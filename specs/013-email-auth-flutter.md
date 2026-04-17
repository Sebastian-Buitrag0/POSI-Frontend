# Spec 013-B — Email Verification + Password Reset (Flutter)

## Objetivo
- Después del registro: mostrar pantalla "Verifica tu correo" en vez de ir al home
- Login con email no verificado (403): mostrar error específico con botón para reenviar
- Pantalla "Olvidé mi contraseña" en login
- El reset de contraseña ocurre en el browser (el backend sirve el form HTML)
  → Flutter solo necesita pedir el email y mostrar "revisa tu correo"

## Infraestructura existente
- `authProvider` / `AuthNotifier` — estados sealed: Initial, Loading, Authenticated, Unauthenticated, Error
- `LoginPage` — tiene `ref.listen(authProvider, ...)` para navegar en `AuthAuthenticated`
- `RegisterPage` — similar a LoginPage
- `AppRoutes`: `/login`, `/register`, `/home`
- `ApiClient.post(path, data)` — adjunta JWT si existe
- `AppColors`: primary, error, textSecondary, success

---

## Task 13.0 — Nuevo estado AuthEmailNotVerified + constantes API

### Agregar estado en `lib/features/auth/presentation/providers/auth_provider.dart`

Agregar después de `AuthError`:
```dart
class AuthEmailNotVerified extends AuthState {
  const AuthEmailNotVerified({required this.userId, required this.email});
  final String userId;
  final String email;
}
```

### Agregar en `lib/core/constants/api_constants.dart` después de `profile`:

```dart
  // Email auth
  static const String verifyEmail = '/api/auth/verify-email';
  static const String resendVerification = '/api/auth/resend-verification';
  static const String forgotPassword = '/api/auth/forgot-password';
```

---

## Task 13.1 — Actualizar AuthNotifier

En `lib/features/auth/presentation/providers/auth_provider.dart`:

1. Modificar `login()` — cambiar el catch de Exception para detectar 403:
```dart
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
  } on DioException catch (e) {
    if (e.response?.statusCode == 403) {
      state = const AuthError('email_not_verified');
    } else {
      state = AuthError(_parseError(e));
    }
  } on Exception catch (e) {
    state = AuthError(_parseError(e));
  }
}
```

2. Modificar `register()` — después de `saveTokens`, emitir `AuthEmailNotVerified` en vez de `AuthAuthenticated`:
```dart
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
    // No autenticar todavía — primero verificar email
    state = AuthEmailNotVerified(
      userId: auth.user.id,
      email: auth.user.email,
    );
  } on Exception catch (e) {
    state = AuthError(_parseError(e));
  }
}
```

3. Agregar método `resendVerification`:
```dart
Future<void> resendVerification(String userId, String email) async {
  try {
    await _api.post(
      ApiConstants.resendVerification,
      data: {'userId': userId, 'email': email},
    );
  } catch (_) {}
}
```

4. Agregar `forgotPassword`:
```dart
Future<void> forgotPassword(String email) async {
  state = const AuthLoading();
  try {
    await _api.post(ApiConstants.forgotPassword, data: {'email': email});
    state = const AuthUnauthenticated();
  } on Exception catch (e) {
    state = AuthError(_parseError(e));
  }
}
```

5. Agregar import de Dio al inicio del archivo:
```dart
import 'package:dio/dio.dart';
```

---

## Task 13.2 — EmailVerificationPage

