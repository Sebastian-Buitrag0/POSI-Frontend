import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/product_card.dart';
import '../providers/products_provider.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});

  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar por nombre o código...',
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
              onChanged: (value) =>
                  ref.read(productSearchQueryProvider.notifier).state = value,
            ),
          ),
        ),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) {
          if (products.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Sin productos',
              subtitle: _searchController.text.isNotEmpty
                  ? 'No hay resultados para "${_searchController.text}"'
                  : 'Agrega tu primer producto con el botón +',
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(productsStreamProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ProductCard(
                    product: product,
                    onTap: () => context.push(
                      AppRoutes.productDetail
                          .replaceAll(':id', '${product.id}'),
                    ),
                    onDelete: () => _confirmDelete(context, product.id, product.name),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'scan',
            onPressed: () => context.push(AppRoutes.scanner),
            tooltip: 'Escanear código',
            child: const Icon(Icons.qr_code_scanner),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add',
            onPressed: () => context.push(AppRoutes.productDetail.replaceAll(':id', 'new')),
            icon: const Icon(Icons.add),
            label: const Text('Producto'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "$name"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(productFormProvider.notifier).delete(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
