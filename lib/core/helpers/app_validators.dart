import 'package:easy_localization/easy_localization.dart';

class AppValidators {
  /// Validates that the name is not empty
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'auth.signup.name_required'.tr();
    }
    return null;
  }

  /// Validates the email format using regex
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'auth.login.email_required'.tr();
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'auth.login.email_invalid'.tr();
    }
    return null;
  }

  /// Validates the password length (min 6 characters)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'auth.login.password_required'.tr();
    }

    if (value.length < 6) {
      return 'auth.login.password_length'.tr();
    }

    return null;
  }

  /// Validates that the confirm password matches the password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'auth.login.password_required'.tr();
    }

    if (value != password) {
      return 'auth.signup.password_mismatch'.tr();
    }

    return null;
  }
}
