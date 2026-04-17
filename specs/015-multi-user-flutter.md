# Spec 015-B — Multi-usuario + Roles (Flutter)

## Objetivo
- Pantalla de gestión de equipo: ver usuarios, invitar, cambiar rol, eliminar
- Solo visible si `user.isAdmin`
- Accesible desde `SettingsPage`

## Infraestructura existente
- `authProvider` → `AuthAuthenticated(user)` donde `user.isAdmin` = `role == 'Admin'`
- `ApiClient.get()`, `.post()`, `.delete()` (falta `delete` — hay que agregarlo)
- `AppColors`, `AppRoutes`, `GoRouter` en main.dart
- `SettingsPage` ya tiene `ListView` con tiles

---

## Task 15.0 — Agregar delete y put a ApiClient

En `lib/core/services/api_client.dart`, agregar al final de la clase:

```dart
Future<Response> put(String path, {Object? data}) =>
    _dio.put(path, data: data);

Future<Response> delete(String path) =>
    _dio.delete(path);
```

Y agregar constantes en `lib/core/constants/api_constants.dart`:
```dart
  // Users
  static const String users = '/api/users';
  static const String usersInvite = '/api/users/invite';
```

---

## Task 15.1 — TenantUser entity + UsersProvider

### `lib/features/users/presentation/providers/users_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_client.dart';

class TenantUser {
  const TenantUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime createdAt;

  String get fullName => '$firstName $lastName';

