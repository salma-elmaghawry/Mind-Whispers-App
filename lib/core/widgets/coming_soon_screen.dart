import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/helpers/extensions.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/widgets/app_button.dart';

/// Arguments for `Routes.comingSoon` — pass as `settings.arguments`. Any
/// screen that links to a feature that isn't built yet (a post's full page
/// from Explore, composing a new post from Write, ...) routes here instead
/// of a bare `SnackBar`, so the "not built yet" moment reads as a real
/// screen — with its own back button — rather than a toast that's easy to
/// miss and leaves the tap looking like it did nothing.
class ComingSoonArgs {
  final String title;
  final String message;
  final IconData icon;

  const ComingSoonArgs({
    required this.title,
    required this.message,
    this.icon = Icons.hourglass_top_rounded,
  });
}

/// Generic "not built yet" destination for any tap that would otherwise
/// dead-end — see [ComingSoonArgs].
class ComingSoonScreen extends StatelessWidget {
  final ComingSoonArgs args;

  const ComingSoonScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(args.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: Center(
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84.w,
                height: 84.w,
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(args.icon, size: 40.sp, color: colorScheme.secondary),
              ).fadeInScale(),
              verticalSpace(20),
              Text(
                'common.coming_soon_title'.tr(),
                style: textTheme.displaySmall,
                textAlign: TextAlign.center,
              ).fadeInSlideUp(delay: 80.ms),
              verticalSpace(8),
              Text(
                args.message,
                style: textTheme.bodySmall,
                textAlign: TextAlign.center,
              ).fadeInSlideUp(delay: 120.ms),
              verticalSpace(28),
              AppButton(
                label: 'common.go_back'.tr(),
                variant: AppButtonVariant.outlined,
                onPressed: context.pop,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
