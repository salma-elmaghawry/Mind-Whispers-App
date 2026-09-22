import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mind_whispers_app/core/animations/animations.dart';
import 'package:mind_whispers_app/core/error_handling/failures.dart';
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

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Map<String, List<String>> _serverErrors = const {};

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _serverError(String field) {
    final errors = _serverErrors[field];
    return (errors == null || errors.isEmpty) ? null : errors.first;
  }

  void _submit(BuildContext context) {
    _serverErrors = const {};
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().resetPassword(
      email: widget.email,
      otp: _otpController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onResetResult(BuildContext context, AuthState state) {
    if (state.isSuccess) {
      _showSnackBar(context, 'auth.reset.success'.tr());

      context.pushNamedAndRemoveUntil(Routes.login, predicate: (_) => false);
    } else if (state.isFailure) {
      final failure = state.failure;

      if (failure is ValidationFailure &&
          (failure.errors.containsKey('otp') ||
              failure.errors.containsKey('password'))) {
        _serverErrors = failure.errors;
        _formKey.currentState!.validate();
      } else {
        _showSnackBar(context, state.message ?? 'errors.unexpected_error'.tr());
      }
    }
  }

  void _onResendResult(BuildContext context, AuthState state) {
    if (state.isSuccess) {
      _showSnackBar(context, 'auth.reset.code_resent'.tr());
    } else if (state.isFailure) {
      _showSnackBar(context, state.message ?? 'errors.unexpected_error'.tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              current.action == AuthAction.resetPassword ||
              current.action == AuthAction.forgotPassword,
          listener: (context, state) {
            if (state.action == AuthAction.resetPassword) {
              _onResetResult(context, state);
            } else {
              _onResendResult(context, state);
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
                    'auth.reset.title'.tr(),
                    style: AppTextStyles.font24Bold,
                    textAlign: TextAlign.center,
                  ).fadeInSlideUp(),
                  verticalSpace(8),
                  Text(
                    'auth.reset.subtitle'.tr(args: [widget.email]),
                    style: AppTextStyles.font16Normal,
                    textAlign: TextAlign.center,
                  ).fadeInSlideUp(delay: 60.ms),
                  verticalSpace(32),
                  ...AnimationBuilder.staggerColumn(
                    startIndex: 2,
                    children: [
                      AppTextField(
                        controller: _otpController,
                        label: 'auth.reset.otp_label'.tr(),
                        hint: 'auth.reset.otp_hint'.tr(),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        prefixIcon: const Icon(Icons.pin_outlined),
                        validator: (value) =>
                            AppValidators.validateOtp(value) ??
                            _serverError('otp'),
                      ),
                      verticalSpace(16),
                      AppTextField(
                        controller: _passwordController,
                        label: 'auth.reset.new_password_label'.tr(),
                        hint: 'auth.reset.new_password_hint'.tr(),
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        validator: (value) =>
                            AppValidators.validatePassword(value) ??
                            _serverError('password'),
                      ),
                      verticalSpace(16),
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: 'auth.signup.confirm_password_label'.tr(),
                        hint: 'auth.signup.confirm_password_hint'.tr(),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        validator: (value) =>
                            AppValidators.validateConfirmPassword(
                              value,
                              _passwordController.text,
                            ),
                      ),
                      verticalSpace(24),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          final isLoading =
                              state.isLoading &&
                              state.action == AuthAction.resetPassword;
                          return AppButton(
                            label: 'auth.reset.submit'.tr(),
                            isLoading: isLoading,
                            onPressed: isLoading
                                ? null
                                : () => _submit(context),
                          );
                        },
                      ),
                      verticalSpace(12),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          final isResending =
                              state.isLoading &&
                              state.action == AuthAction.forgotPassword;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'auth.reset.resend_prompt'.tr(),
                                style: AppTextStyles.font16Normal,
                              ),
                              TextButton(
                                onPressed: isResending
                                    ? null
                                    : () => context
                                          .read<AuthCubit>()
                                          .forgotPassword(email: widget.email),
                                child: Text('auth.reset.resend'.tr()),
                              ),
                            ],
                          );
                        },
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
