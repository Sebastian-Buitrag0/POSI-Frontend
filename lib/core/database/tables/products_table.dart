import 'package:drift/drift.dart';
import '../sync_mixin.dart';
import 'categories_table.dart';

class ProductsTable extends Table with SyncColumns {
  @override
  String get tableName => 'products';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  RealColumn get price => real()();
  RealColumn get cost => real().nullable()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get minStock =>
      integer().named('min_stock').withDefault(const Constant(0))();
  IntColumn get categoryId => integer()
      .named('category_id')
      .nullable()
      .references(CategoriesTable, #id)();
  BoolColumn get isActive =>
      boolean().named('is_active').withDefault(const Constant(true))();
}
