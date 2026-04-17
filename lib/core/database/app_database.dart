import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'sync_mixin.dart';
import 'tables/categories_table.dart';
import 'tables/products_table.dart';
import 'tables/sales_table.dart';
import 'tables/sale_items_table.dart';
import '../../features/products/data/daos/products_dao.dart';
import '../../features/sales/data/daos/sales_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CategoriesTable,
    ProductsTable,
    SalesTable,
    SaleItemsTable,
  ],
  daos: [ProductsDao, SalesDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'posi.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
