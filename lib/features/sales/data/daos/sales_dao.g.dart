// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_dao.dart';

// ignore_for_file: type=lint
mixin _$SalesDaoMixin on DatabaseAccessor<AppDatabase> {
  $SalesTableTable get salesTable => attachedDatabase.salesTable;
  $CategoriesTableTable get categoriesTable => attachedDatabase.categoriesTable;
  $ProductsTableTable get productsTable => attachedDatabase.productsTable;
  $SaleItemsTableTable get saleItemsTable => attachedDatabase.saleItemsTable;
  SalesDaoManager get managers => SalesDaoManager(this);
}

class SalesDaoManager {
  final _$SalesDaoMixin _db;
  SalesDaoManager(this._db);
  $$SalesTableTableTableManager get salesTable =>
      $$SalesTableTableTableManager(_db.attachedDatabase, _db.salesTable);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(
        _db.attachedDatabase,
        _db.categoriesTable,
      );
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db.attachedDatabase, _db.productsTable);
  $$SaleItemsTableTableTableManager get saleItemsTable =>
      $$SaleItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.saleItemsTable,
      );
}
