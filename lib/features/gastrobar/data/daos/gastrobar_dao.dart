import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/sync_mixin.dart';
import '../../../../core/database/tables/gastrobar_tables.dart';

part 'gastrobar_dao.g.dart';

@DriftAccessor(tables: [MesasTable, ComandasTable, ComandaItemsTable])
class GastrobarDao extends DatabaseAccessor<AppDatabase> with _$GastrobarDaoMixin {
  GastrobarDao(super.db);

  // Tables
  Stream<List<MesasTableData>> watchActiveTables(String tenantId) =>
      (select(mesasTable)
            ..where((t) => t.tenantId.equals(tenantId) & t.isActive.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .watch();

  Future<int> upsertTable(MesasTableCompanion t) =>
      into(mesasTable).insertOnConflictUpdate(t);

  Future<MesasTableData?> getTableByRemoteId(String remoteId) =>
      (select(mesasTable)..where((t) => t.remoteId.equals(remoteId))).getSingleOrNull();

  Future<MesasTableData?> getTableById(int id) =>
      (select(mesasTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<void> markTableSynced(int localId, String remoteId) =>
      (update(mesasTable)..where((t) => t.id.equals(localId))).write(
        MesasTableCompanion(
          remoteId: Value(remoteId),
          syncStatus: const Value(SyncStatus.synced),
        ),
      );

  Future<void> updateTableStatus(int localId, String status) =>
      (update(mesasTable)..where((t) => t.id.equals(localId)))
          .write(MesasTableCompanion(status: Value(status)));

  Future<void> deleteTable(int localId) =>
      (delete(mesasTable)..where((t) => t.id.equals(localId))).go();

  // Orders
  Future<int> insertOrder(ComandasTableCompanion o) =>
      into(comandasTable).insert(o);

  Future<ComandasTableData?> getOpenOrderForTable(int localMesaId) =>
      (select(comandasTable)
            ..where((o) => o.localMesaId.equals(localMesaId) & o.status.equals('open')))
          .getSingleOrNull();

  Future<ComandasTableData?> getOrderById(int id) =>
      (select(comandasTable)..where((o) => o.id.equals(id))).getSingleOrNull();

  Future<void> updateOrderStatus(int localId, String status, {DateTime? closedAt}) =>
      (update(comandasTable)..where((o) => o.id.equals(localId))).write(
        ComandasTableCompanion(
          status: Value(status),
          closedAt: closedAt != null ? Value(closedAt) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> markOrderSynced(int localId, String remoteId) =>
      (update(comandasTable)..where((o) => o.id.equals(localId))).write(
        ComandasTableCompanion(
          remoteId: Value(remoteId),
          syncStatus: const Value(SyncStatus.synced),
        ),
      );

  Future<List<ComandasTableData>> getPendingOrders(String tenantId) =>
      (select(comandasTable)
            ..where((o) =>
                o.tenantId.equals(tenantId) &
                o.syncStatus.equals(SyncStatus.pending.index)))
          .get();

  Stream<List<PendingPaymentOrder>> watchPendingPaymentOrders(String tenantId) {
    final query = select(comandasTable).join([
      innerJoin(mesasTable, mesasTable.id.equalsExp(comandasTable.localMesaId)),
    ])
      ..where(
        comandasTable.status.equals('pending_payment') &
            comandasTable.tenantId.equals(tenantId),
      )
      ..orderBy([OrderingTerm.asc(comandasTable.openedAt)]);

    return query.watch().map((rows) => rows.map((row) {
          final order = row.readTable(comandasTable);
          final table = row.readTable(mesasTable);
          return PendingPaymentOrder(
            comandaLocalId: order.id,
            tableName: table.name,
            orderNumber: order.orderNumber,
            openedAt: order.openedAt,
            localMesaId: table.id,
          );
        }).toList());
  }

  // Order Items
  Future<int> insertOrderItem(ComandaItemsTableCompanion item) =>
      into(comandaItemsTable).insert(item);

  Stream<List<ComandaItemsTableData>> watchItemsByOrder(int localComandaId) =>
      (select(comandaItemsTable)
            ..where((i) => i.localComandaId.equals(localComandaId))
            ..orderBy([(i) => OrderingTerm.asc(i.createdAt)]))
          .watch();

  Future<List<ComandaItemsTableData>> getItemsByOrder(int localComandaId) =>
      (select(comandaItemsTable)..where((i) => i.localComandaId.equals(localComandaId))).get();

  Future<ComandaItemsTableData?> getItemById(int id) =>
      (select(comandaItemsTable)..where((i) => i.id.equals(id))).getSingleOrNull();

  Future<void> updateItemStatus(int localId, String status) =>
      (update(comandaItemsTable)..where((i) => i.id.equals(localId))).write(
        ComandaItemsTableCompanion(itemStatus: Value(status)),
      );

  Stream<List<KitchenItem>> watchSentItems(String tenantId) {
    final query = select(comandaItemsTable).join([
      innerJoin(
        comandasTable,
        comandasTable.id.equalsExp(comandaItemsTable.localComandaId),
      ),
      innerJoin(
        mesasTable,
        mesasTable.id.equalsExp(comandasTable.localMesaId),
      ),
    ])
      ..where(
        comandaItemsTable.itemStatus.equals('sent') &
            comandasTable.status.equals('open') &
            comandaItemsTable.tenantId.equals(tenantId),
      )
      ..orderBy([OrderingTerm.asc(comandaItemsTable.createdAt)]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final item = row.readTable(comandaItemsTable);
        final order = row.readTable(comandasTable);
        final table = row.readTable(mesasTable);
        return KitchenItem(
          itemId: item.id,
          productName: item.productName,
          quantity: item.quantity,
          tableName: table.name,
          mesaLocalId: table.id,
          comandaLocalId: order.id,
          orderedAt: item.createdAt,
        );
      }).toList();
    });
  }
}

class PendingPaymentOrder {
  final int comandaLocalId;
  final String tableName;
  final String orderNumber;
  final DateTime openedAt;
  final int localMesaId;

  const PendingPaymentOrder({
    required this.comandaLocalId,
    required this.tableName,
    required this.orderNumber,
    required this.openedAt,
    required this.localMesaId,
  });
}

class KitchenItem {
  final int itemId;
  final String productName;
  final int quantity;
  final String tableName;
  final int mesaLocalId;
  final int comandaLocalId;
  final DateTime orderedAt;

  const KitchenItem({
    required this.itemId,
    required this.productName,
    required this.quantity,
    required this.tableName,
    required this.mesaLocalId,
    required this.comandaLocalId,
    required this.orderedAt,
  });
}
