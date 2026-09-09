import 'package:mind_whispers_app/core/routes/routes.dart';

/// One of `"admin" | "author" | "reader"`. The real API (api-1.json)
/// reports a user's roles as a list on `UserResource.roles`; this enum is
/// the app's own single-role model, used for route-guarding and picked out
/// of that list by [fromRoles] (see `User.primaryRole`). [fromWire] reads
/// back the single wire value this app itself persists to SharedPreferences
/// (`user_role`, written by the auth repository) — it is not the shape the
/// server sends.
enum AppRole {
  admin,
  author,
  reader;

  static AppRole? fromWire(String? value) {
    return switch (value) {
      'admin' => AppRole.admin,
      'author' => AppRole.author,
      'reader' => AppRole.reader,
      _ => null,
    };
  }

  /// Picks the highest-privilege role this build recognizes out of a
  /// server-reported `roles` list, or `null` if none match (e.g. an empty
  /// list, or only roles this app doesn't have a home screen for yet).
  ///
  /// The backend's default Laravel/Spatie role for a newly registered
  /// account is `subscriber`, not `reader` — treat it as an alias for
  /// [AppRole.reader] so those accounts land on the reader home instead of
  /// [Routes.unauthorized].
  static AppRole? fromRoles(List<String> roles) {
    if (roles.contains('subscriber')) return AppRole.reader;
    for (final role in [AppRole.admin, AppRole.author, AppRole.reader]) {
      if (roles.contains(role.wireValue)) return role;
    }
    return null;
  }

  String get wireValue => name;

  String get homeRoute {
    switch (this) {
      case AppRole.admin:
        return Routes.adminHome;
      case AppRole.author:
        return Routes.authorHome;
      case AppRole.reader:
        return Routes.readerHome;
    }
  }
}
