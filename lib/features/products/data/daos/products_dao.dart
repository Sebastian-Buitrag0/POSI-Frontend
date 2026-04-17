import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/sync_mixin.dart';
import '../../../../core/database/tables/products_table.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [ProductsTable])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(super.db);

  // Reactive stream — auto-actualiza la UI cuando cambia la DB
  Stream<List<ProductsTableData>> watchAll(String tenantId) =>
      (select(productsTable)
            ..where((t) => t.tenantId.equals(tenantId))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Stream<List<ProductsTableData>> watchSearch(
          String query, String tenantId) =>
      (select(productsTable)
            ..where((t) =>
                t.tenantId.equals(tenantId) &
                (t.name.like('%$query%') | t.barcode.like('%$query%')))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<ProductsTableData?> getById(int id) =>
      (select(productsTable)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<ProductsTableData?> getByBarcode(
          String barcode, String tenantId) =>
      (select(productsTable)
            ..where((t) =>
                t.barcode.equals(barcode) & t.tenantId.equals(tenantId)))
          .getSingleOrNull();

  Future<ProductsTableData?> getByRemoteId(String remoteId, String tenantId) =>
      (select(productsTable)
            ..where((t) =>
                t.remoteId.equals(remoteId) & t.tenantId.equals(tenantId)))
          .getSingleOrNull();

  Future<int> upsertProduct(ProductsTableCompanion product) =>
      into(productsTable).insertOnConflictUpdate(product);

  Future<int> deleteById(int id) =>
      (delete(productsTable)..where((t) => t.id.equals(id))).go();

  Future<List<ProductsTableData>> getPendingSync(String tenantId) =>
      (select(productsTable)
            ..where((t) =>
                t.tenantId.equals(tenantId) &
                t.syncStatus.equals(SyncStatus.pending.index)))
          .get();

  Future<void> decreaseStock(int productId, int quantity) =>
      customUpdate(
        'UPDATE products SET stock = stock - ?, updated_at = ? WHERE id = ?',
        variables: [
          Variable.withInt(quantity),
          Variable<DateTime>(DateTime.now()),
          Variable.withInt(productId),
        ],
        updates: {productsTable},
      );

  Future<void> markSynced(int localId, String remoteId) =>
      (update(productsTable)..where((t) => t.id.equals(localId))).write(
        ProductsTableCompanion(
          remoteId: Value(remoteId),
          syncStatus: Value(SyncStatus.synced),
        ),
      );
}
