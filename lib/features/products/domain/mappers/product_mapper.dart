import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../entities/product.dart';

extension ProductMapper on ProductsTableData {
  Product toDomain() => Product(
        id: id,
        remoteId: remoteId,
        tenantId: tenantId,
        name: name,
        sku: sku,
        barcode: barcode,
        price: price,
        cost: cost,
        stock: stock,
        minStock: minStock,
        categoryId: categoryId,
        isActive: isActive,
        syncStatus: syncStatus,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

extension ProductToCompanion on Product {
  ProductsTableCompanion toCompanion() => ProductsTableCompanion(
        remoteId: Value(remoteId),
        tenantId: Value(tenantId),
        name: Value(name),
        sku: Value(sku),
        barcode: Value(barcode),
        price: Value(price),
        cost: Value(cost),
        stock: Value(stock),
        minStock: Value(minStock),
        categoryId: Value(categoryId),
        isActive: Value(isActive),
        syncStatus: Value(syncStatus),
        updatedAt: Value(DateTime.now()),
      );
}
