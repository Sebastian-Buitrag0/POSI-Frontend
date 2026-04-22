import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/providers/sync_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/email_verification_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/products/presentation/pages/product_list_page.dart';
import 'features/products/presentation/pages/product_form_page.dart';
import 'features/scanner/presentation/pages/scanner_screen.dart';
import 'features/sales/presentation/pages/pos_page.dart';
import 'features/sales/presentation/pages/sales_history_page.dart';
import 'features/cash-register/presentation/pages/cash_register_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/scanner/presentation/pages/scanner_picker_screen.dart';
import 'features/users/presentation/pages/user_management_page.dart';
import 'features/stats/presentation/pages/stats_page.dart';

void main() {
  runApp(const ProviderScope(child: POSIApp()));
}

class POSIApp extends ConsumerWidget {
  const POSIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    ref.watch(syncProvider);
    final themeMode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.light;

    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) {
        final isLoading = authState is AuthInitial || authState is AuthLoading;
        final isAuthenticated = authState is AuthAuthenticated;
        final isAuthRoute = state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register ||
            state.matchedLocation == AppRoutes.emailVerification ||
            state.matchedLocation == AppRoutes.forgotPassword;
        final isSplash = state.matchedLocation == AppRoutes.splash;

        // Mientras verifica el token guardado, quedarse en splash
        if (isLoading) return isSplash ? null : AppRoutes.splash;

        if (isSplash) {
          return isAuthenticated ? AppRoutes.home : AppRoutes.login;
        }
        if (!isAuthenticated && !isAuthRoute) return AppRoutes.login;
        if (isAuthenticated && isAuthRoute) return AppRoutes.home;
        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const _SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.emailVerification,
          builder: (context, state) {
            final extra = state.extra as Map<String, String>? ?? {};
            return EmailVerificationPage(
              userId: extra['userId'] ?? '',
              email: extra['email'] ?? '',
            );
          },
        ),
        GoRoute(
          path: AppRoutes.forgotPassword,
          builder: (_, _) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const _HomePage(),
        ),
        GoRoute(
          path: AppRoutes.products,
          builder: (context, state) => const ProductListPage(),
        ),
        GoRoute(
          path: AppRoutes.productDetail,
          builder: (context, state) {
            final id = state.pathParameters['id'];
            return ProductFormPage(productId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.scanner,
          builder: (_, _) => const ScannerScreen(),
        ),
          GoRoute(
          path: AppRoutes.pos,
          builder: (context, state) => const PosPage(),
        ),
        GoRoute(
          path: AppRoutes.salesHistory,
          builder: (_, _) => const SalesHistoryPage(),
        ),
        GoRoute(
          path: AppRoutes.cashRegister,
          builder: (_, _) => const CashRegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (_, _) => const SettingsPage(),
        ),
        GoRoute(
          path: AppRoutes.userManagement,
          builder: (_, _) => const UserManagementPage(),
        ),
        GoRoute(
          path: AppRoutes.stats,
          builder: (_, _) => const StatsPage(),
        ),
        GoRoute(
          path: AppRoutes.scannerPicker,
          builder: (_, state) {
            final resolver =
                state.extra as Future<String?> Function(String)?;
            return ScannerPickerScreen(nameResolver: resolver);
          },
        ),
      ],
      errorBuilder: (context, state) => const _ErrorPage(),
    );

    return MaterialApp.router(
      title: 'POSI - Punto de Venta e Inventario',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}

String _formatSyncTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inSeconds < 60) return 'ahora';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes}m';
  if (diff.inHours < 24) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
  final d = dt.day.toString().padLeft(2, '0');
  final mo = dt.month.toString().padLeft(2, '0');
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$d/$mo $h:$m';
}

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (sync.isSyncing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  Icon(
                    sync.lastSyncAt != null
                        ? Icons.cloud_done
                        : Icons.cloud_off,
                    color: sync.lastSyncAt != null
                        ? AppColors.success
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                if (sync.lastSyncAt != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    _formatSyncTime(sync.lastSyncAt!),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppRoutes.settings),
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
                    onTap: () => context.push(AppRoutes.pos),
                  ),
                  _MenuCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Productos',
                    color: AppColors.secondary,
                    onTap: () => context.push(AppRoutes.products),
                  ),
                  _MenuCard(
                    icon: Icons.receipt_long_outlined,
                    label: 'Historial',
                    color: AppColors.accent,
                    onTap: () => context.push(AppRoutes.salesHistory),
                  ),
                  _MenuCard(
                    icon: Icons.store_outlined,
                    label: 'Caja',
                    color: AppColors.info,
                    onTap: () => context.push(AppRoutes.cashRegister),
                  ),
                  if (user?.isAdmin == true) ...[
                    _MenuCard(
                      icon: Icons.bar_chart_rounded,
                      label: 'Estadísticas',
                      color: Colors.deepPurple,
                      onTap: () => context.push(AppRoutes.stats),
                    ),
                    _MenuCard(
                      icon: Icons.group_outlined,
                      label: 'Equipo',
                      color: AppColors.secondary,
                      onTap: () => context.push(AppRoutes.userManagement),
                    ),
                  ],
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

class _ErrorPage extends StatelessWidget {
  const _ErrorPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Página no encontrada',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      );
}
