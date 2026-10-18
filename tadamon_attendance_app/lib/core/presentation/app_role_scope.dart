import 'package:flutter/widgets.dart';

class AppRoleScope extends InheritedWidget {
  const AppRoleScope({
    required this.isMasterAdmin,
    required super.child,
    super.key,
  });

  final bool isMasterAdmin;

  static bool _fallbackIsMaster = true;

  static bool isMaster(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppRoleScope>();
    return scope?.isMasterAdmin ?? _fallbackIsMaster;
  }

  static void setFallback(bool isMaster) {
    _fallbackIsMaster = isMaster;
  }

  @override
  bool updateShouldNotify(AppRoleScope oldWidget) =>
      isMasterAdmin != oldWidget.isMasterAdmin;
}
