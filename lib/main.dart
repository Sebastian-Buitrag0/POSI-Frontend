import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_environment.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/providers/environment_provider.dart';
import 'core/providers/global_error_provider.dart';
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
import 'features/gastrobar/presentation/pages/kitchen_page.dart';
import 'features/gastrobar/presentation/pages/order_page.dart';
import 'features/gastrobar/presentation/pages/tables_page.dart';
import 'features/stats/presentation/pages/stats_page.dart';
import 'features/cash-register/presentation/providers/cash_register_provider.dart';

void main() {
  runApp(const ProviderScope(child: POSIApp()));
}

class POSIApp extends ConsumerWidget {
  const POSIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    ref.listen(syncProvider, (_, __) {}); // mantiene sync vivo sin reconstruir el widget
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
          if (!isAuthenticated) return AppRoutes.login;
          // Si la caja está abierta, ir directo al POS
          final cashRegister = ref.read(cashRegisterProvider);
          if (cashRegister.isOpen && !cashRegister.isRestoring) {
            return AppRoutes.pos;
          }
          return AppRoutes.home;
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
        GoRoute(
          path: AppRoutes.gastrobarTables,
          builder: (_, _) => const TablesPage(),
        ),
        GoRoute(
          path: AppRoutes.gastrobarOrder,
          builder: (context, state) {
            final orderId = state.pathParameters['orderId']!;
            return OrderPage(orderId: orderId);
          },
        ),
        GoRoute(
          path: AppRoutes.gastrobarKitchen,
          builder: (_, _) => const KitchenPage(),
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
      builder: (context, child) {
        return _GlobalErrorListener(child: child!);
      },
    );
  }
}

class _GlobalErrorListener extends ConsumerWidget {
  const _GlobalErrorListener({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<String?>(globalErrorProvider, (_, next) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 6),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () => ref.read(globalErrorProvider.notifier).state = null,
            ),
          ),
        );
      }
    });
    return child;
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7ED),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_banner_frase.png',
              width: 240,
              errorBuilder: (_, _, _) => const Icon(
                Icons.point_of_sale_rounded,
                size: 80,
                color: Color(0xFFF97066),
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Color(0xFFF97066)),
            ),
          ],
        ),
      ),
    );
  }
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Image.asset(
          'assets/images/logo_banner.png',
          height: 36,
        ),
        actions: [
          if (kIsDebugMode)
            Consumer(
              builder: (_, ref, _) {
                final env = ref.watch(environmentProvider).valueOrNull;
                if (env == null || env == AppEnvironment.production) {
                  return const SizedBox.shrink();
                }
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: env.badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: env.badgeColor),
                  ),
                  child: Text(
                    env.label,
                    style: TextStyle(
                      color: env.badgeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Consumer(
              builder: (_, ref, _) {
                final sync = ref.watch(syncProvider);
                return Row(
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
                );
              },
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (user?.isWaiter != true)
                      _HeroCard(
                        icon: Icons.point_of_sale_rounded,
                        label: 'Punto de Venta',
                        route: AppRoutes.pos,
                        color: AppColors.primary,
                      ),
                    if (user?.isWaiter != true) const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SmallCard(
                            Icons.table_restaurant_rounded,
                            'Mesas',
                            AppRoutes.gastrobarTables,
                            AppColors.warning,
                          ),
                        ),
                        if (user?.isWaiter != true) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SmallCard(
                              Icons.account_balance_wallet_rounded,
                              'Caja',
                              AppRoutes.cashRegister,
                              AppColors.info,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (user?.isWaiter != true) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _SmallCard(
                              Icons.inventory_2_rounded,
                              'Inventario',
                              AppRoutes.products,
                              AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SmallCard(
                              Icons.receipt_long_rounded,
                              'Historial',
                              AppRoutes.salesHistory,
                              AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (user?.isAdmin == true || user?.isManager == true) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _SmallCard(
                              Icons.bar_chart_rounded,
                              'Estadísticas',
                              AppRoutes.stats,
                              AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SmallCard(
                              Icons.group_rounded,
                              'Equipo',
                              AppRoutes.userManagement,
                              AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.icon,
    required this.label,
    required this.route,
    required this.color,
    this.onBeforeNavigate,
  });

  final IconData icon;
  final String label;
  final String route;
  final Color color;
  final bool Function()? onBeforeNavigate;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      color: color.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () {
          if (onBeforeNavigate != null && !onBeforeNavigate!()) return;
          context.push(route);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 28, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  const _SmallCard(this.icon, this.label, this.route, this.color);

  final IconData icon;
  final String label;
  final String route;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      color: color.withValues(alpha: 0.08),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              const SizedBox(height: 10),
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
