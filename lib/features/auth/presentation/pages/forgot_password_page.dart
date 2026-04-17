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
                    FormBuilderValidators.required(
                        errorText: 'El correo es requerido'),
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
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
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
