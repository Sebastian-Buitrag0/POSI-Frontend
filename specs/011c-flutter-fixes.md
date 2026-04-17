# Spec 011-C — Flutter: Fixes críticos de UI

## Objetivo
Cuatro fixes que bloquean el uso real del app:
1. `syncProvider` nunca se inicializa → el auto-sync nunca corre
2. `_HomePage` es solo "Bienvenido" → no hay navegación al resto del app
3. No existe `SettingsPage` → ruta `/settings` rompe
4. No hay indicador visual de sync → el usuario no sabe si está online/offline

## Infraestructura existente
- `syncProvider` en `lib/core/providers/sync_provider.dart` — `SyncState { isSyncing, lastSyncAt, error }`
- `authProvider` — `AuthAuthenticated(user)` con `user.firstName`, `user.tenantId`
- `AppRoutes`: home, products, pos, salesHistory, cashRegister, settings, scanner
- `AppColors`: primary, secondary, accent, error, success, textSecondary
- `main.dart`: `_HomePage` y `POSIApp` están inline en el mismo archivo

---

## Task 11-C.0 — Inicializar syncProvider en POSIApp

En `lib/main.dart`, en el método `build` de `POSIApp`, agregar ANTES del `GoRouter`:

```dart
// Inicializa el listener de conectividad
ref.watch(syncProvider);
```

Agregar el import necesario:
```dart
import 'core/providers/sync_provider.dart';
```

---

## Task 11-C.1 — Reemplazar _HomePage con Home real

Reemplazar la clase `_HomePage` en `lib/main.dart` con:

```dart
class _HomePage extends ConsumerWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = (ref.watch(authProvider) as AuthAuthenticated?)?.user;
    final sync = ref.watch(syncProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('POSI'),
        actions: [
          // Indicador de sync
          if (sync.isSyncing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                sync.lastSyncAt != null ? Icons.cloud_done : Icons.cloud_off,
                color: sync.lastSyncAt != null
                    ? AppColors.success
                    : AppColors.textSecondary,
                size: 22,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.go(AppRoutes.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${user?.firstName ?? ''}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.role ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _MenuCard(
                    icon: Icons.point_of_sale,
                    label: 'Punto de Venta',
                    color: AppColors.primary,
                    onTap: () => context.go(AppRoutes.pos),
                  ),
                  _MenuCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Productos',
                    color: AppColors.secondary,
                    onTap: () => context.go(AppRoutes.products),
                  ),
                  _MenuCard(
                    icon: Icons.receipt_long_outlined,
                    label: 'Historial',
                    color: AppColors.accent,
                    onTap: () => context.go(AppRoutes.salesHistory),
                  ),
                  _MenuCard(
                    icon: Icons.store_outlined,
                    label: 'Caja',
                    color: AppColors.info,
                    onTap: () => context.go(AppRoutes.cashRegister),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Task 11-C.2 — Crear SettingsPage

Crear `lib/features/settings/presentation/pages/settings_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
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
        leading: BackButton(onPressed: () => context.go('/home')),
      ),
      body: ListView(
        children: [
          // Perfil
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

          // Sync
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
          const Divider(),

          // Logout
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
```

---

## Task 11-C.3 — Registrar SettingsPage en el router

En `lib/main.dart`:

1. Agregar import:
```dart
import 'features/settings/presentation/pages/settings_page.dart';
```

2. Agregar ruta en el array `routes` del GoRouter (después de cashRegister):
```dart
GoRoute(
  path: AppRoutes.settings,
  builder: (_, _) => const SettingsPage(),
),
```

---

## Task 11-C.4 — Validación

```bash
cd /Users/sebastian-buitrago/Documents/Yo/POSI/POSI-Frontend
fvm flutter analyze
```

**0 errores.**

---

## Archivos a modificar
```
lib/main.dart   ← Tasks 11-C.0, 11-C.1, 11-C.3
```

## Archivos a crear
```
lib/features/settings/presentation/pages/settings_page.dart   ← Task 11-C.2
```

## IMPORTANTE — No hacer
- NO crear providers adicionales para settings
- NO usar `withOpacity` — usar `withValues(alpha: ...)` (Flutter 3.x deprecó withOpacity)
- El builder del GoRoute de settings usa `(_, _)` igual que scanner y otros
- NO modificar tablas Drift ni ejecutar build_runner
