import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/helpers/extensions.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/routes/routes.dart';
import 'package:mind_whispers_app/core/theme/app_colors.dart';

/// Shown by [AppRouter]'s role guard when the signed-in role doesn't match
/// the route it tried to open (mirrors a 403 from the API, see
/// errors.forbidden in API_CONTRACT.md).
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
                style: Theme.of(context).textTheme.bodyLarge,
              ).fadeInSlideUp(delay: 80.ms),
              verticalSpace(24),
              FilledButton(
                onPressed: () => context.pushNamedAndRemoveUntil(
                  Routes.rolePicker,
                  predicate: (_) => false,
                ),
                child: Text('common.ok'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
