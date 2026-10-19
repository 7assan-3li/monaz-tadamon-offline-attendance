import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/theme/club_theme_service.dart';

class MasterAdminAppShell extends StatelessWidget {
  const MasterAdminAppShell({
    required this.child,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  }) : assert(selectedIndex >= 0 && selectedIndex < 5);

  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  Color get _navBarColor {
    final primary = ClubThemeService.instance.currentPrimaryColor;
    final hsl = HSLColor.fromColor(primary);
    return hsl.withLightness((hsl.lightness - 0.12).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final navColor = _navBarColor;

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navColor,
          boxShadow: [
            BoxShadow(
              color: navColor.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: navColor,
            indicatorColor: Colors.white.withValues(alpha: 0.22),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                );
              }
              return const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFBFDBFE),
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: Colors.white, size: 22);
              }
              return const IconThemeData(color: Color(0xFFBFDBFE), size: 22);
            }),
          ),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            backgroundColor: Colors.transparent,
            elevation: 0,
            destinations: const [
              NavigationDestination(
                icon: Icon(LucideIcons.home),
                label: 'الرئيسية',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.userCheck),
                label: 'التحضير',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.users),
                label: 'اللاعبون',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.fileSpreadsheet),
                label: 'التقارير',
              ),
              NavigationDestination(
                icon: Icon(LucideIcons.settings),
                label: 'الإعدادات',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
