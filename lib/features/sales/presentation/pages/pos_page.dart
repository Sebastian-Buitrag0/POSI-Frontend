import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/payment_method_selector.dart';
import '../../../../shared/widgets/receipt_widget.dart';
import '../../domain/entities/sale.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../../../products/presentation/providers/products_provider.dart';

class PosPage extends ConsumerStatefulWidget {
  const PosPage({super.key});

  @override
  ConsumerState<PosPage> createState() => _PosPageState();
}

class _PosPageState extends ConsumerState<PosPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final checkout = ref.watch(checkoutProvider);

    ref.listen(checkoutProvider, (_, next) {
      if (next is CheckoutSuccess) {
        _showReceipt(context, next.sale);
      }
      if (next is CheckoutError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final isProcessing = checkout is CheckoutProcessing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Venta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Escanear',
            onPressed: () => context.push(AppRoutes.scanner),
          ),
          if (!cart.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Vaciar carrito',
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? _EmptyCart(onAddProduct: () => _showProductPicker(context))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) => CartItemWidget(item: cart.items[i]),
                  ),
          ),
          _CheckoutPanel(cart: cart, isProcessing: isProcessing),
        ],
      ),
      floatingActionButton: cart.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showProductPicker(context),
              icon: const Icon(Icons.add),
              label: const Text('Agregar producto'),
            )
          : FloatingActionButton(
              onPressed: () => _showProductPicker(context),
              child: const Icon(Icons.add),
            ),
    );
  }

  void _showProductPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ProductPickerSheet(),
    );
  }

  void _showReceipt(BuildContext context, Sale sale) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => ReceiptWidget(
        sale: sale,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text('Eliminar todos los productos del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(cartProvider.notifier).clearCart();
            },
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }
}

class _CheckoutPanel extends ConsumerWidget {
  const _CheckoutPanel({required this.cart, required this.isProcessing});

  final CartState cart;
  final bool isProcessing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: theme.textTheme.bodyMedium),
              Text(CurrencyFormatter.format(cart.subtotal),
                  style: theme.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('IVA 16%',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey)),
              Text(CurrencyFormatter.format(cart.tax),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                CurrencyFormatter.format(cart.total),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PaymentMethodSelector(
            selected: cart.paymentMethod,
            onChanged: (m) =>
                ref.read(cartProvider.notifier).setPaymentMethod(m),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: cart.isEmpty || isProcessing
                ? null
                : () => ref.read(checkoutProvider.notifier).processCheckout(),
            icon: isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.point_of_sale),
            label: Text(
              isProcessing ? 'Procesando...' : 'COBRAR ${CurrencyFormatter.format(cart.total)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onAddProduct});

  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Carrito vacio',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onAddProduct,
            icon: const Icon(Icons.add),
            label: const Text('Agregar producto'),
          ),
        ],
      ),
    );
  }
}

class _ProductPickerSheet extends ConsumerStatefulWidget {
  const _ProductPickerSheet();

  @override
  ConsumerState<_ProductPickerSheet> createState() =>
      _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<_ProductPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    ref.read(productSearchQueryProvider.notifier).state = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar producto...',
              leading: const Icon(Icons.search),
              onChanged: (v) =>
                  ref.read(productSearchQueryProvider.notifier).state = v,
            ),
          ),
          Expanded(
            child: productsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (products) => ListView.builder(
                controller: scrollController,
                itemCount: products.length,
                itemBuilder: (_, i) {
                  final p = products[i];
                  final inCart = ref
                      .read(cartProvider)
                      .items
                      .any((ci) => ci.productId == p.id);
                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text('${CurrencyFormatter.format(p.price)} — Stock: ${p.stock}'),
                    trailing: p.stock > 0
                        ? IconButton(
                            icon: Icon(
                              inCart
                                  ? Icons.add_circle
                                  : Icons.add_circle_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              ref.read(cartProvider.notifier).addItem(p);
                            },
                          )
                        : const Chip(label: Text('Sin stock')),
                    enabled: p.stock > 0 && p.isActive,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
