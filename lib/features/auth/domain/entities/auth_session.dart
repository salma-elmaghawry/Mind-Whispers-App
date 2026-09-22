import 'package:equatable/equatable.dart';
import 'package:mind_whispers_app/features/auth/domain/entities/user.dart';

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
