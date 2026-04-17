import '../entities/product.dart';

abstract class ProductRepository {
  Stream<List<Product>> watchAll(String tenantId);
  Stream<List<Product>> watchSearch(String query, String tenantId);
  Future<Product?> getById(int id);
  Future<Product?> getByBarcode(String barcode, String tenantId);
  Future<int> create(Product product);
  Future<int> update(Product product);
  Future<int> delete(int id);
  Future<List<Product>> getPendingSync(String tenantId);
}
