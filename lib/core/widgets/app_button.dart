import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';

enum AppButtonVariant { filled, outlined, text }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AppButtonVariant variant;
  final IconData? icon;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = AppButtonVariant.filled,
    this.icon,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final onTap = isLoading ? null : onPressed;

    final content = isLoading
        ? SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: variant == AppButtonVariant.filled
                  ? colorScheme.onPrimary
                  : colorScheme.primary,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20.sp),
                horizontalSpace(8),
              ],
              Text(label),
            ],
          );

    final button = switch (variant) {
      AppButtonVariant.filled => ElevatedButton(
        onPressed: onTap,
        child: content,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: onTap,
        child: content,
      ),
      AppButtonVariant.text => TextButton(onPressed: onTap, child: content),
    };

    return SizedBox(width: double.infinity, height: height.h, child: button);
  }
}
