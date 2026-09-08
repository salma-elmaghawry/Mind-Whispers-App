import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/auth/app_role.dart';
import 'package:mind_whispers_app/core/helpers/extensions.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/injection/injection_container.dart';
import 'package:mind_whispers_app/core/routes/routes.dart';
import 'package:mind_whispers_app/core/theme/controller/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared shell for the three role homes until each gets its real screens
/// (Reader: Day 4-6, Author: Day 7-8, Admin: Day 9-11). Proves the four
/// foundation pillars work end to end: persisted theme, localization/RTL,
/// role-guarded routing, and the animation kit.
class RoleHomePlaceholder extends StatelessWidget {
  final AppRole role;
  final Color accentColor;

  const RoleHomePlaceholder({
    super.key,
    required this.role,
    required this.accentColor,
  });

  Future<void> _switchRole(BuildContext context) async {
    await getIt<SharedPreferences>().remove('user_role');
    if (!context.mounted) return;
    context.pushNamedAndRemoveUntil(
      Routes.rolePicker,
      predicate: (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final roleLabel = 'roles.${role.wireValue}'.tr();

    return Scaffold(
      appBar: AppBar(
        title: Text(roleLabel),
        actions: [
          IconButton(
            tooltip: 'preferences.theme'.tr(),
            icon: const Icon(Icons.brightness_6_outlined),
            onPressed: () => context.read<ThemeCubit>().toggleThemeMode(),
          ),
          IconButton(
            tooltip: 'preferences.language'.tr(),
            icon: const Icon(Icons.translate_outlined),
            onPressed: () async {
              final next = context.locale.languageCode == 'en'
                  ? const Locale('ar')
                  : const Locale('en');
              await context.setLocale(next);
              await getIt<SharedPreferences>().setString(
                'app_locale',
                next.languageCode,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_stories_outlined, color: accentColor),
              ).fadeInScale(),
              verticalSpace(20),
              Text(
                'home.welcome_title'.tr(args: [roleLabel]),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall,
              ).fadeInSlideUp(delay: 80.ms),
              verticalSpace(10),
              Text(
                'home.welcome_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ).fadeInSlideUp(delay: 140.ms),
              verticalSpace(28),
              OutlinedButton.icon(
                onPressed: () => _switchRole(context),
                icon: const Icon(Icons.swap_horiz_rounded),
                label: Text('home.sign_out'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
