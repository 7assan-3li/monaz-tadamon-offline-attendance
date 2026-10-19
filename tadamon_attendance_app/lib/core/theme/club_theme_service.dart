import 'package:flutter/material.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';

class ClubThemePreset {
  final String id;
  final String name;
  final Color primaryColor;
  final Color darkColor;
  final String hex;

  const ClubThemePreset({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.darkColor,
    required this.hex,
  });
}

const List<ClubThemePreset> kClubThemePresets = [
  ClubThemePreset(
    id: 'tadamon_blue',
    name: 'أزرق تضامن حضرموت (الملكي)',
    primaryColor: Color(0xFF0F48A2),
    darkColor: Color(0xFF0A3A85),
    hex: '#0F48A2',
  ),
  ClubThemePreset(
    id: 'ahli_green',
    name: 'أخضر أهلي الغيل / أهلي صنعاء',
    primaryColor: Color(0xFF047857),
    darkColor: Color(0xFF065F46),
    hex: '#047857',
  ),
  ClubThemePreset(
    id: 'shaab_red',
    name: 'أحمر شعب حضرموت / وحدة عدن',
    primaryColor: Color(0xFFDC2626),
    darkColor: Color(0xFF991B1B),
    hex: '#DC2626',
  ),
  ClubThemePreset(
    id: 'tilal_sky',
    name: 'سماوي تلال عدن',
    primaryColor: Color(0xFF0284C7),
    darkColor: Color(0xFF0369A1),
    hex: '#0284C7',
  ),
  ClubThemePreset(
    id: 'talia_amber',
    name: 'أصفر طليعة حبان / اليرموك',
    primaryColor: Color(0xFFD97706),
    darkColor: Color(0xFFB45309),
    hex: '#D97706',
  ),
  ClubThemePreset(
    id: 'modern_indigo',
    name: 'كحلي إمبراطوري',
    primaryColor: Color(0xFF1E3A8A),
    darkColor: Color(0xFF0F172A),
    hex: '#1E3A8A',
  ),
  ClubThemePreset(
    id: 'teal_sport',
    name: 'فيروزي رياضي عصري',
    primaryColor: Color(0xFF0D9488),
    darkColor: Color(0xFF115E59),
    hex: '#0D9488',
  ),
];

class ClubThemeService {
  ClubThemeService._();

  static final ClubThemeService instance = ClubThemeService._();

  final ValueNotifier<Color> primaryColorNotifier =
      ValueNotifier<Color>(AppColors.royalBlue);
  final ValueNotifier<String?> logoPathNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<String> clubNameNotifier =
      ValueNotifier<String>('تضامن حضرموت');

  Color get currentColor => primaryColorNotifier.value;
  String? get currentLogoPath => logoPathNotifier.value;
  String get currentClubName => clubNameNotifier.value;

  void setPrimaryColor(Color color) {
    AppColors.applyThemeColor(color);
    primaryColorNotifier.value = color;
  }

  void updatePrimaryColor(Color color) => setPrimaryColor(color);

  void setLogoPath(String? path) {
    logoPathNotifier.value = path;
  }

  void updateLogoPath(String? path) => setLogoPath(path);

  void setClubName(String name) {
    clubNameNotifier.value = name.trim().isEmpty ? 'تضامن حضرموت' : name.trim();
  }

  void updateClubName(String name) => setClubName(name);

  void resetToDefault() {
    setPrimaryColor(AppColors.royalBlue);
    setLogoPath(null);
  }

  static Color colorFromHex(String hexString) => parseColorHex(hexString);

  static Color parseColorHex(String? hexString, {Color fallback = AppColors.royalBlue}) {
    if (hexString == null || hexString.trim().isEmpty) {
      return fallback;
    }
    var hex = hexString.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '').trim();
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    final parsed = int.tryParse(hex, radix: 16);
    if (parsed == null) {
      return fallback;
    }
    return Color(parsed);
  }

  static String colorToHex(Color color) {
    final a = (color.a * 255).round().toRadixString(16).padLeft(2, '0');
    final r = (color.r * 255).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255).round().toRadixString(16).padLeft(2, '0');
    if (a.toLowerCase() == 'ff') {
      return '#${r.toUpperCase()}${g.toUpperCase()}${b.toUpperCase()}';
    }
    return '#${a.toUpperCase()}${r.toUpperCase()}${g.toUpperCase()}${b.toUpperCase()}';
  }
}
