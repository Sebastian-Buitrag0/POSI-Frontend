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
      String tenantId, DateTime from, DateTime to,
      {int limit = 50, int offset = 0});

  Future<List<Sale>> getTodaySales(String tenantId);

  Future<void> voidSale(Sale sale);
}
