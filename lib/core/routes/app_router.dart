import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_whispers_app/core/auth/app_role.dart';
import 'package:mind_whispers_app/core/injection/injection_container.dart';
import 'package:mind_whispers_app/core/routes/routes.dart';
import 'package:mind_whispers_app/core/widgets/coming_soon_screen.dart';
import 'package:mind_whispers_app/core/widgets/unauthorized_screen.dart';
import 'package:mind_whispers_app/features/admin/screens/admin_home_screen.dart';
import 'package:mind_whispers_app/features/author/screens/author_home_screen.dart';
import 'package:mind_whispers_app/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:mind_whispers_app/features/auth/presentation/screens/login_screen.dart';
import 'package:mind_whispers_app/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:mind_whispers_app/features/auth/presentation/screens/signup_screen.dart';
import 'package:mind_whispers_app/features/auth/repository/auth_repository_impl.dart';
import 'package:mind_whispers_app/features/intro/screens/splash_screen.dart';
import 'package:mind_whispers_app/features/reader/presentation/cubit/post_detail/post_detail_cubit.dart';
import 'package:mind_whispers_app/features/reader/presentation/screens/post_detail_screen.dart';
import 'package:mind_whispers_app/features/reader/presentation/screens/reader_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppRouter {
  Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case Routes.signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case Routes.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case Routes.resetPassword:
        final email = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(email: email),
        );
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
      case Routes.postDetail:
        final postId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => BlocProvider<PostDetailCubit>(
            create: (_) => getIt<PostDetailCubit>(param1: postId),
            child: PostDetailScreen(postId: postId),
          ),
        );
      case Routes.comingSoon:
        final args = settings.arguments as ComingSoonArgs;
        return MaterialPageRoute(builder: (_) => ComingSoonScreen(args: args));

      default:
        return null;
    }
  }

  Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))),
    );
  }

  Route<dynamic> _guardedRoute({
    required List<AppRole> allowedRoles,
    required WidgetBuilder builder,
  }) {
    final role = AppRole.fromWire(getIt<SharedPreferences>().getString(userRolePrefsKey));

    if (role != null && allowedRoles.contains(role)) {
      return MaterialPageRoute(builder: builder);
    }
    return MaterialPageRoute(builder: (_) => const UnauthorizedScreen());
  }
}
