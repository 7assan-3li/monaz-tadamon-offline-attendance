import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MasterAdminAppShell extends StatelessWidget {
  const MasterAdminAppShell({
    required this.child,
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  }) : assert(selectedIndex >= 0 && selectedIndex < 4);

  final Widget child;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(LucideIcons.home, size: 22),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.users, size: 22),
            label: 'اللاعبون',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.clipboardList, size: 22),
            label: 'الكشوفات',
          ),
          NavigationDestination(
            icon: Icon(LucideIcons.settings, size: 22),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}
