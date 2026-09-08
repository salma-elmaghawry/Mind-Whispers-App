import 'package:mind_whispers_app/core/routes/routes.dart';

/// Mirrors the `role` field on the User resource in API_CONTRACT.md
/// (`"admin" | "author" | "reader"`). Shared by the router guard now and by
/// the real auth feature's User entity once it lands on Day 3.
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
