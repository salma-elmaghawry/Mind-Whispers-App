import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/auth/app_role.dart';
import 'package:mind_whispers_app/core/helpers/extensions.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/injection/injection_container.dart';
import 'package:mind_whispers_app/core/routes/routes.dart';
import 'package:mind_whispers_app/core/theme/controller/theme_cubit.dart';
import 'package:mind_whispers_app/core/widgets/adaptive_scaffold.dart';
import 'package:mind_whispers_app/core/widgets/app_button.dart';
import 'package:mind_whispers_app/core/widgets/app_card.dart';
import 'package:mind_whispers_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mind_whispers_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_whispers_app/core/utils/app_text_styles.dart';

class RoleHomePlaceholder extends StatefulWidget {
  final AppRole role;
  final Color accentColor;

  const RoleHomePlaceholder({
    super.key,
    required this.role,
    required this.accentColor,
  });

  @override
  State<RoleHomePlaceholder> createState() => _RoleHomePlaceholderState();
}

class _RoleHomePlaceholderState extends State<RoleHomePlaceholder> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final roleLabel = 'roles.${widget.role.wireValue}'.tr();

    return AdaptiveScaffold(
      appBar: AppBar(title: Text(roleLabel)),
      selectedIndex: _index,
      onDestinationSelected: (index) => setState(() => _index = index),
      destinations: [
        AdaptiveDestination(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          label: 'home.tab_home'.tr(),
        ),
        AdaptiveDestination(
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings_rounded,
          label: 'home.tab_settings'.tr(),
        ),
      ],
      pages: [
        _HomeTab(roleLabel: roleLabel, accentColor: widget.accentColor),
        const _SettingsTab(),
      ],
    );
  }
}

class _HomeTab extends StatelessWidget {
  final String roleLabel;
  final Color accentColor;

  const _HomeTab({required this.roleLabel, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Center(
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
              style: AppTextStyles.font20Bold,
            ).fadeInSlideUp(delay: 80.ms),
            verticalSpace(10),
            Text(
              'home.welcome_subtitle'.tr(),
              textAlign: TextAlign.center,
              style: AppTextStyles.font16Normal,
            ).fadeInSlideUp(delay: 140.ms),
          ],
        ),
      ),
    );
  }
}

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  Future<void> _toggleLanguage(BuildContext context) async {
    final next = context.locale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    await context.setLocale(next);
    await getIt<SharedPreferences>().setString(
      'app_locale',
      next.languageCode,
    );
  }

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthCubit>().logout();
    if (!context.mounted) return;
    context.pushNamedAndRemoveUntil(Routes.login, predicate: (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'preferences.theme'.tr(),
                style: AppTextStyles.font16Normal,
              ),
              IconButton(
                tooltip: 'preferences.theme'.tr(),
                icon: const Icon(Icons.brightness_6_outlined),
                onPressed: () => context.read<ThemeCubit>().toggleThemeMode(),
              ),
            ],
          ),
        ),
        verticalSpace(12),
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'preferences.language'.tr(),
                style: AppTextStyles.font16Normal,
              ),
              IconButton(
                tooltip: 'preferences.language'.tr(),
                icon: const Icon(Icons.translate_outlined),
                onPressed: () => _toggleLanguage(context),
              ),
            ],
          ),
        ),
        verticalSpace(28),
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final isSigningOut = state.isLoading && state.action == AuthAction.logout;
            return AppButton(
              label: 'home.sign_out'.tr(),
              icon: Icons.logout_rounded,
              variant: AppButtonVariant.outlined,
              isLoading: isSigningOut,
              onPressed: isSigningOut ? null : () => _signOut(context),
            );
          },
        ),
      ],
    );
  }
}
