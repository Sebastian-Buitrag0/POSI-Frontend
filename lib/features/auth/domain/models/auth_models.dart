import '../entities/user_entity.dart';

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
