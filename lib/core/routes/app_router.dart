import 'package:flutter/material.dart';
import 'package:mind_whispers_app/core/auth/app_role.dart';
import 'package:mind_whispers_app/core/injection/injection_container.dart';
import 'package:mind_whispers_app/core/routes/routes.dart';
import 'package:mind_whispers_app/core/widgets/unauthorized_screen.dart';
import 'package:mind_whispers_app/features/admin/screens/admin_home_screen.dart';
import 'package:mind_whispers_app/features/author/screens/author_home_screen.dart';
import 'package:mind_whispers_app/features/intro/screens/role_picker_screen.dart';
import 'package:mind_whispers_app/features/intro/screens/splash_screen.dart';
import 'package:mind_whispers_app/features/reader/screens/reader_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.rolePicker:
        return MaterialPageRoute(builder: (_) => const RolePickerScreen());
      case Routes.unauthorized:
        return MaterialPageRoute(builder: (_) => const UnauthorizedScreen());

      case Routes.adminHome:
        return _guardedRoute(
          allowedRoles: const [AppRole.admin],
          builder: (_) => const AdminHomeScreen(),
        );
      case Routes.authorHome:
        return _guardedRoute(
          allowedRoles: const [AppRole.author],
          builder: (_) => const AuthorHomeScreen(),
        );
      case Routes.readerHome:
        return _guardedRoute(
          allowedRoles: const [AppRole.reader],
          builder: (_) => const ReaderHomeScreen(),
        );

      // Register each new screen here as features are created, e.g.:
      // case Routes.login:
      //   return MaterialPageRoute(builder: (_) => const LoginScreen());
      // Pass arguments via `settings.arguments`.

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  /// Only lets the request through when the signed-in role (read from
  /// SharedPreferences today; from AuthCubit's session once it exists) is
  /// in [allowedRoles] — otherwise shows [UnauthorizedScreen].
  Route<dynamic> _guardedRoute({
    required List<AppRole> allowedRoles,
    required WidgetBuilder builder,
  }) {
    final role = AppRole.fromWire(
      getIt<SharedPreferences>().getString('user_role'),
    );

    if (role != null && allowedRoles.contains(role)) {
      return MaterialPageRoute(builder: builder);
    }
    return MaterialPageRoute(builder: (_) => const UnauthorizedScreen());
  }
}
