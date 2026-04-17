# SPEC 004 — Sistema de Autenticación

## Contexto
Flutter 3.41, Dart 3.11, Riverpod 2.6, GoRouter 14.x.
Proyecto: `/Users/sebastian-buitrago/Documents/Yo/POSI/POSI-Frontend`
Rutas ya definidas en `lib/core/constants/app_routes.dart`.
El `main.dart` tiene un router inline con placeholders — se reemplazarán en Task 4.5.

## Decisiones de arquitectura
- `AuthState` es una sealed class (Dart 3) — exhaustive pattern matching garantizado.
- `ApiClient` es un Provider (no singleton estático) para facilitar testing.
- El interceptor usa `QueuedInterceptorsWrapper` para serializar refreshes concurrentes.
- `main.dart` NO se toca en Tasks 4.1–4.4. Solo en Task 4.5.

---

## TASK 4.1 — Constantes + modelos de dominio

### `lib/core/constants/api_constants.dart`
```dart
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:5000';

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String refresh = '/api/auth/refresh';
  static const String logout = '/api/auth/logout';
  static const String profile = '/api/auth/profile';

  // Timeouts (ms)
  static const int connectionTimeout = 10000;
  static const int receiveTimeout = 15000;
}
```

### `lib/features/auth/domain/entities/user_entity.dart`
```dart
class UserEntity {
  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.tenantId,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String tenantId;
  final DateTime createdAt;

  String get fullName => '$firstName $lastName';
  bool get isAdmin => role == 'Admin';

  UserEntity copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? tenantId,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) => UserEntity(
        id: json['id'] as String,
        email: json['email'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        role: json['role'] as String,
        tenantId: json['tenantId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
```

### `lib/features/auth/domain/models/auth_models.dart`
```dart
class LoginRequest {
  const LoginRequest({required this.email, required this.password});
  final String email;
  final String password;

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  const RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.businessName,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String businessName;

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'businessName': businessName,
      };
}

class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  final String accessToken;
  final String refreshToken;
  final UserEntity user;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
        user: UserEntity.fromJson(json['user'] as Map<String, dynamic>),
      );
}
```
Nota: importar `UserEntity` en `auth_models.dart`:
`import '../entities/user_entity.dart';`

**Validación:** 3 archivos creados, sin imports rotos.

---

## TASK 4.2 — ApiClient (Dio + interceptor JWT + secure storage)

### `lib/core/services/api_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class ApiClient {
  ApiClient() {
    _storage = const FlutterSecureStorage();
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: {'Content-Type': 'application/json'},
    ));
    _dio.interceptors.add(_buildAuthInterceptor());
  }

  late final Dio _dio;
  late final FlutterSecureStorage _storage;

  // ── Token helpers ──────────────────────────────────────────────────────────

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _kAccessToken, value: accessToken);
    await _storage.write(key: _kRefreshToken, value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);
  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<void> clearTokens() async {
    await _storage.delete(key: _kAccessToken);
    await _storage.delete(key: _kRefreshToken);
  }

  // ── Interceptor ────────────────────────────────────────────────────────────

  QueuedInterceptorsWrapper _buildAuthInterceptor() {
    return QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            final token = await getAccessToken();
            final opts = error.requestOptions;
            opts.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await _dio.fetch(opts);
              handler.resolve(response);
              return;
            } catch (_) {}
          }
          await clearTokens();
        }
        handler.next(error);
      },
    );
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;
    try {
      final response = await Dio().post(
        '${ApiConstants.baseUrl}${ApiConstants.refresh}',
        data: {'refreshToken': refreshToken},
      );
      final newAccess = response.data['accessToken'] as String;
      final newRefresh = response.data['refreshToken'] as String;
      await saveTokens(accessToken: newAccess, refreshToken: newRefresh);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── API methods ────────────────────────────────────────────────────────────

  Future<Response> post(String path, {Object? data}) =>
      _dio.post(path, data: data);

  Future<Response> get(String path,
          {Map<String, dynamic>? queryParameters}) =>
      _dio.get(path, queryParameters: queryParameters);
}
```

**Validación:** archivo creado, no hay imports rotos.

---

## TASK 4.3 — AuthState + AuthNotifier (Riverpod)

### `lib/features/auth/presentation/providers/auth_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/models/auth_models.dart';

// ── State ──────────────────────────────────────────────────────────────────

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserEntity user;
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

// ── Provider ───────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiClientProvider));
});

