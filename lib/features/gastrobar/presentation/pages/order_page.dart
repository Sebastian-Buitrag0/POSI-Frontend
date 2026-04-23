import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../domain/entities/order_model.dart';
import '../providers/order_provider.dart';
import '../widgets/order_item_widget.dart';

class OrderPage extends ConsumerStatefulWidget {
  const OrderPage({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderAsync = ref.watch(orderProvider(widget.orderId));
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return orderAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Comanda')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (order) {
        return Scaffold(
          appBar: AppBar(
            title: Text('${order.tableName} — ${order.orderNumber}'),
            bottom: isPortrait
                ? TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(icon: Icon(Icons.menu_book), text: 'Productos'),
                      Tab(icon: Icon(Icons.receipt_long), text: 'Comanda'),
                    ],
                  )
                : null,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    ref.read(orderProvider(widget.orderId).notifier).refresh(),
              ),
            ],
          ),
          body: isPortrait
              ? TabBarView(
                  controller: _tabController,
                  children: [
                    _ProductsColumn(
                      onProductTap: (product) => _addProduct(product, order),
                    ),
                    _OrderColumn(
                      order: order,
                      orderId: widget.orderId,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _ProductsColumn(
                        onProductTap: (product) => _addProduct(product, order),
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: _OrderColumn(
                        order: order,
                        orderId: widget.orderId,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Future<void> _addProduct(Product product, OrderModel order) async {
    try {
      await ref.read(orderProvider(widget.orderId).notifier).addItem(
            product.remoteId ?? product.id.toString(),
            1,
            null,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} agregado'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _ProductsColumn extends ConsumerStatefulWidget {
  const _ProductsColumn({required this.onProductTap});

  final void Function(Product) onProductTap;

  @override
  ConsumerState<_ProductsColumn> createState() => _ProductsColumnState();
}

class _ProductsColumnState extends ConsumerState<_ProductsColumn> {
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
          padding: const EdgeInsets.all(12),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Buscar producto...',
            leading: const Icon(Icons.search),
            trailing: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(productSearchQueryProvider.notifier).state = '';
                  },
                ),
            ],
            onChanged: (v) =>
                ref.read(productSearchQueryProvider.notifier).state = v,
          ),
        ),
        Expanded(
          child: productsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (products) {
              final active = products.where((p) => p.isActive).toList();
              if (active.isEmpty) {
                return const Center(
                  child: Text('Sin productos activos'),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: active.length,
                itemBuilder: (_, i) {
                  final p = active[i];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => widget.onProductTap(p),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyFormatter.formatWithSymbol(p.price),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            if (p.stock <= 0)
                              const Text(
                                'Sin stock',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _OrderColumn extends ConsumerWidget {
  const _OrderColumn({required this.order, required this.orderId});

  final OrderModel order;
  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (order.pendingItems.isNotEmpty) ...[
                _SectionHeader(
                  label: 'Pendientes',
                  color: Colors.grey,
                  count: order.pendingItems.length,
                ),
                ...order.pendingItems.map((i) => OrderItemWidget(
                      item: i,
                      onCancel: () => ref
                          .read(orderProvider(orderId).notifier)
                          .cancelItem(i.id),
                    )),
              ],
              if (order.sentItems.isNotEmpty) ...[
                _SectionHeader(
                  label: 'En cocina',
                  color: Colors.orange,
                  count: order.sentItems.length,
                ),
                ...order.sentItems.map((i) => OrderItemWidget(item: i)),
              ],
              if (order.deliveredItems.isNotEmpty) ...[
                _SectionHeader(
                  label: 'Entregados',
                  color: Colors.green,
                  count: order.deliveredItems.length,
                ),
                ...order.deliveredItems.map((i) => OrderItemWidget(item: i)),
              ],
              if (order.items.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Sin items en la comanda'),
                  ),
                ),
            ],
          ),
        ),
        Container(
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
                  Text('TOTAL',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    CurrencyFormatter.formatWithSymbol(order.total),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (order.pendingItems.isNotEmpty)
                FilledButton.icon(
                  onPressed: () => _sendToKitchen(context, ref),
                  icon: const Icon(Icons.room_service),
                  label: const Text('Enviar a cocina'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              if (order.pendingItems.isNotEmpty) const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: order.items.isEmpty
                    ? null
                    : () => _showCloseOrderSheet(context, ref, order),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Pedir la cuenta'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _sendToKitchen(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(orderProvider(orderId).notifier).sendToKitchen();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enviado a cocina')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showCloseOrderSheet(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) {
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar mesa'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Total: ${CurrencyFormatter.formatWithSymbol(order.total)} — El cliente pagará en caja',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Notas (opcional)',
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(orderProvider(orderId).notifier)
                    .requestBill(notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cuenta enviada a caja')),
                  );
                  context.go(AppRoutes.gastrobarTables);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.check),
            label: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.color,
    required this.count,
  });

  final String label;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
