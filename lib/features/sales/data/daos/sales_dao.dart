import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/sync_mixin.dart';
import '../../../../core/database/tables/sales_table.dart';
import '../../../../core/database/tables/sale_items_table.dart';

part 'sales_dao.g.dart';

@DriftAccessor(tables: [SalesTable, SaleItemsTable])
class SalesDao extends DatabaseAccessor<AppDatabase>
    with _$SalesDaoMixin {
  SalesDao(super.db);

  Future<int> insertSale(SalesTableCompanion sale) =>
      into(salesTable).insert(sale);

  Future<int> insertSaleItem(SaleItemsTableCompanion item) =>
      into(saleItemsTable).insert(item);

  Stream<List<SalesTableData>> watchAll(String tenantId) =>
      (select(salesTable)
            ..where((t) => t.tenantId.equals(tenantId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<SalesTableData?> getById(int id) =>
      (select(salesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<SaleItemsTableData>> getItemsBySaleId(int saleId) =>
      (select(saleItemsTable)
            ..where((t) => t.saleId.equals(saleId)))
          .get();

  Future<List<SalesTableData>> getByDateRange(
          String tenantId, DateTime from, DateTime to,
          {int limit = 50, int offset = 0}) =>
      (select(salesTable)
            ..where((t) =>
                t.tenantId.equals(tenantId) &
                t.createdAt.isBiggerOrEqualValue(from) &
                t.createdAt.isSmallerOrEqualValue(to))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(limit, offset: offset))
          .get();

  Stream<List<SalesTableData>> watchByDateRange(
          String tenantId, DateTime from, DateTime to) =>
      (select(salesTable)
            ..where((t) =>
                t.tenantId.equals(tenantId) &
                t.createdAt.isBiggerOrEqualValue(from) &
                t.createdAt.isSmallerOrEqualValue(to))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<List<SalesTableData>> getPendingSync(String tenantId) =>
      (select(salesTable)
            ..where((t) =>
                t.tenantId.equals(tenantId) &
                t.syncStatus.equals(SyncStatus.pending.index)))
          .get();

  Future<void> markSynced(int localId, String remoteId) =>
      (update(salesTable)..where((t) => t.id.equals(localId))).write(
        SalesTableCompanion(
          remoteId: Value(remoteId),
          syncStatus: Value(SyncStatus.synced),
        ),
      );

  Future<void> updateStatus(int localId, String status) =>
      (update(salesTable)..where((t) => t.id.equals(localId))).write(
        SalesTableCompanion(status: Value(status)),
      );
}