Crear `lib/features/auth/presentation/pages/email_verification_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';

class EmailVerificationPage extends ConsumerWidget {
  const EmailVerificationPage({
    super.key,
    required this.userId,
    required this.email,
  });

  final String userId;
  final String email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (_, next) {
      if (next is AuthAuthenticated) context.go(AppRoutes.home);
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mark_email_unread_outlined,
                    size: 72, color: AppColors.primary),
                const SizedBox(height: 24),
                Text(
                  'Verifica tu correo',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Te enviamos un enlace de verificación a\n$email',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(authProvider.notifier).resendVerification(userId, email),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reenviar correo'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: Text(
                    'Volver al inicio de sesión',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Task 13.3 — ForgotPasswordPage

Crear `lib/features/auth/presentation/pages/forgot_password_page.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider) is AuthLoading;

    if (_sent) {
      return Scaffold(
        appBar: AppBar(title: const Text('Restablecer contraseña')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mark_email_read_outlined,
                    size: 64, color: AppColors.success),
                const SizedBox(height: 24),
                Text(
                  'Revisa tu correo',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Si tu correo está registrado, recibirás un enlace para restablecer tu contraseña.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Volver al inicio de sesión'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Olvidé mi contraseña')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              FormBuilder(
                key: _formKey,
                child: FormBuilderTextField(
                  name: 'email',
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'El correo es requerido'),
                    FormBuilderValidators.email(errorText: 'Correo inválido'),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Enviar enlace'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final email = _formKey.currentState!.value['email'] as String;
      ref.read(authProvider.notifier).forgotPassword(email);
      setState(() => _sent = true);
    }
  }
}
```

---

## Task 13.4 — Actualizar LoginPage

En `lib/features/auth/presentation/pages/login_page.dart`:

1. Modificar el `ref.listen` para manejar `AuthEmailNotVerified` y el error especial:
```dart
ref.listen(authProvider, (_, next) {
  if (next is AuthAuthenticated) context.go(AppRoutes.home);
  if (next is AuthEmailNotVerified) {
    context.go(AppRoutes.emailVerification,
        extra: {'userId': next.userId, 'email': next.email});
  }
  if (next is AuthError) {
    if (next.message == 'email_not_verified') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Debes verificar tu correo antes de iniciar sesión.'),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Reenviar',
            onPressed: () => context.go(AppRoutes.emailVerification,
                extra: {'userId': '', 'email': ''}),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next.message), backgroundColor: Colors.red),
      );
    }
  }
});
```

2. Agregar botón "Olvidé mi contraseña" después del botón de registro:
```dart
TextButton(
  onPressed: () => context.push(AppRoutes.forgotPassword),
  child: const Text('¿Olvidaste tu contraseña?'),
),
```

---

## Task 13.5 — Actualizar RegisterPage

En `lib/features/auth/presentation/pages/register_page.dart`, modificar el `ref.listen`:

```dart
ref.listen(authProvider, (_, next) {
  if (next is AuthAuthenticated) context.go(AppRoutes.home);
  if (next is AuthEmailNotVerified) {
    context.go(AppRoutes.emailVerification,
        extra: {'userId': next.userId, 'email': next.email});
  }
  if (next is AuthError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(next.message), backgroundColor: Colors.red),
    );
  }
});
```

---

## Task 13.6 — Nuevas rutas en AppRoutes + main.dart

### En `lib/core/constants/app_routes.dart`, agregar:
```dart
static const String emailVerification = '/verify-email';
static const String forgotPassword = '/forgot-password';
```

### En `lib/main.dart`:

1. Agregar imports:
```dart
import 'features/auth/presentation/pages/email_verification_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
```

2. Agregar rutas en GoRouter (después de la ruta `register`):
```dart
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
```

---

## Task 13.7 — Validación

```bash
cd /Users/sebastian-buitrago/Documents/Yo/POSI/POSI-Frontend
fvm flutter analyze
```

**0 errores.**

---

## Archivos a crear
```
lib/features/auth/presentation/pages/email_verification_page.dart
lib/features/auth/presentation/pages/forgot_password_page.dart
```

## Archivos a modificar
```
lib/features/auth/presentation/providers/auth_provider.dart  ← nuevo estado + métodos
lib/features/auth/presentation/pages/login_page.dart         ← ref.listen + forgot link
lib/features/auth/presentation/pages/register_page.dart      ← ref.listen
lib/core/constants/app_routes.dart                           ← nuevas rutas
lib/core/constants/api_constants.dart                        ← nuevas constantes
lib/main.dart                                                ← nuevas rutas GoRouter
```

## IMPORTANTE — No hacer
- NO hacer deep link / app scheme — el reset ocurre en browser
- NO agregar campos de token a Flutter — el form HTML del backend lo maneja
- NO usar `withOpacity`, usar `withValues(alpha:)` si se necesita
- `AuthEmailNotVerified` NO es AuthAuthenticated — el usuario no está logueado aún
