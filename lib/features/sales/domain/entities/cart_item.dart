class CartItem {
  const CartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.maxStock = 999,
  });

  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final int maxStock;

  double get subtotal => unitPrice * quantity;

  CartItem copyWith({
    int? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    int? maxStock,
  }) => CartItem(
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    unitPrice: unitPrice ?? this.unitPrice,
    quantity: quantity ?? this.quantity,
    maxStock: maxStock ?? this.maxStock,
  );

  @override
  bool operator ==(Object other) =>
      other is CartItem && other.productId == productId;

  @override
  int get hashCode => productId.hashCode;
}
