import 'package:mind_whispers_app/core/routes/routes.dart';

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
