import 'package:equatable/equatable.dart';
import 'package:mind_whispers_app/features/auth/domain/entities/user.dart';

/// Result of a successful register/login call: the user plus the Sanctum
/// token and its expiry (24h by default, 30 days when `remember: true` was
/// sent — see api-1.json).
class AuthSession extends Equatable {
  final User user;
  final String token;
  final DateTime expiresAt;

  const AuthSession({
    required this.user,
    required this.token,
    required this.expiresAt,
  });

  @override
  List<Object?> get props => [user, token, expiresAt];
}
