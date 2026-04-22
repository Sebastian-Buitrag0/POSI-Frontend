class OrderModel {
  final String id;
  final String orderNumber;
  final String tableId;
  final String tableName;
  final String status;
  final String? waiterName;
  final DateTime openedAt;
  final List<OrderItemModel> items;
  final double total;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.tableId,
    required this.tableName,
    required this.status,
    this.waiterName,
    required this.openedAt,
    required this.items,
    required this.total,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] as String,
    orderNumber: json['orderNumber'] as String,
    tableId: json['tableId'] as String,
    tableName: json['tableName'] as String,
    status: json['status'] as String,
    waiterName: json['waiterName'] as String?,
    openedAt: DateTime.parse(json['openedAt'] as String),
    items: (json['items'] as List<dynamic>)
        .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    total: (json['total'] as num).toDouble(),
  );

  List<OrderItemModel> get pendingItems =>
      items.where((i) => i.status == 'pending').toList();
  List<OrderItemModel> get sentItems =>
      items.where((i) => i.status == 'sent').toList();
  List<OrderItemModel> get deliveredItems =>
      items.where((i) => i.status == 'delivered').toList();
}

class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;
  final String status; // pending | sent | delivered | cancelled
  final String? notes;

  const OrderItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    required this.status,
    this.notes,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
    id: json['id'] as String,
    productId: json['productId'] as String,
    productName: json['productName'] as String,
    unitPrice: (json['unitPrice'] as num).toDouble(),
    quantity: json['quantity'] as int,
    subtotal: (json['subtotal'] as num).toDouble(),
    status: json['status'] as String,
    notes: json['notes'] as String?,
  );
}
