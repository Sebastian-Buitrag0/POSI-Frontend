import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_environment.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/providers/environment_provider.dart';
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
                        name: 'identifier',
                        decoration: const InputDecoration(
                          labelText: 'Correo o cédula',
                          hintText: 'usuario@email.com o 1234567890',
                          prefixIcon: Icon(Icons.person_outlined),
                        ),
                        keyboardType: TextInputType.text,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                              errorText: 'El correo o cédula es requerido'),
                          (val) {
                            if (val == null || val.isEmpty) return null;
                            if (val.contains('@')) {
                              final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                              if (!emailRegex.hasMatch(val)) {
                                return 'Correo inválido';
                              }
                            } else if (val.length < 6) {
                              return 'La cédula debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
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
                if (kIsDebugMode) ...[
                  const SizedBox(height: 24),
                  Consumer(
                    builder: (context, ref, _) {
                      final env = ref.watch(environmentProvider).valueOrNull
                          ?? AppEnvironment.production;
                      return GestureDetector(
                        onTap: () => _showEnvironmentPicker(context, ref),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: env.badgeColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                  color: env.badgeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                env.label,
                                style: TextStyle(
                                  color: env.badgeColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.expand_more, size: 14, color: env.badgeColor),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEnvironmentPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Entorno', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Divider(),
          ...AppEnvironment.values.map((env) => ListTile(
            leading: Container(
              width: 12, height: 12,
              decoration: BoxDecoration(color: env.badgeColor, shape: BoxShape.circle),
            ),
            title: Text(env.label),
            subtitle: Text(env.baseUrl, style: const TextStyle(fontSize: 11)),
            onTap: () {
              ref.read(environmentProvider.notifier).setEnvironment(env);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;
      ref
          .read(authProvider.notifier)
          .login(values['identifier'] as String, values['password'] as String);
    }
  }
}
