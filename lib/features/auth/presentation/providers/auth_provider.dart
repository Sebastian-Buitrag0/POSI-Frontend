import 'package:dio/dio.dart';
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

class AuthEmailNotVerified extends AuthState {
  const AuthEmailNotVerified({required this.userId, required this.email});
  final String userId;
  final String email;
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
      state = AuthEmailNotVerified(
        userId: auth.user.id,
        email: auth.user.email,
      );
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

  Future<void> resendVerification(String userId, String email) async {
    try {
      await _api.post(
        ApiConstants.resendVerification,
        data: {'userId': userId, 'email': email},
      );
    } catch (_) {}
  }

  Future<void> forgotPassword(String email) async {
    state = const AuthLoading();
    try {
      await _api.post(ApiConstants.forgotPassword, data: {'email': email});
      state = const AuthUnauthenticated();
    } on Exception catch (e) {
      state = AuthError(_parseError(e));
    }
  }

  String _parseError(Exception e) {
    if (e.toString().contains('401')) return 'Email o contraseña incorrectos';
    if (e.toString().contains('409')) return 'El email ya está registrado';
    if (e.toString().contains('SocketException')) return 'Sin conexión a internet';
    return 'Error inesperado. Intenta de nuevo.';
  }
}
