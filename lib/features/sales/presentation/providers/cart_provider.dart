import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../../../products/domain/entities/product.dart';

class CartState {
  const CartState({
    this.items = const [],
    this.paymentMethod = PaymentMethod.cash,
    this.isProcessing = false,
  });

  final List<CartItem> items;
  final PaymentMethod paymentMethod;
  final bool isProcessing;

  double get subtotal => items.fold(0.0, (s, i) => s + i.subtotal);
  double get tax => subtotal * 0.16;
  double get total => subtotal + tax;
  int get itemCount => items.fold(0, (s, i) => s + i.quantity);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    PaymentMethod? paymentMethod,
    bool? isProcessing,
  }) => CartState(
    items: items ?? this.items,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    isProcessing: isProcessing ?? this.isProcessing,
  );
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(Product product) {
    if (!product.isActive || product.stock <= 0) return;

    final existing = state.items.where((i) => i.productId == product.id).firstOrNull;
    if (existing != null) {
      if (existing.quantity >= product.stock) return;
      final updated = state.items.map((i) =>
        i.productId == product.id
          ? i.copyWith(quantity: i.quantity + 1)
          : i,
      ).toList();
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(
            productId: product.id,
            productName: product.name,
            unitPrice: product.price,
            quantity: 1,
            maxStock: product.stock,
          ),
        ],
      );
    }
  }

  void removeItem(int productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );
  }

  void updateQuantity(int productId, int newQty) {
    if (newQty <= 0) {
      removeItem(productId);
      return;
    }
    state = state.copyWith(
      items: state.items.map((i) {
        if (i.productId != productId) return i;
        final clamped = newQty.clamp(1, i.maxStock);
        return i.copyWith(quantity: clamped);
      }).toList(),
    );
  }

  void setPaymentMethod(PaymentMethod method) =>
      state = state.copyWith(paymentMethod: method);

  void clearCart() => state = const CartState();
}
