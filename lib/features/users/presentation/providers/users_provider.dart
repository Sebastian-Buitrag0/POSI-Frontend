import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_client.dart';

class TenantUser {
  const TenantUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime createdAt;

  String get fullName => '$firstName $lastName';

  factory TenantUser.fromJson(Map<String, dynamic> json) => TenantUser(
        id: json['id'] as String,
        email: json['email'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        role: json['role'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

// ── State ──────────────────────────────────────────────────────────────────

sealed class UsersState {
  const UsersState();
}

class UsersLoading extends UsersState {
  const UsersLoading();
}

class UsersLoaded extends UsersState {
  const UsersLoaded(this.users);
  final List<TenantUser> users;
}

class UsersError extends UsersState {
  const UsersError(this.message);
  final String message;
}

// ── Provider ───────────────────────────────────────────────────────────────

final usersProvider =
    StateNotifierProvider.autoDispose<UsersNotifier, UsersState>((ref) {
  return UsersNotifier(ref.watch(apiClientProvider));
});

// ── Notifier ───────────────────────────────────────────────────────────────

class UsersNotifier extends StateNotifier<UsersState> {
  UsersNotifier(this._api) : super(const UsersLoading()) {
    load();
  }

  final ApiClient _api;

  Future<void> load() async {
    if (!mounted) return;
    state = const UsersLoading();
    try {
      final response = await _api.get(ApiConstants.users);
      final list = (response.data as List).cast<Map<String, dynamic>>();
      if (!mounted) return;
      state = UsersLoaded(list.map(TenantUser.fromJson).toList());
    } on Exception catch (e) {
      if (!mounted) return;
      state = UsersError(e.toString());
    }
  }

  Future<String?> invite({
    required String email,
    required String firstName,
    required String lastName,
    required String role,
  }) async {
    try {
      await _api.post(ApiConstants.usersInvite, data: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
      });
      await load();
      return null;
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateRole(String userId, String newRole) async {
    try {
      await _api.put('${ApiConstants.users}/$userId/role', data: {'role': newRole});
      await load();
      return null;
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future<String?> remove(String userId) async {
    try {
      await _api.delete('${ApiConstants.users}/$userId');
      await load();
      return null;
    } on Exception catch (e) {
      return e.toString();
    }
  }

  Future<String?> createLocal({
    required String firstName,
    required String lastName,
    required String cedula,
    required String role,
    required String password,
  }) async {
    try {
      await _api.post(ApiConstants.usersCreateLocal, data: {
        'firstName': firstName,
        'lastName': lastName,
        'cedula': cedula,
        'role': role,
        'password': password,
      });
      await load();
      return null;
    } on Exception catch (e) {
      return e.toString();
    }
  }
}