  factory TenantUser.fromJson(Map<String, dynamic> json) => TenantUser(
        id: json['id'] as String,
        email: json['email'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        role: json['role'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

// ── State ──────────────────────────────────────────────────────────────────

sealed class UsersState {
  const UsersState();
}

class UsersLoading extends UsersState {
  const UsersLoading();
}

class UsersLoaded extends UsersState {
  const UsersLoaded(this.users);
  final List<TenantUser> users;
}

class UsersError extends UsersState {
  const UsersError(this.message);
  final String message;
}

// ── Provider ───────────────────────────────────────────────────────────────

final usersProvider =
    StateNotifierProvider.autoDispose<UsersNotifier, UsersState>((ref) {
  return UsersNotifier(ref.watch(apiClientProvider));
});

// ── Notifier ───────────────────────────────────────────────────────────────

class UsersNotifier extends StateNotifier<UsersState> {
  UsersNotifier(this._api) : super(const UsersLoading()) {
    load();
  }

  final ApiClient _api;

  Future<void> load() async {
    state = const UsersLoading();
    try {
      final response = await _api.get(ApiConstants.users);
      final list = (response.data as List).cast<Map<String, dynamic>>();
      state = UsersLoaded(list.map(TenantUser.fromJson).toList());
    } on Exception catch (e) {
      state = UsersError(e.toString());
    }
  }

  Future<String?> invite({
    required String email,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    try {
      await _api.post(ApiConstants.usersInvite, data: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
      });
      await load();
      return null; // null = success
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateRole(String userId, String newRole) async {
    try {
      await _api.put('${ApiConstants.users}/$userId/role', data: {'role': newRole});
      await load();
      return null;
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future<String?> remove(String userId) async {
    try {
      await _api.delete('${ApiConstants.users}/$userId');
      await load();
      return null;
    } on Exception catch (e) {
      return e.toString();
    }
  }
}
```

---

## Task 15.2 — UserManagementPage

### `lib/features/users/presentation/pages/user_management_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/users_provider.dart';

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equipo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(usersProvider.notifier).load(),
          ),
        ],
      ),
      body: switch (state) {
        UsersLoading() => const Center(child: CircularProgressIndicator()),
        UsersError(:final message) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                const SizedBox(height: 8),
                Text(message),
                TextButton(
                  onPressed: () => ref.read(usersProvider.notifier).load(),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        UsersLoaded(:final users) => users.isEmpty
            ? const Center(child: Text('No hay usuarios en el equipo.'))
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _UserTile(user: users[i]),
              ),
      },
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showInviteDialog(context, ref),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Invitar'),
      ),
    );
  }

  void _showInviteDialog(BuildContext context, WidgetRef ref) {
    final emailCtrl = TextEditingController();
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    String selectedRole = 'Cashier';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Invitar usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Correo electrónico'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: firstNameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: lastNameCtrl,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: const [
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                    DropdownMenuItem(value: 'Cashier', child: Text('Cajero')),
                  ],
                  onChanged: (v) => setState(() => selectedRole = v ?? 'Cashier'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final error = await ref.read(usersProvider.notifier).invite(
                      email: emailCtrl.text.trim(),
                      firstName: firstNameCtrl.text.trim(),
                      lastName: lastNameCtrl.text.trim(),
                      role: selectedRole,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error == null
                          ? 'Invitación enviada a ${emailCtrl.text.trim()}'
                          : 'Error: $error'),
                      backgroundColor:
                          error == null ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Invitar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends ConsumerWidget {
  const _UserTile({required this.user});
  final TenantUser user;

  Color _roleColor(String role) => switch (role) {
        'Admin' => AppColors.primary,
        'Manager' => AppColors.secondary,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _roleColor(user.role).withValues(alpha: 0.1),
          child: Text(
            user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
            style: TextStyle(
                color: _roleColor(user.role), fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(user.fullName,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(user.email,
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: Chip(
          label: Text(user.role,
              style: TextStyle(
                  fontSize: 11,
                  color: _roleColor(user.role),
                  fontWeight: FontWeight.w600)),
          backgroundColor: _roleColor(user.role).withValues(alpha: 0.1),
          side: BorderSide.none,
          padding: EdgeInsets.zero,
        ),
        onLongPress: () => _showOptions(context, ref),
      ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Cambiar rol'),
              onTap: () {
                Navigator.pop(context);
                _showRoleDialog(context, ref);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove_outlined, color: AppColors.error),
              title: const Text('Eliminar usuario',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRoleDialog(BuildContext context, WidgetRef ref) {
    String selectedRole = user.role;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Rol de ${user.firstName}'),
          content: DropdownButtonFormField<String>(
            value: selectedRole,
            decoration: const InputDecoration(labelText: 'Rol'),
            items: const [
              DropdownMenuItem(value: 'Admin', child: Text('Admin')),
              DropdownMenuItem(value: 'Manager', child: Text('Manager')),
              DropdownMenuItem(value: 'Cashier', child: Text('Cajero')),
            ],
            onChanged: (v) => setState(() => selectedRole = v ?? user.role),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(usersProvider.notifier).updateRole(user.id, selectedRole);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Eliminar a ${user.fullName}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final error = await ref.read(usersProvider.notifier).remove(user.id);
              if (context.mounted && error != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: $error'),
                      backgroundColor: AppColors.error),
                );
              }
            },
            child: const Text('Eliminar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
```

---

## Task 15.3 — Agregar tile en SettingsPage + nueva ruta

### En `lib/features/settings/presentation/pages/settings_page.dart`

Agregar import:
```dart
import '../../../../core/constants/app_routes.dart';
```

Agregar tile de "Gestión de equipo" en el `ListView`, después del tile de sync y antes del Divider de logout:
```dart
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
```

### En `lib/core/constants/app_routes.dart`, agregar:
```dart
static const String userManagement = '/users';
```

### En `lib/main.dart`, agregar import y ruta:

Import:
```dart
import 'features/users/presentation/pages/user_management_page.dart';
```

Ruta (después de la ruta de settings):
```dart
GoRoute(
  path: AppRoutes.userManagement,
  builder: (_, _) => const UserManagementPage(),
),
```

---

## Task 15.4 — Validación

```bash
cd /Users/sebastian-buitrago/Documents/Yo/POSI/POSI-Frontend
fvm flutter analyze
```

**0 errores.**

---

## Archivos a crear
```
lib/features/users/presentation/providers/users_provider.dart  ← Task 15.1
lib/features/users/presentation/pages/user_management_page.dart ← Task 15.2
```

## Archivos a modificar
```
lib/core/services/api_client.dart                              ← Task 15.0 (put + delete)
lib/core/constants/api_constants.dart                          ← Task 15.0 (constantes)
lib/features/settings/presentation/pages/settings_page.dart   ← Task 15.3
lib/core/constants/app_routes.dart                             ← Task 15.3
lib/main.dart                                                  ← Task 15.3
```

## IMPORTANTE — No hacer
- NO usar `withOpacity`, usar `withValues(alpha:)`
- El builder del GoRoute de userManagement usa `(_, _)` igual que otros
- `usersProvider` es `autoDispose` — se descarta cuando no hay nadie escuchando
- NO modificar tablas Drift ni ejecutar build_runner
