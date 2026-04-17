import 'package:drift/drift.dart';
import '../sync_mixin.dart';

class CategoriesTable extends Table with SyncColumns {
  @override
  String get tableName => 'categories';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
}
