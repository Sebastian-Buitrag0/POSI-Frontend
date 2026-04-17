import '../entities/sale.dart';
import '../entities/cart_item.dart';

abstract class SalesRepository {
  Future<Sale> completeSale({
    required List<CartItem> items,
    required PaymentMethod paymentMethod,
    required String tenantId,
    String? notes,
  });

  Stream<List<Sale>> watchAll(String tenantId);

  Future<List<Sale>> getByDateRange(
      String tenantId, DateTime from, DateTime to);

  Future<List<Sale>> getTodaySales(String tenantId);
}
