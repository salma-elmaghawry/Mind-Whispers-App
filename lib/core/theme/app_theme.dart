import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mind_whispers_app/core/utils/app_text_styles.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.third,
      surface: AppColors.surfaceLight,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        labelStyle: AppTextStyles.font14Normal.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        hintStyle: AppTextStyles.font14Normal.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.font32Bold.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        displayMedium: AppTextStyles.font24Bold.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        displaySmall: AppTextStyles.font20Bold.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodyLarge: AppTextStyles.font18Normal.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodyMedium: AppTextStyles.font16Normal.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodySmall: AppTextStyles.font14Normal.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        labelLarge: AppTextStyles.font14SemiBold.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        labelMedium: AppTextStyles.font12SemiBold.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.font18Normal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.third,
      surface: AppColors.surfaceDark,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textPrimaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        labelStyle: AppTextStyles.font14Normal.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        hintStyle: AppTextStyles.font14Normal.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.font32Bold.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displayMedium: AppTextStyles.font24Bold.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displaySmall: AppTextStyles.font20Bold.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyLarge: AppTextStyles.font18Normal.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyMedium: AppTextStyles.font16Normal.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodySmall: AppTextStyles.font14Normal.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        labelLarge: AppTextStyles.font14SemiBold.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        labelMedium: AppTextStyles.font12SemiBold.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.font18Normal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
