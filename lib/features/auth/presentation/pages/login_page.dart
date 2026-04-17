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
      if (next is AuthEmailNotVerified) {
        context.go(AppRoutes.emailVerification,
            extra: {'userId': next.userId, 'email': next.email});
      }
      if (next is AuthError) {
        if (next.message == 'email_not_verified') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  const Text('Debes verificar tu correo antes de iniciar sesión.'),
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
                TextButton(
                  onPressed: () => context.push(AppRoutes.forgotPassword),
                  child: const Text('¿Olvidaste tu contraseña?'),
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
