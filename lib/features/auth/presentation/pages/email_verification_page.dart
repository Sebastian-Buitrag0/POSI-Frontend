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
                  onPressed: () => ref
                      .read(authProvider.notifier)
                      .resendVerification(userId, email),
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
