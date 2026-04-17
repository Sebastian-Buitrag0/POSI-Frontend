import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../domain/repositories/product_repository.dart';
import 'local_product_repository.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalProductRepository(db.productsDao);
});
