class TableModel {
  final String id;
  final String name;
  final int capacity;
  final String status; // available | occupied | reserved
  final bool isActive;
  final int activeOrderItemCount;

  const TableModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.status,
    required this.isActive,
    required this.activeOrderItemCount,
  });

  bool get isAvailable => status == 'available';
  bool get isOccupied => status == 'occupied';

  factory TableModel.fromJson(Map<String, dynamic> json) => TableModel(
    id: json['id'] as String,
    name: json['name'] as String,
    capacity: json['capacity'] as int,
    status: json['status'] as String,
    isActive: json['isActive'] as bool,
    activeOrderItemCount: json['activeOrderItemCount'] as int,
  );
}
