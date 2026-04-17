import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = (ref.watch(authProvider) as AuthAuthenticated?)?.user;
    final sync = ref.watch(syncProvider);

    String syncLabel;
    if (sync.isSyncing) {
      syncLabel = 'Sincronizando...';
    } else if (sync.lastSyncAt != null) {
      final diff = DateTime.now().difference(sync.lastSyncAt!);
      if (diff.inMinutes < 1) {
        syncLabel = 'Última sync: hace un momento';
      } else if (diff.inHours < 1) {
        syncLabel = 'Última sync: hace ${diff.inMinutes} min';
      } else {
        syncLabel = 'Última sync: hace ${diff.inHours} h';
      }
    } else {
      syncLabel = 'Sin sincronizar';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    user?.firstName.isNotEmpty == true
                        ? user!.firstName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName ?? '',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      Text(
                        user?.role ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: sync.isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    sync.lastSyncAt != null ? Icons.cloud_done : Icons.cloud_off,
                    color: sync.lastSyncAt != null
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
            title: const Text('Sincronización'),
            subtitle: Text(syncLabel),
            trailing: TextButton(
              onPressed: sync.isSyncing
                  ? null
                  : () => ref.read(syncProvider.notifier).syncNow(),
              child: const Text('Sincronizar ahora'),
            ),
          ),
          if (sync.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                sync.error!,
                style: const TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
          if (user?.isAdmin == true) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.group_outlined, color: AppColors.primary),
              title: const Text('Gestión de equipo'),
              subtitle: const Text('Invitar y administrar usuarios'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoutes.userManagement),
            ),
          ],
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Cerrar sesión',
                style: TextStyle(color: AppColors.error)),
            onTap: () async {
              await ref.read(authProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}
