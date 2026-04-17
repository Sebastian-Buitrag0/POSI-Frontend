import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/services/api_client.dart';
import '../../domain/repositories/sales_repository.dart';
import 'local_sales_repository.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final apiClient = ref.watch(apiClientProvider);
  return LocalSalesRepository(
    db: db,
    salesDao: db.salesDao,
    productsDao: db.productsDao,
    apiClient: apiClient,
  );
});
