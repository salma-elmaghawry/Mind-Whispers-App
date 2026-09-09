import 'package:equatable/equatable.dart';
import 'package:mind_whispers_app/core/auth/app_role.dart';

/// Mirrors `UserResource` in api-1.json. The API reports `roles` as a list
/// (a user could carry more than one), but the app only ever shows one home
/// per session — see [primaryRole].
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

  /// The role that drives navigation/route-guarding (see [AppRole] and
  /// [AppRouter]'s guard). Picks the highest-privilege role this build
  /// recognizes out of the server's `roles` list.
  AppRole? get primaryRole => AppRole.fromRoles(roles);

  @override
  List<Object?> get props => [id, name, email, emailVerifiedAt, roles, createdAt];
}
