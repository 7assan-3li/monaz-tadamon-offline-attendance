import 'package:flutter/material.dart';
import 'package:tadamon_attendance_app/core/routing/device_role_guard.dart';
import 'package:tadamon_attendance_app/core/routing/field_attendance_app_shell.dart';
import 'package:tadamon_attendance_app/core/routing/master_admin_app_shell.dart';

typedef RouteContentBuilder = Widget Function(
  BuildContext context,
  String resolvedRoute,
);

class AppRouter {
  AppRouter({
    required this.deviceRole,
    required this.contentBuilder,
    this.deviceRoleGuard = const DeviceRoleGuard(),
  });

  final DeviceRole deviceRole;
  final RouteContentBuilder contentBuilder;
  final DeviceRoleGuard deviceRoleGuard;

  Route<void> onGenerateRoute(RouteSettings settings) {
    final requestedRoute = settings.name ?? _defaultRoute;
    final resolvedRoute = deviceRoleGuard.resolve(
      role: deviceRole,
      requestedRoute: requestedRoute,
    );

    return MaterialPageRoute<void>(
      settings: RouteSettings(name: resolvedRoute),
      builder: (context) =>
          wrapWithDeviceShell(child: contentBuilder(context, resolvedRoute)),
    );
  }

  Widget wrapWithDeviceShell({required Widget child}) {
    return switch (deviceRole) {
      DeviceRole.fieldAttendance => FieldAttendanceAppShell(child: child),
      DeviceRole.masterAdmin => MasterAdminAppShell(
        selectedIndex: 0,
        onDestinationSelected: (_) {},
        child: child,
      ),
    };
  }

  String get _defaultRoute => switch (deviceRole) {
    DeviceRole.fieldAttendance => AppRoutes.fieldTodaySession,
    DeviceRole.masterAdmin => AppRoutes.masterHome,
  };
}
