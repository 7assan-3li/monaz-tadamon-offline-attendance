import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/constants/app_typography.dart';
import 'package:tadamon_attendance_app/core/theme/app_theme.dart';

void main() {
  test('uses the approved Tadamon identity colors', () {
    expect(AppColors.royalBlue, const Color(0xFF0E4B94));
    expect(AppColors.interactionBlue, const Color(0xFF1E60B5));
    expect(AppColors.canvas, const Color(0xFFF8FAFC));
    expect(AppColors.present, const Color(0xFF15803D));
    expect(AppColors.excused, const Color(0xFFB45309));
    expect(AppColors.unexcused, const Color(0xFFB91C1C));
  });

  test('builds a Cairo Material 3 theme with high-contrast surfaces', () {
    final theme = AppTheme.light;

    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, AppColors.royalBlue);
    expect(theme.colorScheme.secondary, AppColors.interactionBlue);
    expect(theme.scaffoldBackgroundColor, AppColors.canvas);
    expect(theme.textTheme.bodyMedium?.fontFamily, AppTypography.fontFamily);
    expect(theme.textTheme.bodyMedium?.color, AppColors.textPrimary);
  });
}
