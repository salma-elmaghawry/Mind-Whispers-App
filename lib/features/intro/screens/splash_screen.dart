import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/auth/app_role.dart';
import 'package:mind_whispers_app/core/helpers/extensions.dart';
import 'package:mind_whispers_app/core/injection/injection_container.dart';
import 'package:mind_whispers_app/core/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the app and routes to the signed-in role's home, or the role
/// picker when nobody is signed in yet. Will read the real session once
/// AuthCubit ships on Day 3 — for now it reads the role stored by
/// [RolePickerScreen].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideNextRoute();
  }

  Future<void> _decideNextRoute() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final prefs = getIt<SharedPreferences>();
    final role = AppRole.fromWire(prefs.getString('user_role'));

    context.pushReplacementNamed(role?.homeRoute ?? Routes.rolePicker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'app_name'.tr(),
          style: Theme.of(context).textTheme.displayMedium,
        ).fadeInScale(),
      ),
    );
  }
}
