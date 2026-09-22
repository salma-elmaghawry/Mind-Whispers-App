import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/helpers/extensions.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/injection/injection_container.dart';
import 'package:mind_whispers_app/core/routes/routes.dart';
import 'package:mind_whispers_app/core/theme/controller/theme_cubit.dart';
import 'package:mind_whispers_app/core/widgets/app_button.dart';
import 'package:mind_whispers_app/core/widgets/app_card.dart';
import 'package:mind_whispers_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mind_whispers_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:mind_whispers_app/features/reader/presentation/widgets/author_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mind_whispers_app/core/utils/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _toggleLanguage(BuildContext context) async {
    final next = context.locale.languageCode == 'en'
        ? const Locale('ar')
        : const Locale('en');
    await context.setLocale(next);
    await getIt<SharedPreferences>().setString('app_locale', next.languageCode);
  }

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthCubit>().logout();
    if (!context.mounted) return;
    context.pushNamedAndRemoveUntil(Routes.login, predicate: (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;

    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        Center(
          child: Column(
            children: [
              AuthorAvatar(name: user?.name ?? '', radius: 36.r).fadeInScale(),
              verticalSpace(14),
              Text(
                user?.name ?? '',
                style: AppTextStyles.font20Bold,
              ).fadeInSlideUp(delay: 60.ms),
              verticalSpace(4),
              Text(
                user?.email ?? '',
                style: AppTextStyles.font14Normal.secondary(context),
              ).fadeInSlideUp(delay: 100.ms),
              if (user != null && !user.isEmailVerified) ...[
                verticalSpace(10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'profile.email_unverified'.tr(),
                    style: AppTextStyles.font12Medium.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ).fadeInSlideUp(delay: 140.ms),
              ],
            ],
          ),
        ),
        verticalSpace(28),
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('preferences.theme'.tr(), style: AppTextStyles.font16Normal),
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
              Text('preferences.language'.tr(), style: AppTextStyles.font16Normal),
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
