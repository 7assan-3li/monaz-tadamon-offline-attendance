import 'package:flutter/material.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/constants/app_typography.dart';

abstract final class AppTheme {
  static ThemeData buildTheme([Color? primaryColor]) {
    final primary = primaryColor ?? AppColors.royalBlue;
    final secondary = AppColors.interactionBlue;

    final colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: AppColors.surface,
      secondary: secondary,
      onSecondary: AppColors.surface,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.unexcused,
      onError: AppColors.surface,
      outline: AppColors.borderSubtle,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.canvas,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        foregroundColor: AppColors.surface,
        centerTitle: false,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get light => buildTheme();
}
