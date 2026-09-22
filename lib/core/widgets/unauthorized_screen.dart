import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/helpers/extensions.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/routes/routes.dart';
import 'package:mind_whispers_app/core/theme/app_colors.dart';
import 'package:mind_whispers_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mind_whispers_app/core/utils/app_text_styles.dart';

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: AppColors.error,
              ).fadeInScale(),
              verticalSpace(16),
              Text(
                'errors.forbidden'.tr(),
                textAlign: TextAlign.center,
                style: AppTextStyles.font18Normal,
              ).fadeInSlideUp(delay: 80.ms),
              verticalSpace(24),
              FilledButton(
                onPressed: () {
                  final role = context.read<AuthCubit>().state.user?.primaryRole;
                  context.pushNamedAndRemoveUntil(
                    role?.homeRoute ?? Routes.login,
                    predicate: (_) => false,
                  );
                },
                child: Text('common.ok'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
