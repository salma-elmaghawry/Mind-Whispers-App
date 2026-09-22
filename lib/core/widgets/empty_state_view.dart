import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/widgets/app_button.dart';
import 'package:mind_whispers_app/core/utils/app_text_styles.dart';

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 40.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ).fadeInScale(),
            verticalSpace(16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.font18Normal,
            ).fadeInSlideUp(delay: 80.ms),
            if (message != null) ...[
              verticalSpace(6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyles.font14Normal.secondary(context),
              ).fadeInSlideUp(delay: 120.ms),
            ],
            if (actionLabel != null && onAction != null) ...[
              verticalSpace(20),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                variant: AppButtonVariant.outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
