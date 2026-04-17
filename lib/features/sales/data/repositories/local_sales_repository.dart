import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/sync_mixin.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/mappers/sale_mapper.dart';
import '../../domain/repositories/sales_repository.dart';
import '../daos/sales_dao.dart';
import '../../../products/data/daos/products_dao.dart';

class LocalSalesRepository implements SalesRepository {
  const LocalSalesRepository({
    required this.db,
    required this.salesDao,
    required this.productsDao,
  });

  final AppDatabase db;
  final SalesDao salesDao;
  final ProductsDao productsDao;

  @override
  Future<Sale> completeSale({
    required List<CartItem> items,
    required PaymentMethod paymentMethod,
    required String tenantId,
    String? notes,
  }) async {
    final now = DateTime.now();
    final saleNumber = 'S${now.millisecondsSinceEpoch}';
    final subtotal = items.fold(0.0, (sum, i) => sum + i.subtotal);
    final tax = subtotal * 0.16;
    final total = subtotal + tax;

    return db.transaction<Sale>(() async {
      final saleId = await salesDao.insertSale(
        SalesTableCompanion(
          saleNumber: Value(saleNumber),
          subtotal: Value(subtotal),
          tax: Value(tax),
          total: Value(total),
          paymentMethod: Value(paymentMethod.name),
          status: const Value('completed'),
          notes: Value(notes),
          tenantId: Value(tenantId),
          syncStatus: const Value(SyncStatus.pending),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      for (final item in items) {
        await salesDao.insertSaleItem(
          item.toCompanion(saleId: saleId, tenantId: tenantId),
        );
        await productsDao.decreaseStock(item.productId, item.quantity);
      }

      final saleRow = (await salesDao.getById(saleId))!;
      final itemRows = await salesDao.getItemsBySaleId(saleId);
      return saleRow.toDomain(itemRows.map((r) => r.toDomain()).toList());
    });
  }

  @override
  Stream<List<Sale>> watchAll(String tenantId) {
    return salesDao.watchAll(tenantId).asyncMap((rows) async {
      final sales = <Sale>[];
      for (final row in rows) {
        final itemRows = await salesDao.getItemsBySaleId(row.id);
        sales.add(row.toDomain(itemRows.map((r) => r.toDomain()).toList()));
      }
      return sales;
    });
  }

  @override
  Future<List<Sale>> getByDateRange(
      String tenantId, DateTime from, DateTime to) async {
    final rows = await salesDao.getByDateRange(tenantId, from, to);
    final sales = <Sale>[];
    for (final row in rows) {
      final itemRows = await salesDao.getItemsBySaleId(row.id);
      sales.add(row.toDomain(itemRows.map((r) => r.toDomain()).toList()));
    }
    return sales;
  }

  @override
  Future<List<Sale>> getTodaySales(String tenantId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getByDateRange(tenantId, startOfDay, endOfDay);
  }
}
