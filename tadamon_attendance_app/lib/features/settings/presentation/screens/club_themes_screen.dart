import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/theme/club_theme_service.dart';
import 'package:tadamon_attendance_app/features/settings/domain/entities/club_profile_settings.dart';
import 'package:tadamon_attendance_app/features/settings/presentation/bloc/settings_bloc.dart';

class ClubThemesScreen extends StatefulWidget {
  const ClubThemesScreen({
    required this.currentSettings,
    super.key,
  });

  final ClubProfileSettings currentSettings;

  @override
  State<ClubThemesScreen> createState() => _ClubThemesScreenState();
}

class _ClubThemesScreenState extends State<ClubThemesScreen> {
  late Color _selectedColor;
  late TextEditingController _hexController;

  static const List<Color> _availableColors = [
    Color(0xFF0F48A2), // Royal Blue (الافتراضي)
    Color(0xFF1D4ED8), // Vivid Blue
    Color(0xFF0284C7), // Sky Blue
    Color(0xFF0D9488), // Deep Teal
    Color(0xFF059669), // Emerald Green
    Color(0xFF16A34A), // Athletic Green
    Color(0xFF15803D), // Forest Green
    Color(0xFFD97706), // Amber Gold
    Color(0xFFEA580C), // Flame Orange
    Color(0xFFDC2626), // Crimson Red
    Color(0xFFB91C1C), // Deep Red
    Color(0xFF881337), // Maroon / Burgundy
    Color(0xFF7C3AED), // Purple
    Color(0xFF6D28D9), // Deep Violet
    Color(0xFF4338CA), // Indigo
    Color(0xFF0E7490), // Cyan
    Color(0xFFBE123C), // Rose
    Color(0xFFC2410C), // Rust
    Color(0xFF334155), // Slate Charcoal
    Color(0xFF0F172A), // Midnight Navy
  ];

  @override
  void initState() {
    super.initState();
    if (widget.currentSettings.primaryColorHex != null &&
        widget.currentSettings.primaryColorHex!.isNotEmpty) {
      _selectedColor = ClubThemeService.parseColorHex(
        widget.currentSettings.primaryColorHex!,
      );
    } else {
      _selectedColor = ClubThemeService.instance.currentPrimaryColor;
    }
    _hexController = TextEditingController(text: _colorToHex(_selectedColor));
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${(color.toARGB32() & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  void _onColorSelected(Color color) {
    setState(() {
      _selectedColor = color;
      _hexController.text = _colorToHex(color);
    });
  }

  void _applyAndSave() {
    final hex = _colorToHex(_selectedColor);
    ClubThemeService.instance.updatePrimaryColor(_selectedColor);
    context.read<SettingsBloc>().add(
          SettingsSaved(widget.currentSettings.copyWith(primaryColorHex: hex)),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم تطبيق واعتماد اللون بنجاح على كامل النظام',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.present,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hexString = _colorToHex(_selectedColor);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: _selectedColor,
        elevation: 0,
        title: const Text(
          'ألوان وثيمات التطبيق',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                // Live Mockup Preview Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSubtle),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'معاينة حية للمظهر المعتمد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              hexString,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _selectedColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Mini app UI preview
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.shield,
                                size: 13,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.currentSettings.clubName.isNotEmpty
                                    ? widget.currentSettings.clubName
                                    : 'نادي تضامن حضرموت',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'مفعل',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Palette Title
                const Text(
                  'لوحة الألوان الجاهزة (اختر اللون المطلوب):',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // Pure Colors Grid - NO CLUB NAMES OR TEXT BESIDE COLORS
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _availableColors.length,
                  itemBuilder: (context, index) {
                    final color = _availableColors[index];
                    final isSelected =
                        (color.toARGB32() & 0x00FFFFFF) ==
                        (_selectedColor.toARGB32() & 0x00FFFFFF);

                    return InkWell(
                      onTap: () => _onColorSelected(color),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.black.withValues(alpha: 0.1),
                            width: isSelected ? 3.0 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? color.withValues(alpha: 0.55)
                                  : color.withValues(alpha: 0.25),
                              blurRadius: isSelected ? 8 : 4,
                              offset: Offset(0, isSelected ? 3 : 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Center(
                                child: Icon(
                                  LucideIcons.check,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Custom Hex Code Card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black.withValues(alpha: 0.15),
                            width: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _hexController,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'رمز اللون المخصص (HEX)',
                            labelStyle: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                            ),
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                          onChanged: (val) {
                            try {
                              final parsed = ClubThemeService.parseColorHex(val);
                              setState(() {
                                _selectedColor = parsed;
                              });
                            } catch (_) {}
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Pinned Bottom Button: Apply and Confirm
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _applyAndSave,
                  icon: const Icon(LucideIcons.checkCircle, size: 20),
                  label: const Text(
                    'اعتماد وتطبيق اللون المختار',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