// ── Notifier ───────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._api) : super(const AuthInitial()) {
    _checkExistingSession();
  }

  final ApiClient _api;

  Future<void> _checkExistingSession() async {
    final token = await _api.getAccessToken();
    if (token == null) {
      state = const AuthUnauthenticated();
      return;
    }
    try {
      final response = await _api.get(ApiConstants.profile);
      state = AuthAuthenticated(
        UserEntity.fromJson(response.data as Map<String, dynamic>),
      );
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final response = await _api.post(
        ApiConstants.login,
        data: LoginRequest(email: email, password: password).toJson(),
      );
      final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      await _api.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
      state = AuthAuthenticated(auth.user);
    } on Exception catch (e) {
      state = AuthError(_parseError(e));
    }
  }

  Future<void> register(RegisterRequest request) async {
    state = const AuthLoading();
    try {
      final response = await _api.post(
        ApiConstants.register,
        data: request.toJson(),
      );
      final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
      await _api.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
      state = AuthAuthenticated(auth.user);
    } on Exception catch (e) {
      state = AuthError(_parseError(e));
    }
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiConstants.logout);
    } catch (_) {}
    await _api.clearTokens();
    state = const AuthUnauthenticated();
  }

  String _parseError(Exception e) {
    if (e.toString().contains('401')) return 'Email o contraseña incorrectos';
    if (e.toString().contains('409')) return 'El email ya está registrado';
    if (e.toString().contains('SocketException')) return 'Sin conexión a internet';
    return 'Error inesperado. Intenta de nuevo.';
  }
}
```

**Validación:** archivo creado.

---

## TASK 4.4 — Login page + Register page

### `lib/features/auth/presentation/pages/login_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    ref.listen(authProvider, (_, next) {
      if (next is AuthAuthenticated) context.go(AppRoutes.home);
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.point_of_sale, size: 72, color: Color(0xFF3B82F6)),
                const SizedBox(height: 8),
                Text(
                  'POSI',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Punto de Venta e Inventario',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                ),
                const SizedBox(height: 40),
                FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      FormBuilderTextField(
                        name: 'email',
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: 'El correo es requerido'),
                          FormBuilderValidators.email(
                              errorText: 'Correo inválido'),
                        ]),
                      ),
                      const SizedBox(height: 16),
                      FormBuilderTextField(
                        name: 'password',
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        obscureText: _obscurePassword,
                        validator: FormBuilderValidators.required(
                            errorText: 'La contraseña es requerida'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Iniciar sesión'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.push(AppRoutes.register),
                  child: const Text('¿No tienes cuenta? Regístrate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      ref
          .read(authProvider.notifier)
          .login(values['email'] as String, values['password'] as String);
    }
  }
}
```

### `lib/features/auth/presentation/pages/register_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../domain/models/auth_models.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    ref.listen(authProvider, (_, next) {
      if (next is AuthAuthenticated) context.go(AppRoutes.home);
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Crea tu negocio en POSI',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Se creará tu cuenta y tu negocio al mismo tiempo.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: const Color(0xFF6B7280)),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'firstName',
                        decoration:
                            const InputDecoration(labelText: 'Nombre'),
                        validator: FormBuilderValidators.required(
                            errorText: 'Requerido'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'lastName',
                        decoration:
                            const InputDecoration(labelText: 'Apellido'),
                        validator: FormBuilderValidators.required(
                            errorText: 'Requerido'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'businessName',
                  decoration: const InputDecoration(
                    labelText: 'Nombre del negocio',
                    prefixIcon: Icon(Icons.store_outlined),
                  ),
                  validator: FormBuilderValidators.required(
                      errorText: 'El nombre del negocio es requerido'),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'email',
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText: 'El correo es requerido'),
                    FormBuilderValidators.email(errorText: 'Correo inválido'),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'password',
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure1 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscure1 = !_obscure1),
                    ),
                  ),
                  obscureText: _obscure1,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText: 'La contraseña es requerida'),
                    FormBuilderValidators.minLength(8,
                        errorText: 'Mínimo 8 caracteres'),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderTextField(
                  name: 'confirmPassword',
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure2 ? Icons.visibility_off : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscure2 = !_obscure2),
                    ),
                  ),
                  obscureText: _obscure2,
                  validator: (value) {
                    final password =
                        _formKey.currentState?.fields['password']?.value;
                    if (value != password) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Crear cuenta'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('¿Ya tienes cuenta? Inicia sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final v = _formKey.currentState!.value;
      ref.read(authProvider.notifier).register(
            RegisterRequest(
              email: v['email'] as String,
              password: v['password'] as String,
              firstName: v['firstName'] as String,
              lastName: v['lastName'] as String,
              businessName: v['businessName'] as String,
            ),
          );
    }
  }
}
```

**Validación:** 2 archivos creados.

---

## TASK 4.5 — Actualizar main.dart (router con auth guard + rutas reales)

Reemplazar el contenido COMPLETO de `lib/main.dart` con:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() {
  runApp(const ProviderScope(child: POSIApp()));
}

class POSIApp extends ConsumerWidget {
  const POSIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final router = GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) {
        final isAuthenticated = authState is AuthAuthenticated;
        final isAuthRoute = state.matchedLocation == AppRoutes.login ||
            state.matchedLocation == AppRoutes.register;
        final isSplash = state.matchedLocation == AppRoutes.splash;

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
          path: AppRoutes.home,
          builder: (context, state) => const _HomePage(),
        ),
        GoRoute(
          path: AppRoutes.products,
          builder: (context, state) => const _PlaceholderPage('Productos'),
        ),
        GoRoute(
          path: AppRoutes.pos,
          builder: (context, state) => const _PlaceholderPage('Punto de Venta'),
        ),
      ],
      errorBuilder: (context, state) => const _ErrorPage(),
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

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
}

class _HomePage extends ConsumerWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = (ref.watch(authProvider) as AuthAuthenticated?)?.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.point_of_sale, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Bienvenido, ${user?.firstName ?? ''}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(user?.role ?? '',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('$title — Próximamente')),
      );
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
```

IMPORTANTE: También agregar la ruta `/register` en `lib/core/constants/app_routes.dart`:
```dart
static const String register = '/register';
```
(ya existe `login`, solo agregar `register`)

**Validación final:** ejecutar `flutter analyze` — debe retornar "No issues found".

---

## Estructura final esperada
```
lib/
  core/
    constants/
      api_constants.dart        ← nuevo
      app_routes.dart           ← agregar /register
    services/
      api_client.dart           ← nuevo
  features/
    auth/
      domain/
        entities/
          user_entity.dart      ← nuevo
        models/
          auth_models.dart      ← nuevo
      presentation/
        pages/
          login_page.dart       ← nuevo
          register_page.dart    ← nuevo
        providers/
          auth_provider.dart    ← nuevo
  main.dart                     ← reemplazado
```
