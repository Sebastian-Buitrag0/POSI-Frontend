import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/payment_method_selector.dart';
import '../../../../shared/widgets/receipt_widget.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/data/repositories/product_repository_provider.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../domain/entities/sale.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../../../cash-register/presentation/providers/cash_register_provider.dart';
import '../../../gastrobar/data/daos/gastrobar_dao.dart' show PendingPaymentOrder;
import '../../../gastrobar/data/repositories/gastrobar_local_repository.dart';
import '../../../gastrobar/presentation/providers/pending_orders_provider.dart';

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
          _PendingTablesButton(onSelected: (order, items) {
            ref.read(cartProvider.notifier).loadGastrobarOrder(
              comandaLocalId: order.comandaLocalId,
              tableName: order.tableName,
              items: items,
            );
          }),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Escanear',
            onPressed: () => _scanToCart(context),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar producto',
            onPressed: () => _showProductPicker(context),
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
          if (cart.gastrobarTableName != null)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.primaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.table_restaurant,
                      size: 16,
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cuenta de ${cart.gastrobarTableName}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: cart.isEmpty
                ? _EmptyCart(
                    onScan: () => _scanToCart(context),
                    onSearch: () => _showProductPicker(context),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) => CartItemWidget(item: cart.items[i]),
                  ),
          ),
          _CheckoutPanel(cart: cart, isProcessing: isProcessing),
        ],
      ),
      floatingActionButton: null,
    );
  }

  Future<void> _scanToCart(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) return;
    final repo = ref.read(productRepositoryProvider);

    Future<String?> nameResolver(String barcode) async {
      final product = await repo.getByBarcode(barcode, auth.user.tenantId);
      return product?.name;
    }

    final barcodes = await context.push<List<String>>(
      AppRoutes.scannerPicker,
      extra: nameResolver,
    );
    if (barcodes == null || barcodes.isEmpty || !mounted) return;

    int added = 0;
    final List<String> notFound = [];

    for (final barcode in barcodes) {
      final product = await repo.getByBarcode(barcode, auth.user.tenantId);
      if (!mounted) return;
      if (product == null) {
        if (!notFound.contains(barcode)) notFound.add(barcode);
      } else {
        ref.read(cartProvider.notifier).addItem(product);
        added++;
      }
    }

    if (added > 0) {
      messenger.showSnackBar(SnackBar(
        content: Text(
            '$added producto${added == 1 ? '' : 's'} agregado${added == 1 ? '' : 's'} al carrito'),
        duration: const Duration(seconds: 2),
      ));
    }
    for (final barcode in notFound) {
      messenger.showSnackBar(SnackBar(
        content: Text('Producto "$barcode" no encontrado'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _showProductPicker(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Buscar producto'),
        content: const SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _ProductPickerSheet(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showReceipt(BuildContext context, Sale sale) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ReceiptWidget(
          sale: sale,
          onClose: () => Navigator.of(ctx).pop(),
        ),
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
    final cashRegister = ref.watch(cashRegisterProvider);
    final isCashOpen = cashRegister.isOpen;

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
          if (!isCashOpen)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: Colors.orange.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Caja cerrada — abre la caja para vender',
                      style: TextStyle(color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
          FilledButton.icon(
            onPressed: cart.isEmpty || isProcessing || !isCashOpen
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
  const _EmptyCart({required this.onScan, required this.onSearch});

  final VoidCallback onScan;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Carrito vacío',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Escanear productos'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onSearch,
            icon: const Icon(Icons.search),
            label: const Text('Buscar producto'),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (products) => ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, i) {
                final p = products[i];
                final inCart = ref
                    .read(cartProvider)
                    .items
                    .any((ci) => ci.productId == p.id);
                return ListTile(
                  title: Text(p.name),
                  subtitle: Text(
                      '${CurrencyFormatter.format(p.price)} — Stock: ${p.stock}'),
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
    );
  }
}

class _PendingTablesButton extends ConsumerWidget {
  const _PendingTablesButton({required this.onSelected});

  final void Function(
    PendingPaymentOrder order,
    List<({int itemId, String productName, double unitPrice, int quantity})> items,
  ) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingPaymentOrdersProvider);
    final count = pendingAsync.valueOrNull?.length ?? 0;

    if (count == 0) return const SizedBox.shrink();

    return Stack(
      alignment: Alignment.topRight,
      children: [
        IconButton(
          icon: const Icon(Icons.table_restaurant),
          tooltip: 'Cuentas de mesa',
          onPressed: () => _showDialog(context, ref),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDialog(BuildContext context, WidgetRef ref) {
    final orders = ref.read(pendingPaymentOrdersProvider).valueOrNull ?? [];

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cuentas pendientes de mesa'),
        content: SizedBox(
          width: double.maxFinite,
          child: orders.isEmpty
              ? const Text('Sin cuentas pendientes')
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: orders.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final order = orders[i];
                    return ListTile(
                      leading: const Icon(Icons.table_restaurant),
                      title: Text(order.tableName),
                      subtitle: Text(order.orderNumber),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        Navigator.pop(ctx);
                        final repo = ref.read(gastrobarLocalRepositoryProvider);
                        final rawItems = await repo.getItemsByOrder(order.comandaLocalId);
                        final items = rawItems
                            .where((i) => i.itemStatus != 'cancelled')
                            .map((i) => (
                                  itemId: i.id,
                                  productName: i.productName,
                                  unitPrice: i.unitPrice,
                                  quantity: i.quantity,
                                ))
                            .toList();
                        onSelected(order, items);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
