import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../database/sync_mixin.dart';
import 'api_client.dart';
import '../../features/products/data/daos/products_dao.dart';
import '../../features/sales/data/daos/sales_dao.dart';
import '../../features/gastrobar/data/daos/gastrobar_dao.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final api = ref.watch(apiClientProvider);
  return SyncService(
    productsDao: db.productsDao,
    salesDao: db.salesDao,
    gastrobarDao: db.gastrobarDao,
    api: api,
  );
});

class SyncResult {
  const SyncResult({
    required this.productsSynced,
    required this.salesSynced,
    required this.ordersSynced,
  });
  final int productsSynced;
  final int salesSynced;
  final int ordersSynced;
}

class SyncService {
  SyncService({
    required this.productsDao,
    required this.salesDao,
    required this.gastrobarDao,
    required this.api,
  });

  final ProductsDao productsDao;
  final SalesDao salesDao;
  final GastrobarDao gastrobarDao;
  final ApiClient api;

  Future<SyncResult> sync(String tenantId) async {
    await _pullProducts(tenantId);
    final productsSynced = await _syncProducts(tenantId);
    final salesSynced = await _syncSales(tenantId);
    final ordersSynced = await _syncOrders(tenantId);
    return SyncResult(
      productsSynced: productsSynced,
      salesSynced: salesSynced,
      ordersSynced: ordersSynced,
    );
  }

  Future<void> _pullProducts(String tenantId) async {
    final response = await api.get(ApiConstants.products);
    final list = (response.data as List).cast<Map<String, dynamic>>();

    for (final p in list) {
      final remoteId = p['id'] as String;
      final existing = await productsDao.getByRemoteId(remoteId, tenantId);
      if (existing != null) continue;

      await productsDao.upsertProduct(ProductsTableCompanion(
        remoteId: Value(remoteId),
        tenantId: Value(tenantId),
        name: Value(p['name'] as String),
        sku: Value(p['sku'] as String?),
        barcode: Value(p['barcode'] as String?),
        price: Value((p['price'] as num).toDouble()),
        cost: Value((p['cost'] as num?)?.toDouble()),
        stock: Value(p['stock'] as int),
        minStock: Value(p['minStock'] as int),
        isActive: Value(p['isActive'] as bool),
        syncStatus: Value(SyncStatus.synced),
        updatedAt: Value(DateTime.parse(p['updatedAt'] as String).toLocal()),
      ));
    }
  }

  Future<int> _syncProducts(String tenantId) async {
    final pending = await productsDao.getPendingSync(tenantId);
    if (pending.isEmpty) return 0;

    final response = await api.post(
      ApiConstants.productsSync,
      data: {
        'products': pending
            .map((p) => {
                  'localId': p.id,
                  'name': p.name,
                  'sku': p.sku,
                  'barcode': p.barcode,
                  'price': p.price,
                  'cost': p.cost,
                  'stock': p.stock,
                  'minStock': p.minStock,
                  'isActive': p.isActive,
                  'createdAt': p.createdAt.toUtc().toIso8601String(),
                  'updatedAt': p.updatedAt.toUtc().toIso8601String(),
                })
            .toList(),
      },
    );

    final mappings =
        (response.data['mappings'] as List).cast<Map<String, dynamic>>();
    for (final m in mappings) {
      await productsDao.markSynced(
        m['localId'] as int,
        m['remoteId'] as String,
      );
    }
    return response.data['synced'] as int;
  }

  Future<int> _syncSales(String tenantId) async {
    final pending = await salesDao.getPendingSync(tenantId);
    if (pending.isEmpty) return 0;

    final salesPayload = <Map<String, dynamic>>[];

    for (final sale in pending) {
      final items = await salesDao.getItemsBySaleId(sale.id);
      salesPayload.add({
        'localId': sale.id,
        'saleNumber': sale.saleNumber,
        'subtotal': sale.subtotal,
        'tax': sale.tax,
        'total': sale.total,
        'paymentMethod': sale.paymentMethod,
        'status': sale.status,
        'notes': sale.notes,
        'createdAt': sale.createdAt.toUtc().toIso8601String(),
        'items': items
            .map((i) => {
                  'productName': i.productName,
                  'unitPrice': i.unitPrice,
                  'quantity': i.quantity,
                  'subtotal': i.subtotal,
                })
            .toList(),
      });
    }

    final response = await api.post(
      ApiConstants.salesSync,
      data: {'sales': salesPayload},
    );

    final mappings =
        (response.data['mappings'] as List).cast<Map<String, dynamic>>();
    for (final m in mappings) {
      await salesDao.markSynced(
        m['localId'] as int,
        m['remoteId'] as String,
      );
    }
    return response.data['synced'] as int;
  }

  Future<int> _syncOrders(String tenantId) async {
    final pending = await gastrobarDao.getPendingOrders(tenantId);
    if (pending.isEmpty) return 0;

    int synced = 0;

    for (final order in pending) {
      try {
        final table = await gastrobarDao.watchActiveTables(tenantId)
            .map((list) => list.firstWhere((t) => t.id == order.localMesaId))
            .first;

        if (table.remoteId == null) continue;

        final res = await api.post('/api/gastrobar/tables/${table.remoteId}/orders');
        final remoteId = (res.data['id'] ?? res.data['orderId']) as String?;

        if (remoteId != null) {
          await gastrobarDao.markOrderSynced(order.id, remoteId);
          synced++;
        }
      } catch (_) {
        // Leave as pending for next cycle
      }
    }

    return synced;
  }
}
