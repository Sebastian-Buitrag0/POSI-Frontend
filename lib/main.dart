import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: POSIApp()));
}

class POSIApp extends ConsumerWidget {
  const POSIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.products,
          builder: (context, state) => const ProductsPage(),
        ),
        GoRoute(
          path: AppRoutes.pos,
          builder: (context, state) => const POSPage(),
        ),
      ],
      errorBuilder: (context, state) => const ErrorPage(),
    );

    return MaterialApp.router(
      title: 'POSI - Punto de Venta e Inventario',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.point_of_sale, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          Text('POSI', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Cargando...', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    ),
  );
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Iniciar Sesión')),
    body: const Center(child: Text('Login (Pendiente de implementar)')),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Inicio')),
    body: const Center(child: Text('Dashboard (Pendiente)')),
  );
}

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Productos')),
    body: const Center(child: Text('Productos CRUD (Pendiente)')),
  );
}

class POSPage extends StatelessWidget {
  const POSPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Punto de Venta')),
    body: const Center(child: Text('POS / Carrito (Pendiente)')),
  );
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Página no encontrada',
            style: Theme.of(context).textTheme.titleLarge,
          ),
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
