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
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) => _UserTile(user: users[i]),
              ),
      },
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateLocalSheet(context, ref),
        icon: const Icon(Icons.person_add),
        label: const Text('Usuario local'),
      ),
    );
  }

  void _showCreateLocalSheet(BuildContext context, WidgetRef ref) {
    final firstNameCtrl = TextEditingController();
    final lastNameCtrl = TextEditingController();
    final cedulaCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = 'Mesero';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Nuevo usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: lastNameCtrl,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: cedulaCtrl,
                  decoration: const InputDecoration(labelText: 'Cédula'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedRole,
                  decoration: const InputDecoration(labelText: 'Rol'),
                  items: const [
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                    DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                    DropdownMenuItem(value: 'Cashier', child: Text('Cajero')),
                    DropdownMenuItem(value: 'Mesero', child: Text('Mesero')),
                  ],
                  onChanged: (v) => setState(() => selectedRole = v ?? 'Mesero'),
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
                final error = await ref.read(usersProvider.notifier).createLocal(
                      firstName: firstNameCtrl.text.trim(),
                      lastName: lastNameCtrl.text.trim(),
                      cedula: cedulaCtrl.text.trim(),
                      role: selectedRole,
                      password: passwordCtrl.text,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error == null ? 'Usuario creado' : 'Error: $error'),
                      backgroundColor: error == null ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Crear'),
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
            initialValue: selectedRole,
            decoration: const InputDecoration(labelText: 'Rol'),
            items: const [
              DropdownMenuItem(value: 'Admin', child: Text('Admin')),
              DropdownMenuItem(value: 'Manager', child: Text('Manager')),
              DropdownMenuItem(value: 'Cashier', child: Text('Cajero')),
              DropdownMenuItem(value: 'Mesero', child: Text('Mesero')),
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
