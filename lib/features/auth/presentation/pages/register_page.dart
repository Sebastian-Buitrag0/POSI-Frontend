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
