import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/table_model.dart';
import '../providers/tables_provider.dart';

class TablesPage extends ConsumerWidget {
  const TablesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(tablesProvider);
    final user = (ref.watch(authProvider) as AuthAuthenticated?)?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesas'),
        actions: [
          if (user?.isAdmin == true)
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Crear mesa',
              onPressed: () => _showCreateTableSheet(context, ref),
            ),
        ],
      ),
      body: tablesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tables) {
          if (tables.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.table_restaurant_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Sin mesas',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(tablesProvider.notifier).refresh(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: tables.length,
              itemBuilder: (_, index) => _TableCard(
                table: tables[index],
                onTap: () => _onTableTap(context, ref, tables[index]),
              ),
            ),
          );
        },
      ),
      floatingActionButton: user?.isAdmin == true
          ? FloatingActionButton(
              onPressed: () => _showCreateTableSheet(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Future<void> _onTableTap(
    BuildContext context,
    WidgetRef ref,
    TableModel table,
  ) async {
    if (table.isOccupied) {
      // Navigate to active order
      // In a real app, we'd have the orderId. For now, we open a new order
      // and let the backend handle it, or we'd need an endpoint to get active order.
      // The spec says "navega a OrderPage de la orden activa".
      // Since we don't have the orderId directly, we'll try to open order
      // which should return the existing one if occupied.
      try {
        final orderId =
            await ref.read(tablesProvider.notifier).openOrder(table.id);
        if (context.mounted) {
          context.push(AppRoutes.gastrobarOrder.replaceAll(':orderId', orderId));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
      return;
    }

    if (!table.isAvailable) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Abrir comanda en ${table.name}'),
        content: Text('¿Deseas abrir una nueva comanda en ${table.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Abrir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final orderId =
            await ref.read(tablesProvider.notifier).openOrder(table.id);
        if (context.mounted) {
          context.push(AppRoutes.gastrobarOrder.replaceAll(':orderId', orderId));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _showCreateTableSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final capacityCtrl = TextEditingController(text: '4');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Nueva mesa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Mesa 1',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: capacityCtrl,
              decoration: const InputDecoration(
                labelText: 'Capacidad',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final capacity = int.tryParse(capacityCtrl.text.trim()) ?? 4;
                if (name.isEmpty) return;
                Navigator.pop(context);
                try {
                  await ref
                      .read(tablesProvider.notifier)
                      .createTable(name, capacity);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Crear'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.table, required this.onTap});

  final TableModel table;
  final VoidCallback onTap;

  Color get _bgColor {
    return switch (table.status) {
      'available' => Colors.green.shade50,
      'occupied' => Colors.orange.shade50,
      'reserved' => Colors.grey.shade100,
      _ => Colors.grey.shade100,
    };
  }

  Color get _borderColor {
    return switch (table.status) {
      'available' => Colors.green,
      'occupied' => Colors.orange,
      'reserved' => Colors.grey,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: _borderColor.withValues(alpha: 0.3)),
      ),
      color: _bgColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.table_restaurant,
                    size: 32,
                    color: _borderColor,
                  ),
                  if (table.isOccupied && table.activeOrderItemCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${table.activeOrderItemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Text(
                table.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Cap: ${table.capacity}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _borderColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  table.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _borderColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
