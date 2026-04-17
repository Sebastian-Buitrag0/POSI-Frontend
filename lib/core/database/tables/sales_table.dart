import 'package:drift/drift.dart';
import '../sync_mixin.dart';

class SalesTable extends Table with SyncColumns {
  @override
  String get tableName => 'sales';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get saleNumber => text().named('sale_number')();
  RealColumn get subtotal => real()();
  RealColumn get tax => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  TextColumn get paymentMethod => text().named('payment_method')();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  TextColumn get notes => text().nullable()();
}
