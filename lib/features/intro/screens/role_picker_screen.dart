import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/auth/app_role.dart';
import 'package:mind_whispers_app/core/helpers/extensions.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/injection/injection_container.dart';
import 'package:mind_whispers_app/core/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Temporary stand-in for real sign-in while the foundation is being built.
/// Picking a role persists it and drops straight into that role's home so
/// every role's shell can be previewed before AuthCubit exists (Day 3).
class RolePickerScreen extends StatelessWidget {
  const RolePickerScreen({super.key});

  Future<void> _selectRole(BuildContext context, AppRole role) async {
    final prefs = getIt<SharedPreferences>();
    await prefs.setString('user_role', role.wireValue);
    if (!context.mounted) return;
    context.pushNamedAndRemoveUntil(role.homeRoute, predicate: (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'role_picker.title'.tr(),
                style: Theme.of(context).textTheme.displayMedium,
              ).fadeInSlideUp(),
              verticalSpace(12),
              Text(
                'role_picker.subtitle'.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ).fadeInSlideUp(delay: 80.ms),
              verticalSpace(32),
              ...AnimationBuilder.staggerColumn(
                startIndex: 2,
                children: [
                  _RoleCard(
                    role: AppRole.reader,
                    color: AppColors.roleReader,
                    onTap: () => _selectRole(context, AppRole.reader),
                  ),
                  verticalSpace(12),
                  _RoleCard(
                    role: AppRole.author,
                    color: AppColors.roleAuthor,
                    onTap: () => _selectRole(context, AppRole.author),
                  ),
                  verticalSpace(12),
                  _RoleCard(
                    role: AppRole.admin,
                    color: AppColors.roleAdmin,
                    onTap: () => _selectRole(context, AppRole.admin),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final AppRole role;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({required this.role, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final roleLabel = 'roles.${role.wireValue}'.tr();

    return AnimatedTap(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            horizontalSpace(14),
            Expanded(
              child: Text(
                'role_picker.continue_as'.tr(args: [roleLabel]),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: color),
          ],
        ),
      ),
    );
  }
}
