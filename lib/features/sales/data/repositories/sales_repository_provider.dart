import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../domain/repositories/sales_repository.dart';
import 'local_sales_repository.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalSalesRepository(
    db: db,
    salesDao: db.salesDao,
    productsDao: db.productsDao,
  );
});
