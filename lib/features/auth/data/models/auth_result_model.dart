import 'package:mind_whispers_app/features/auth/data/models/user_model.dart';
import 'package:mind_whispers_app/features/auth/domain/entities/auth_session.dart';

/// Matches the register/login response body in api-1.json:
/// `{ user: UserResource, token: string, expires_at: string }`
/// (returned at the top level, not wrapped in a `data` envelope).
class AuthResultModel {
  final UserModel user;
  final String token;
  final DateTime expiresAt;

  const AuthResultModel({
    required this.user,
    required this.token,
    required this.expiresAt,
  });

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    return AuthResultModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  AuthSession toEntity() {
    return AuthSession(user: user.toEntity(), token: token, expiresAt: expiresAt);
  }
}
