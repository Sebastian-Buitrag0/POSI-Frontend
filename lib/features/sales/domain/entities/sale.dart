enum PaymentMethod {
  cash,
  card,
  transfer
}

enum SaleStatus { completed, cancelled, refunded }

class SaleItem {
  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  final int id;
  final int saleId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItem copyWith({
    int? id,
    int? saleId,
    int? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? subtotal,
  }) => SaleItem(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    subtotal: subtotal ?? this.subtotal,
  );
}

class Sale {
  const Sale({
    required this.id,
    required this.saleNumber,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.tenantId,
    required this.createdAt,
    this.notes,
  });

  final int id;
  final String saleNumber;
  final List<SaleItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final PaymentMethod paymentMethod;
  final SaleStatus status;
  final String tenantId;
  final String? notes;
  final DateTime createdAt;

  Sale copyWith({
    int? id,
    String? saleNumber,
    List<SaleItem>? items,
    double? subtotal,
    double? tax,
    double? total,
    PaymentMethod? paymentMethod,
    SaleStatus? status,
    String? tenantId,
    String? notes,
    DateTime? createdAt,
  }) => Sale(
    id: id ?? this.id,
    saleNumber: saleNumber ?? this.saleNumber,
    items: items ?? this.items,
    subtotal: subtotal ?? this.subtotal,
    tax: tax ?? this.tax,
    total: total ?? this.total,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    status: status ?? this.status,
    tenantId: tenantId ?? this.tenantId,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
}
