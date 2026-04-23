import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/sale.dart';
import '../../data/repositories/sales_repository_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../gastrobar/data/repositories/gastrobar_local_repository.dart';
import 'cart_provider.dart';

sealed class CheckoutState { const CheckoutState(); }
class CheckoutIdle extends CheckoutState { const CheckoutIdle(); }
class CheckoutProcessing extends CheckoutState { const CheckoutProcessing(); }
class CheckoutSuccess extends CheckoutState {
  const CheckoutSuccess(this.sale);
  final Sale sale;
}
class CheckoutError extends CheckoutState {
  const CheckoutError(this.message);
  final String message;
}

final checkoutProvider =
    StateNotifierProvider.autoDispose<CheckoutNotifier, CheckoutState>(
  (ref) => CheckoutNotifier(ref),
);

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier(this._ref) : super(const CheckoutIdle());

  final Ref _ref;

  Future<void> processCheckout() async {
    final cart = _ref.read(cartProvider);
    if (cart.isEmpty) {
      state = const CheckoutError('El carrito está vacío');
      return;
    }

    final auth = _ref.read(authProvider);
    if (auth is! AuthAuthenticated) {
      state = const CheckoutError('No autenticado');
      return;
    }

    state = const CheckoutProcessing();
    try {
      final repo = _ref.read(salesRepositoryProvider);
      final gastrobarOrderId = cart.gastrobarOrderId;
      final sale = await repo.completeSale(
        items: cart.items,
        paymentMethod: cart.paymentMethod,
        tenantId: auth.user.tenantId,
      );
      if (gastrobarOrderId != null) {
        final gastrobarRepo = _ref.read(gastrobarLocalRepositoryProvider);
        await gastrobarRepo.markOrderPaid(gastrobarOrderId);
      }
      _ref.read(cartProvider.notifier).clearCart();
      state = CheckoutSuccess(sale);
    } on Exception catch (e) {
      state = CheckoutError(e.toString());
    }
  }

  void reset() => state = const CheckoutIdle();
}
