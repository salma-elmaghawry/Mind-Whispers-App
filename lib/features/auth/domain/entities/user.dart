import 'package:equatable/equatable.dart';
import 'package:mind_whispers_app/core/auth/app_role.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final List<String> roles;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.emailVerifiedAt,
    required this.roles,
    required this.createdAt,
  });

  bool get isEmailVerified => emailVerifiedAt != null;

  AppRole? get primaryRole => AppRole.fromRoles(roles);

  @override
  List<Object?> get props => [id, name, email, emailVerifiedAt, roles, createdAt];
}
