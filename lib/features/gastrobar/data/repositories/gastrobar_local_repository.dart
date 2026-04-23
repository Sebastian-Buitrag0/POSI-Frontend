import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/sync_mixin.dart';
import '../../../../core/services/api_client.dart';
import '../../domain/entities/order_model.dart';
import '../../domain/entities/table_model.dart';
import '../daos/gastrobar_dao.dart' show GastrobarDao, PendingPaymentOrder;

final gastrobarLocalRepositoryProvider = Provider<GastrobarLocalRepository>((ref) {
  return GastrobarLocalRepository(
    dao: ref.watch(databaseProvider).gastrobarDao,
    api: ref.watch(apiClientProvider),
  );
});

class GastrobarLocalRepository {
  GastrobarLocalRepository({
    required this.dao,
    required this.api,
  });

  final GastrobarDao dao;
  final ApiClient api;

  // ─── Tables ────────────────────────────────────────────────────────────────

  Stream<List<MesasTableData>> watchActiveTables(String tenantId) =>
      dao.watchActiveTables(tenantId);

  Future<void> fetchAndSyncTables(String tenantId) async {
    try {
      final res = await api.get('/api/gastrobar/tables');
      final list = (res.data as List).cast<Map<String, dynamic>>();

      for (final json in list) {
        final remoteId = json['id'] as String;
        final existing = await dao.getTableByRemoteId(remoteId);

        final companion = MesasTableCompanion(
          id: existing != null ? Value(existing.id) : const Value.absent(),
          remoteId: Value(remoteId),
          tenantId: Value(tenantId),
          name: Value(json['name'] as String),
          capacity: Value(json['capacity'] as int),
          status: Value(json['status'] as String),
          isActive: Value(json['isActive'] as bool),
          syncStatus: const Value(SyncStatus.synced),
          createdAt: json['createdAt'] != null
              ? Value(DateTime.parse(json['createdAt'] as String).toLocal())
              : const Value.absent(),
          updatedAt: json['updatedAt'] != null
              ? Value(DateTime.parse(json['updatedAt'] as String).toLocal())
              : const Value.absent(),
        );

        await dao.upsertTable(companion);
      }
    } catch (_) {
      // Silently fail when offline; local data is source of truth
    }
  }

  Future<List<TableModel>> getTableModels(String tenantId) async {
    final tables = await dao.watchActiveTables(tenantId).first;
    return Future.wait(tables.map((t) => _toTableModel(t, tenantId)));
  }

  Future<TableModel> _toTableModel(MesasTableData t, String tenantId) async {
    // Count active order items for this table
    int activeItemCount = 0;
    final openOrder = await dao.getOpenOrderForTable(t.id);
    if (openOrder != null) {
      final items = await dao.getItemsByOrder(openOrder.id);
      activeItemCount = items.where((i) => i.itemStatus != 'cancelled').length;
    }

    return TableModel(
      id: t.remoteId ?? t.id.toString(),
      name: t.name,
      capacity: t.capacity,
      status: t.status,
      isActive: t.isActive,
      activeOrderItemCount: activeItemCount,
    );
  }

  Future<void> deleteTable(int localId, String? remoteId) async {
    await dao.deleteTable(localId);
    if (remoteId != null) {
      try {
        await api.delete('/api/gastrobar/tables/$remoteId');
      } catch (_) {}
    }
  }

  Future<void> createTable(String name, int capacity, String tenantId) async {
    final localId = await dao.upsertTable(MesasTableCompanion(
      tenantId: Value(tenantId),
      name: Value(name),
      capacity: Value(capacity),
      status: const Value('available'),
      isActive: const Value(true),
      syncStatus: const Value(SyncStatus.pending),
    ));

    // Background sync
    unawaited(_syncTableToRemote(localId, tenantId));
  }

  Future<void> _syncTableToRemote(int localId, String tenantId) async {
    try {
      final table = await dao.getTableById(localId);
      if (table == null) return;

      final res = await api.post('/api/gastrobar/tables', data: {
        'name': table.name,
        'capacity': table.capacity,
      });

      final remoteId = (res.data['id'] ?? res.data['remoteId']) as String?;
      if (remoteId != null) {
        await dao.markTableSynced(localId, remoteId);
      }
    } catch (_) {
      // Leave as pending for next sync cycle
    }
  }

  // ─── Orders ────────────────────────────────────────────────────────────────

