import 'package:flutter/material.dart';

abstract final class AppColors {
  /// اللون الأزرق الملكي المعتمد لنادي تضامن حضرموت (#0F48A2)
  static const Color royalBlue = Color(0xFF0F48A2);
  static const Color royalBlueDark = Color(0xFF0A3A85);
  static const Color interactionBlue = Color(0xFF1B59BF);

  static Color _primary = royalBlue;
  static Color _primaryDark = royalBlueDark;
  static Color _interaction = interactionBlue;

  /// اللون الأساسي للنادي المعتمد حالياً (ديناميكي بحسب الثيم المختار)
  static Color get primary => _primary;
  static Color get primaryDark => _primaryDark;
  static Color get interaction => _interaction;

  /// تحديث لون وهوية النادي في كافة واجهات النظام
  static void applyThemeColor(Color primary, {Color? dark, Color? interaction}) {
    _primary = primary;
    final hsl = HSLColor.fromColor(primary);
    _primaryDark = dark ??
        hsl
            .withLightness((hsl.lightness - 0.10).clamp(0.0, 1.0))
            .toColor();
    _interaction = interaction ??
        hsl
            .withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0))
            .toColor();
  }

  /// استعادة الهوية الرسمية الافتراضية لنادي تضامن حضرموت
  static void resetToDefault() {
    _primary = royalBlue;
    _primaryDark = royalBlueDark;
    _interaction = interactionBlue;
  }

  static const Color canvas = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color borderSubtle = Color(0xFFE2E8F0);

  static const Color present = Color(0xFF15803D);
  static const Color presentBackground = Color(0xFFDCFCE7);
  static const Color excused = Color(0xFFB45309);
  static const Color excusedBackground = Color(0xFFFEF3C7);
  static const Color unexcused = Color(0xFFB91C1C);
  static const Color unexcusedBackground = Color(0xFFFEE2E2);
  static const Color session = Color(0xFF4338CA);
  static const Color sessionBackground = Color(0xFFEEF2FF);
}
