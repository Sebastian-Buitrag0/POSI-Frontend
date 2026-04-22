import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_client.dart';
import '../domain/entities/order_model.dart';
import '../domain/entities/table_model.dart';

class GastrobarRepository {
  GastrobarRepository(this._api);
  final ApiClient _api;

  Future<List<TableModel>> getTables() async {
    final res = await _api.get('/api/gastrobar/tables');
    return (res.data as List<dynamic>)
        .map((e) => TableModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TableModel> createTable(String name, int capacity) async {
    final res = await _api.post(
      '/api/gastrobar/tables',
      data: {'name': name, 'capacity': capacity},
    );
    return TableModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<OrderModel> openOrder(String tableId) async {
    final res = await _api.post('/api/gastrobar/tables/$tableId/orders');
    return OrderModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<OrderModel> getOrder(String orderId) async {
    final res = await _api.get('/api/gastrobar/orders/$orderId');
    return OrderModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<OrderModel> addItems(
    String orderId,
    List<Map<String, dynamic>> items,
  ) async {
    final res = await _api.post(
      '/api/gastrobar/orders/$orderId/items',
      data: {'items': items},
    );
    return OrderModel.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> updateItemStatus(
    String orderId,
    String itemId,
    String status,
  ) async {
    await _api.patch(
      '/api/gastrobar/orders/$orderId/items/$itemId/status',
      data: {'status': status},
    );
  }

  Future<String> closeOrder(
    String orderId,
    String paymentMethod,
    String? notes,
  ) async {
    final res = await _api.post(
      '/api/gastrobar/orders/$orderId/close',
      data: {'paymentMethod': paymentMethod, 'notes': notes},
    );
    return res.data['saleId'] as String;
  }

  Future<void> cancelOrder(String orderId) async {
    await _api.post('/api/gastrobar/orders/$orderId/cancel');
  }
}

final gastrobarRepositoryProvider = Provider<GastrobarRepository>(
  (ref) => GastrobarRepository(ref.read(apiClientProvider)),
);
