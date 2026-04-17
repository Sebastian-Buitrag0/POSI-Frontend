import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/sync_mixin.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/product_repository_provider.dart';
import '../../domain/entities/product.dart';

// Query de búsqueda actual
final productSearchQueryProvider = StateProvider<String>((ref) => '');

// Stream reactivo — se actualiza solo cuando cambia la DB
final productsStreamProvider = StreamProvider<List<Product>>((ref) {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return const Stream.empty();

  final query = ref.watch(productSearchQueryProvider);
  final repo = ref.watch(productRepositoryProvider);

  if (query.trim().isEmpty) {
    return repo.watchAll(auth.user.tenantId);
  }
  return repo.watchSearch(query.trim(), auth.user.tenantId);
});

// Estado para operaciones CRUD (crear/editar/eliminar)
sealed class ProductFormState {
  const ProductFormState();
}

class ProductFormIdle extends ProductFormState {
  const ProductFormIdle();
}

class ProductFormLoading extends ProductFormState {
  const ProductFormLoading();
}

class ProductFormSuccess extends ProductFormState {
  const ProductFormSuccess(this.product);
  final Product product;
}

class ProductFormError extends ProductFormState {
  const ProductFormError(this.message);
  final String message;
}

final productFormProvider =
    StateNotifierProvider.autoDispose<ProductFormNotifier, ProductFormState>(
        (ref) {
  return ProductFormNotifier(ref);
});

class ProductFormNotifier extends StateNotifier<ProductFormState> {
  ProductFormNotifier(this._ref) : super(const ProductFormIdle());

  final Ref _ref;

  Future<void> save({
    required String name,
    required double price,
    required int stock,
    required String tenantId,
    int? id,
    String? barcode,
    String? sku,
    double? cost,
    int? categoryId,
    bool isActive = true,
  }) async {
    state = const ProductFormLoading();
    try {
      final repo = _ref.read(productRepositoryProvider);
      final now = DateTime.now();

      final product = Product(
        id: id ?? 0,
        name: name,
        price: price,
        stock: stock,
        tenantId: tenantId,
        barcode: barcode,
        sku: sku,
        cost: cost,
        categoryId: categoryId,
        isActive: isActive,
        syncStatus: SyncStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      if (id != null) {
        await repo.update(product);
      } else {
        await repo.create(product);
      }
      state = ProductFormSuccess(product);
    } on Exception catch (e) {
      state = ProductFormError(e.toString());
    }
  }

  Future<void> delete(int id) async {
    state = const ProductFormLoading();
    try {
      await _ref.read(productRepositoryProvider).delete(id);
      state = const ProductFormIdle();
    } on Exception catch (e) {
      state = ProductFormError(e.toString());
    }
  }
}
