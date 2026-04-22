import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/gastrobar_repository.dart';
import '../../domain/entities/order_model.dart';

class OrderNotifier extends FamilyAsyncNotifier<OrderModel, String> {
  late final String _orderId;

  @override
  Future<OrderModel> build(String arg) async {
    _orderId = arg;
    return _fetch();
  }

  Future<OrderModel> _fetch() async {
    final repo = ref.read(gastrobarRepositoryProvider);
    return repo.getOrder(_orderId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> addItem(String productId, int qty, String? notes) async {
    final repo = ref.read(gastrobarRepositoryProvider);
    final current = state.valueOrNull;
    if (current == null) return;

    final item = {
      'productId': productId,
      'quantity': qty,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final updated = await repo.addItems(_orderId, [item]);
    state = AsyncData(updated);
  }

  Future<void> sendToKitchen() async {
    final repo = ref.read(gastrobarRepositoryProvider);
    final current = state.valueOrNull;
    if (current == null) return;

    final pending = current.items.where((i) => i.status == 'pending').toList();
    if (pending.isEmpty) return;

    for (final item in pending) {
      await repo.updateItemStatus(_orderId, item.id, 'sent');
    }

    state = await AsyncValue.guard(_fetch);
  }

  Future<String> closeOrder(String paymentMethod, String? notes) async {
    final repo = ref.read(gastrobarRepositoryProvider);
    final saleId = await repo.closeOrder(_orderId, paymentMethod, notes);
    state = await AsyncValue.guard(_fetch);
    return saleId;
  }

  Future<void> cancelOrder() async {
    final repo = ref.read(gastrobarRepositoryProvider);
    await repo.cancelOrder(_orderId);
    state = await AsyncValue.guard(_fetch);
  }
}

final orderProvider =
    AsyncNotifierProviderFamily<OrderNotifier, OrderModel, String>(
  OrderNotifier.new,
);
