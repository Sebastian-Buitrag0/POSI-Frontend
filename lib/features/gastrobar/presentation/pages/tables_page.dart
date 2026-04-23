import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/sync_mixin.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/tables_provider.dart';

class TablesPage extends ConsumerWidget {
  const TablesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesAsync = ref.watch(tablesProvider);
    final user = (ref.watch(authProvider) as AuthAuthenticated?)?.user;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        WidgetsBinding.instance.addPostFrameCallback((_) => context.go(AppRoutes.home));
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Mesas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.kitchen),
            tooltip: 'Cocina',
            onPressed: () => context.push(AppRoutes.gastrobarKitchen),
          ),
          if (user?.isAdmin == true || user?.isManager == true)
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
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: tables.length,
              itemBuilder: (_, index) => _TableCard(
                table: tables[index],
                onTap: () => _onTableTap(context, ref, tables[index]),
                onLongPress: (user?.isAdmin == true || user?.isManager == true)
                    ? () => _confirmDeleteTable(context, ref, tables[index])
                    : null,
              ),
            ),
          );
        },
      ),
      floatingActionButton: user?.isAdmin == true || user?.isManager == true
          ? FloatingActionButton(
              onPressed: () => _showCreateTableSheet(context, ref),
              child: const Icon(Icons.add),
            )
          : null,
      ),
    );
  }

  Future<void> _onTableTap(
    BuildContext context,
    WidgetRef ref,
    MesasTableData table,
  ) async {
    final isOccupied = table.status == 'occupied';

    if (isOccupied) {
      try {
        final orderId =
            await ref.read(tablesProvider.notifier).openOrder(table.id.toString());
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

    if (table.status != 'available') return;

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
            await ref.read(tablesProvider.notifier).openOrder(table.id.toString());
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva mesa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                hintText: 'Mesa 1',
              ),
              textCapitalization: TextCapitalization.sentences,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: capacityCtrl,
              decoration: const InputDecoration(labelText: 'Capacidad'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final capacity = int.tryParse(capacityCtrl.text.trim()) ?? 4;
              if (name.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await ref.read(tablesProvider.notifier).createTable(name, capacity);
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
        ],
      ),
    );
  }

  void _confirmDeleteTable(BuildContext context, WidgetRef ref, MesasTableData table) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar mesa'),
        content: Text('¿Eliminar "${table.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(tablesProvider.notifier).deleteTable(table.id, table.remoteId);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.table, required this.onTap, this.onLongPress});

  final MesasTableData table;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = switch (table.status) {
      'available' => Colors.green,
      'occupied' => Colors.deepOrange,
      'reserved' => Colors.blueGrey,
      _ => Colors.blueGrey,
    };
    final statusLabel = switch (table.status) {
      'available' => 'Disponible',
      'occupied' => 'Ocupada',
      'reserved' => 'Reservada',
      _ => table.status,
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.table_restaurant, size: 40, color: color),
                  const SizedBox(height: 12),
                  Text(
                    table.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (table.syncStatus == SyncStatus.pending)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.cloud_off_outlined,
                  size: 14,
                  color: color.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
