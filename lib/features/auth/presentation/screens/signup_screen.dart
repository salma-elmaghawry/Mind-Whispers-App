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

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  int _shakeCount = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      setState(() => _shakeCount++);
      return;
    }
    context.read<AuthCubit>().register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listenWhen: (previous, current) =>
              current.action == AuthAction.register,
          listener: (context, state) {
            if (state.isSuccess && state.user != null) {
              final role = state.user!.primaryRole;
              context.pushNamedAndRemoveUntil(
                role?.homeRoute ?? Routes.unauthorized,
                predicate: (_) => false,
              );
            } else if (state.isFailure) {
              setState(() => _shakeCount++);
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
            child: KeyedSubtree(
              key: ValueKey(_shakeCount),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AddlogoPng(),
                    verticalSpace(16),
                    Text(
                      'auth.signup.title'.tr(),
                      style: AppTextStyles.font24Bold,
                    ).fadeInSlideUp(),
                    verticalSpace(8),
                    Text(
                      'auth.signup.subtitle'.tr(),
                      style: AppTextStyles.font16Normal,
                    ).fadeInSlideUp(delay: 60.ms),
                    verticalSpace(32),
                    ...AnimationBuilder.staggerColumn(
                      startIndex: 2,
                      children: [
                        AppTextField(
                          controller: _nameController,
                          label: 'auth.signup.name_label'.tr(),
                          hint: 'auth.signup.name_hint'.tr(),
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          validator: AppValidators.validateName,
                        ),
                        verticalSpace(16),
                        AppTextField(
                          controller: _emailController,
                          label: 'auth.login.email_label'.tr(),
                          hint: 'auth.login.email_hint'.tr(),
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.mail_outline_rounded),
                          validator: AppValidators.validateEmail,
                        ),
                        verticalSpace(16),
                        AppTextField(
                          controller: _passwordController,
                          label: 'auth.login.password_label'.tr(),
                          hint: 'auth.login.password_hint'.tr(),
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          validator: AppValidators.validatePassword,
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
                                state.action == AuthAction.register;
                            return AppButton(
                              label: 'auth.signup.submit'.tr(),
                              isLoading: isLoading,
                              onPressed: isLoading
                                  ? null
                                  : () => _submit(context),
                            );
                          },
                        ),
                        verticalSpace(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'auth.signup.have_account'.tr(),
                              style: AppTextStyles.font16Normal,
                            ),
                            TextButton(
                              onPressed: () =>
                                  context.pushReplacementNamed(Routes.login),
                              child: Text('auth.signup.sign_in_link'.tr()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ).fadeInSlideUp(),
            ),
          ),
        ),
      ),
    );
  }
}
