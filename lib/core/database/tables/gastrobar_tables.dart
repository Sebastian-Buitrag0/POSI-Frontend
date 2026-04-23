import 'package:drift/drift.dart';
import '../sync_mixin.dart';

class MesasTable extends Table with SyncColumns {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get capacity => integer().withDefault(const Constant(4))();
  TextColumn get status => text().withDefault(const Constant('available'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class ComandasTable extends Table with SyncColumns {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get localMesaId => integer().references(MesasTable, #id)();
  TextColumn get orderNumber => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('open'))();
  TextColumn get waiterId => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get openedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get closedAt => dateTime().nullable()();
  TextColumn get remoteSaleId => text().nullable()();
}

class ComandaItemsTable extends Table with SyncColumns {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get localComandaId => integer().references(ComandasTable, #id)();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  RealColumn get unitPrice => real()();
  IntColumn get quantity => integer()();
  RealColumn get subtotal => real()();
  TextColumn get itemStatus => text().withDefault(const Constant('pending'))();
  TextColumn get notes => text().nullable()();
}
