import 'sale.dart';

class SalesSummary {
  const SalesSummary({
    required this.totalCount,
    required this.totalRevenue,
    required this.cashRevenue,
    required this.cardRevenue,
    required this.transferRevenue,
    required this.totalItemsSold,
  });

  final int totalCount;
  final double totalRevenue;
  final double cashRevenue;
  final double cardRevenue;
  final double transferRevenue;
  final int totalItemsSold;

  double get averageTicket =>
      totalCount == 0 ? 0 : totalRevenue / totalCount;

  factory SalesSummary.fromSales(List<Sale> sales) {
    double cash = 0, card = 0, transfer = 0;
    int items = 0;
    for (final s in sales) {
      switch (s.paymentMethod) {
        case PaymentMethod.cash:
          cash += s.total;
        case PaymentMethod.card:
          card += s.total;
        case PaymentMethod.transfer:
          transfer += s.total;
      }
      items += s.items.fold(0, (sum, i) => sum + i.quantity);
    }
    return SalesSummary(
      totalCount: sales.length,
      totalRevenue: cash + card + transfer,
      cashRevenue: cash,
      cardRevenue: card,
      transferRevenue: transfer,
      totalItemsSold: items,
    );
  }

  static const empty = SalesSummary(
    totalCount: 0,
    totalRevenue: 0,
    cashRevenue: 0,
    cardRevenue: 0,
    transferRevenue: 0,
    totalItemsSold: 0,
  );
}
