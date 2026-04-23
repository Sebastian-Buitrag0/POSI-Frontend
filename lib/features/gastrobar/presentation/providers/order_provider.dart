import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/gastrobar_local_repository.dart';
import '../../domain/entities/order_model.dart';

class OrderNotifier extends FamilyAsyncNotifier<OrderModel, String> {
  late final int _localOrderId;

  @override
  Future<OrderModel> build(String arg) async {
    _localOrderId = int.parse(arg);
    final repo = ref.read(gastrobarLocalRepositoryProvider);

    final stream = repo.watchOrderModel(_localOrderId);

    final sub = stream.listen(
      (data) {
        if (data != null) {
          state = AsyncData(data);
        }
      },
      onError: (e, st) => state = AsyncError(e, st),
    );

    ref.onDispose(sub.cancel);

    final first = await stream.first;
    if (first == null) throw Exception('Order not found');
    return first;
  }

  Future<void> refresh() async {
    // Stream already updates automatically; trigger a rebuild by reading again
    final repo = ref.read(gastrobarLocalRepositoryProvider);
    final order = await repo.getOrderModel(_localOrderId);
    if (order != null) {
      state = AsyncData(order);
    }
  }

  Future<void> addItem(String productId, int qty, String? notes) async {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) throw Exception('Not authenticated');

    final db = ref.read(databaseProvider);
    final repo = ref.read(gastrobarLocalRepositoryProvider);

    // Resolve product
    ProductsTableData? product;
    final parsed = int.tryParse(productId);
    if (parsed != null) {
      product = await db.productsDao.getById(parsed);
    } else {
      product = await db.productsDao.getByRemoteId(productId, auth.user.tenantId);
    }

    if (product == null) throw Exception('Product not found');

    await repo.addItems(_localOrderId, [
      {
        'productId': product.remoteId ?? product.id.toString(),
        'productName': product.name,
        'unitPrice': product.price,
        'quantity': qty,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }
    ], auth.user.tenantId);
  }

  Future<void> sendToKitchen() async {
    final repo = ref.read(gastrobarLocalRepositoryProvider);
    await repo.sendToKitchen(_localOrderId);
  }

  Future<void> requestBill(String? notes) async {
    final repo = ref.read(gastrobarLocalRepositoryProvider);
    await repo.requestBill(_localOrderId, notes);
  }

  Future<String> closeOrder(String paymentMethod, String? notes) async {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) throw Exception('Not authenticated');

    final repo = ref.read(gastrobarLocalRepositoryProvider);
    final remoteSaleId = await repo.closeOrder(
      _localOrderId,
      paymentMethod,
      notes,
      auth.user.tenantId,
    );
    return remoteSaleId ?? '';
  }

  Future<void> cancelItem(String itemId) async {
    final localId = int.tryParse(itemId);
    if (localId == null) return;
    final repo = ref.read(gastrobarLocalRepositoryProvider);
    await repo.dao.updateItemStatus(localId, 'cancelled');
  }

  Future<void> cancelOrder() async {
    final repo = ref.read(gastrobarLocalRepositoryProvider);
    final order = await repo.dao.getOrderById(_localOrderId);
    if (order == null) return;

    await repo.dao.updateOrderStatus(_localOrderId, 'cancelled');
    await repo.dao.updateTableStatus(order.localMesaId, 'available');
  }
}

final orderProvider =
    AsyncNotifierProviderFamily<OrderNotifier, OrderModel, String>(
  OrderNotifier.new,
);