  Future<int> openOrder(int localMesaId, String tenantId) async {
    // Check if there's already an open order
    final existing = await dao.getOpenOrderForTable(localMesaId);
    if (existing != null) {
      return existing.id;
    }

    final localId = await dao.insertOrder(ComandasTableCompanion(
      localMesaId: Value(localMesaId),
      tenantId: Value(tenantId),
      status: const Value('open'),
      syncStatus: const Value(SyncStatus.pending),
      orderNumber: Value('MESA-$localMesaId-${DateTime.now().millisecondsSinceEpoch}'),
    ));

    await dao.updateTableStatus(localMesaId, 'occupied');

    // Background sync
    unawaited(_syncOrderToRemote(localId, tenantId));

    return localId;
  }

  Future<void> _syncOrderToRemote(int localId, String tenantId) async {
    try {
      final order = await dao.getOrderById(localId);
      if (order == null || order.remoteId != null) return;

      final table = await dao.watchActiveTables(tenantId)
          .map((list) => list.firstWhere((t) => t.id == order.localMesaId))
          .first;

      if (table.remoteId == null) return;

      final res = await api.post('/api/gastrobar/tables/${table.remoteId}/orders');
      final remoteId = (res.data['id'] ?? res.data['orderId']) as String?;

      if (remoteId != null) {
        await dao.markOrderSynced(localId, remoteId);
      }
    } catch (_) {
      // Leave as pending
    }
  }

  Future<OrderModel?> getOrderModel(int localComandaId) async {
    final order = await dao.getOrderById(localComandaId);
    if (order == null) return null;

    return _buildOrderModel(order);
  }

  Stream<OrderModel?> watchOrderModel(int localComandaId) {
    final orderStream = Stream.periodic(const Duration(seconds: 1))
        .asyncMap((_) => dao.getOrderById(localComandaId))
        .distinct();

    final itemsStream = dao.watchItemsByOrder(localComandaId);

    return Rx.combineLatest2<ComandasTableData?, List<ComandaItemsTableData>, Future<OrderModel?>>(
      orderStream,
      itemsStream,
      (order, items) {
        if (order == null) return Future.value(null);
        return _buildOrderModel(order, items: items);
      },
    ).asyncMap((future) => future);
  }

  Future<OrderModel> _buildOrderModel(ComandasTableData order,
      {List<ComandaItemsTableData>? items}) async {
    final orderItems = items ?? await dao.getItemsByOrder(order.id);

    final table = await dao.getOrderById(order.id).then((o) async {
      if (o == null) return null;
      final tables = await dao.watchActiveTables(o.tenantId).first;
      return tables.firstWhere((t) => t.id == o.localMesaId);
    });

    return OrderModel(
      id: order.remoteId ?? order.id.toString(),
      orderNumber: order.orderNumber,
      tableId: order.localMesaId.toString(),
      tableName: table?.name ?? 'Mesa ${order.localMesaId}',
      status: order.status,
      waiterName: null,
      openedAt: order.openedAt,
      items: orderItems.map((i) => OrderItemModel(
        id: i.remoteId ?? i.id.toString(),
        productId: i.productId,
        productName: i.productName,
        unitPrice: i.unitPrice,
        quantity: i.quantity,
        subtotal: i.subtotal,
        status: i.itemStatus,
        notes: i.notes,
      )).toList(),
      total: orderItems.fold(0.0, (sum, i) => sum + i.subtotal),
    );
  }

  Future<void> addItems(
    int localComandaId,
    List<Map<String, dynamic>> items,
    String tenantId,
  ) async {
    final order = await dao.getOrderById(localComandaId);
    if (order == null) return;

    for (final item in items) {
      final qty = item['quantity'] as int;
      final price = (item['unitPrice'] as num).toDouble();
      await dao.insertOrderItem(ComandaItemsTableCompanion(
        localComandaId: Value(localComandaId),
        tenantId: Value(tenantId),
        productId: Value(item['productId'] as String),
        productName: Value(item['productName'] as String? ?? ''),
        unitPrice: Value(price),
        quantity: Value(qty),
        subtotal: Value(price * qty),
        notes: Value(item['notes'] as String?),
        syncStatus: const Value(SyncStatus.pending),
      ));
    }

    // Background sync
    if (order.remoteId != null) {
      unawaited(_syncItemsToRemote(localComandaId, order.remoteId!, items));
    }
  }

