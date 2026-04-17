import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/data/repositories/product_repository_provider.dart';

sealed class ScannerState {
  const ScannerState();
}

class ScannerIdle extends ScannerState {
  const ScannerIdle();
}

class ScannerScanning extends ScannerState {
  const ScannerScanning();
}

class ScannerSearching extends ScannerState {
  const ScannerSearching(this.barcode);
  final String barcode;
}

class ScannerProductFound extends ScannerState {
  const ScannerProductFound(this.barcode, this.productId);
  final String barcode;
  final int productId;
}

class ScannerProductNotFound extends ScannerState {
  const ScannerProductNotFound(this.barcode);
  final String barcode;
}

class ScannerError extends ScannerState {
  const ScannerError(this.message);
  final String message;
}

final scannerProvider =
    StateNotifierProvider.autoDispose<ScannerNotifier, ScannerState>(
  (ref) => ScannerNotifier(ref),
);

class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier(this._ref) : super(const ScannerIdle());
  final Ref _ref;

  void startScanning() => state = const ScannerScanning();

  void stopScanning() => state = const ScannerIdle();

  Future<void> handleBarcode(String rawValue) async {
    if (state is ScannerSearching) return;
    HapticFeedback.mediumImpact();
    state = ScannerSearching(rawValue);
    try {
      final auth = _ref.read(authProvider);
      if (auth is! AuthAuthenticated) {
        state = const ScannerError('No autenticado');
        return;
      }
      final repo = _ref.read(productRepositoryProvider);
      final product = await repo.getByBarcode(rawValue, auth.user.tenantId);
      if (product != null) {
        state = ScannerProductFound(rawValue, product.id);
      } else {
        state = ScannerProductNotFound(rawValue);
      }
    } catch (e) {
      state = ScannerError(e.toString());
    }
  }

  void reset() => state = const ScannerScanning();
}
