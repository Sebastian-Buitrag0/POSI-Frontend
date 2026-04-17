import '../../../../core/database/sync_mixin.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.tenantId,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    this.remoteId,
    this.sku,
    this.barcode,
    this.cost,
    this.minStock = 0,
    this.categoryId,
    this.isActive = true,
  });

  final int id;
  final String? remoteId;
  final String tenantId;
  final String name;
  final String? sku;
  final String? barcode;
  final double price;
  final double? cost;
  final int stock;
  final int minStock;
  final int? categoryId;
  final bool isActive;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isLowStock => stock <= minStock;
  double? get margin => cost != null && cost! > 0 ? ((price - cost!) / price) * 100 : null;

  Product copyWith({
    int? id,
    String? remoteId,
    String? tenantId,
    String? name,
    String? sku,
    String? barcode,
    double? price,
    double? cost,
    int? stock,
    int? minStock,
    int? categoryId,
    bool? isActive,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      tenantId: tenantId ?? this.tenantId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'Product(id: $id, name: $name, price: $price, stock: $stock)';
}
