import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/helpers/app_validators.dart';
import 'package:mind_whispers_app/core/helpers/extensions.dart';
import 'package:mind_whispers_app/core/helpers/spacing.dart';
import 'package:mind_whispers_app/core/helpers/ui_helpers.dart';
import 'package:mind_whispers_app/core/routes/routes.dart';
import 'package:mind_whispers_app/core/widgets/app_button.dart';
import 'package:mind_whispers_app/core/widgets/app_text_field.dart';
import 'package:mind_whispers_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mind_whispers_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:mind_whispers_app/core/utils/app_text_styles.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().forgotPassword(
      email: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              current.action == AuthAction.forgotPassword &&
              (ModalRoute.of(context)?.isCurrent ?? false),
          listener: (context, state) {
            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('auth.forgot.code_sent'.tr())),
              );
              context.pushNamed(
                Routes.resetPassword,
                arguments: _emailController.text.trim(),
              );
            } else if (state.isFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message ?? 'errors.unexpected_error'.tr(),
                  ),
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 24.w,
              vertical: 24.h,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AddlogoPng(),
                  verticalSpace(16),
                  Text(
                    'auth.forgot.title'.tr(),
                    style: AppTextStyles.font24Bold,
                    textAlign: TextAlign.center,
                  ).fadeInSlideUp(),
                  verticalSpace(8),
                  Text(
                    'auth.forgot.subtitle'.tr(),
                    style: AppTextStyles.font16Normal,
                    textAlign: TextAlign.center,
                  ).fadeInSlideUp(delay: 60.ms),
                  verticalSpace(32),
                  ...AnimationBuilder.staggerColumn(
                    startIndex: 2,
                    children: [
                      AppTextField(
                        controller: _emailController,
                        label: 'auth.login.email_label'.tr(),
                        hint: 'auth.login.email_hint'.tr(),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        prefixIcon: const Icon(Icons.mail_outline_rounded),
                        validator: AppValidators.validateEmail,
                      ),
                      verticalSpace(24),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          final isLoading =
                              state.isLoading &&
                              state.action == AuthAction.forgotPassword;
                          return AppButton(
                            label: 'auth.forgot.submit'.tr(),
                            isLoading: isLoading,
                            onPressed: isLoading
                                ? null
                                : () => _submit(context),
                          );
                        },
                      ),
                      verticalSpace(12),
                      TextButton(
                        onPressed: context.pop,
                        child: Text('auth.forgot.back_to_login'.tr()),
                      ),
                    ],
                  ),
                ],
              ),
            ).fadeInSlideUp(),
          ),
        ),
      ),
    );
  }
}
