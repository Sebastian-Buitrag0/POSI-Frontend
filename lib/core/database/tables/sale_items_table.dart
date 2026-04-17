import 'package:drift/drift.dart';
import '../sync_mixin.dart';
import 'sales_table.dart';
import 'products_table.dart';

class SaleItemsTable extends Table with SyncColumns {
  @override
  String get tableName => 'sale_items';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId =>
      integer().named('sale_id').references(SalesTable, #id)();
  IntColumn get productId =>
      integer().named('product_id').references(ProductsTable, #id)();
  TextColumn get productName => text().named('product_name')();
  RealColumn get unitPrice => real().named('unit_price')();
  IntColumn get quantity => integer()();
  RealColumn get subtotal => real()();
}
