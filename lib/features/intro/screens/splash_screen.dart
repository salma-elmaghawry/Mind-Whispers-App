import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/helpers/extensions.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/routes/routes.dart';
import 'package:mind_whispers_app/features/auth/presentation/cubit/auth_cubit.dart';


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
    final authCubit = context.read<AuthCubit>();
  
    final minDelay = Future<void>.delayed(const Duration(milliseconds: 900));
    await Future.wait([minDelay, authCubit.checkAuthStatus()]);
    if (!mounted) return;

    final state = authCubit.state;
    if (state.isSuccess && state.user != null) {
      final role = state.user!.primaryRole;
      context.pushReplacementNamed(role?.homeRoute ?? Routes.unauthorized);
    } else {
      context.pushReplacementNamed(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              'assets/images/logo.svg',
              width: 180.w,
              height: 180.w,
            ).fadeInScale(),
            verticalSpace(16),
            Text(
              'app_name'.tr(),
              style: Theme.of(context).textTheme.displaySmall,
            ).fadeInSlideUp(delay: 120.ms),
            verticalSpace(6),
            Text(
              'tagline'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
            ).fadeInSlideUp(delay: 180.ms),
          ],
        ),
      ),
    );
  }
}
