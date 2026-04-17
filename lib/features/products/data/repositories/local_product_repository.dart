import '../../../../core/database/sync_mixin.dart';
import '../../domain/entities/product.dart';
import '../../domain/mappers/product_mapper.dart';
import '../../domain/repositories/product_repository.dart';
import '../daos/products_dao.dart';

class LocalProductRepository implements ProductRepository {
  const LocalProductRepository(this._dao);

  final ProductsDao _dao;

  @override
  Stream<List<Product>> watchAll(String tenantId) =>
      _dao.watchAll(tenantId).map((rows) => rows.map((r) => r.toDomain()).toList());

  @override
  Stream<List<Product>> watchSearch(String query, String tenantId) =>
      _dao.watchSearch(query, tenantId).map((rows) => rows.map((r) => r.toDomain()).toList());

  @override
  Future<Product?> getById(int id) async {
    final row = await _dao.getById(id);
    return row?.toDomain();
  }

  @override
  Future<Product?> getByBarcode(String barcode, String tenantId) async {
    final row = await _dao.getByBarcode(barcode, tenantId);
    return row?.toDomain();
  }

  @override
  Future<int> create(Product product) =>
      _dao.upsertProduct(product.copyWith(syncStatus: SyncStatus.pending).toCompanion());

  @override
  Future<int> update(Product product) =>
      _dao.upsertProduct(product.copyWith(syncStatus: SyncStatus.pending).toCompanion());

  @override
  Future<int> delete(int id) => _dao.deleteById(id);

  @override
  Future<List<Product>> getPendingSync(String tenantId) async {
    final rows = await _dao.getPendingSync(tenantId);
    return rows.map((r) => r.toDomain()).toList();
  }
}