  Future<void> _syncItemsToRemote(
    int localComandaId,
    String remoteOrderId,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      await api.post('/api/gastrobar/orders/$remoteOrderId/items', data: {
        'items': items,
      });
    } catch (_) {
      // Items stay pending; next sync will retry
    }
  }

  Future<void> markItemDelivered(int itemId) async {
    final item = await dao.getItemById(itemId);
    if (item == null) return;

    await dao.updateItemStatus(itemId, 'delivered');

    final order = await dao.getOrderById(item.localComandaId);
    if (order?.remoteId != null && item.remoteId != null) {
      unawaited(_patchItemStatus(order!.remoteId!, item.remoteId!, 'delivered'));
    }
  }

  Future<void> sendToKitchen(int localComandaId) async {
    final items = await dao.getItemsByOrder(localComandaId);
    final pending = items.where((i) => i.itemStatus == 'pending').toList();

    for (final item in pending) {
      await dao.updateItemStatus(item.id, 'sent');
    }

    final order = await dao.getOrderById(localComandaId);
    if (order?.remoteId != null) {
      for (final item in pending) {
        if (item.remoteId != null) {
          unawaited(_patchItemStatus(order!.remoteId!, item.remoteId!, 'sent'));
        }
      }
    }
  }

  Future<void> _patchItemStatus(
    String remoteOrderId,
    String remoteItemId,
    String status,
  ) async {
    try {
      await api.patch(
        '/api/gastrobar/orders/$remoteOrderId/items/$remoteItemId/status',
        data: {'status': status},
      );
    } catch (_) {
      // Ignore; status is already updated locally
    }
  }

  Future<void> requestBill(int localComandaId, String? notes) async {
    final order = await dao.getOrderById(localComandaId);
    if (order == null) return;
    await dao.updateOrderStatus(localComandaId, 'pending_payment');
    await dao.updateTableStatus(order.localMesaId, 'available');
  }

  Future<void> markOrderPaid(int localComandaId) async {
    final order = await dao.getOrderById(localComandaId);
    if (order == null) return;

    await dao.updateOrderStatus(localComandaId, 'closed', closedAt: DateTime.now());

    if (order.remoteId != null) {
      unawaited(_syncCloseOrder(order.remoteId!, 'cash_register', null));
    }
  }

  Stream<List<PendingPaymentOrder>> watchPendingPaymentOrders(String tenantId) =>
      dao.watchPendingPaymentOrders(tenantId);

  Future<List<ComandaItemsTableData>> getItemsByOrder(int localComandaId) =>
      dao.getItemsByOrder(localComandaId);

  Future<String?> closeOrder(
    int localComandaId,
    String paymentMethod,
    String? notes,
    String tenantId,
  ) async {
    final order = await dao.getOrderById(localComandaId);
    if (order == null) return null;

    await dao.updateOrderStatus(localComandaId, 'closed', closedAt: DateTime.now());
    await dao.updateTableStatus(order.localMesaId, 'available');

    if (order.remoteId != null) {
      unawaited(_syncCloseOrder(order.remoteId!, paymentMethod, notes));
    }

    return order.remoteSaleId;
  }

  Future<void> _syncCloseOrder(
    String remoteOrderId,
    String paymentMethod,
    String? notes,
  ) async {
    try {
      await api.post('/api/gastrobar/orders/$remoteOrderId/close', data: {
        'paymentMethod': paymentMethod,
        'notes': notes,
      });
    } catch (_) {
      // Ignore
    }
  }

  // ─── Sync ──────────────────────────────────────────────────────────────────

  Future<void> syncPendingOrders(String tenantId) async {
    final pending = await dao.getPendingOrders(tenantId);
    for (final order in pending) {
      await _syncOrderToRemote(order.id, tenantId);
    }
  }
}

// Simple combineLatest helper since rxdart may not be available
class Rx {
  static Stream<R> combineLatest2<A, B, R>(
    Stream<A> streamA,
    Stream<B> streamB,
    R Function(A, B) combiner,
  ) {
    A? latestA;
    B? latestB;
    bool hasA = false;
    bool hasB = false;

    final controller = StreamController<R>.broadcast();

    void emit() {
      if (hasA && hasB && !controller.isClosed) {
        controller.add(combiner(latestA as A, latestB as B));
      }
    }

    final subA = streamA.listen((a) {
      latestA = a;
      hasA = true;
      emit();
    }, onError: controller.addError);

    final subB = streamB.listen((b) {
      latestB = b;
      hasB = true;
      emit();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await subA.cancel();
      await subB.cancel();
    };

    return controller.stream;
  }
}
