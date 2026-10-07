import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/routing/app_router.dart';
import 'package:tadamon_attendance_app/core/routing/device_role_guard.dart';
import 'package:tadamon_attendance_app/core/routing/field_attendance_app_shell.dart';
import 'package:tadamon_attendance_app/core/routing/master_admin_app_shell.dart';
import 'package:tadamon_attendance_app/core/theme/app_theme.dart';

void main() {
  const guard = DeviceRoleGuard();

  test('redirects field devices away from every administrative route', () {
    for (final route in <String>[
      AppRoutes.players,
      '${AppRoutes.players}/edit',
      AppRoutes.reports,
      AppRoutes.settings,
      AppRoutes.pin,
    ]) {
      expect(
        guard.resolve(role: DeviceRole.fieldAttendance, requestedRoute: route),
        AppRoutes.fieldTodaySession,
      );
    }
  });

  test('keeps administrative routes available to the master device', () {
    expect(
      guard.resolve(
        role: DeviceRole.masterAdmin,
        requestedRoute: AppRoutes.players,
      ),
      AppRoutes.players,
    );
  });

  testWidgets('field role builds only the isolated field shell', (
    tester,
  ) async {
    final router = AppRouter(
      deviceRole: DeviceRole.fieldAttendance,
      contentBuilder: (_, _) => const Text('تمرين اليوم'),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: router.wrapWithDeviceShell(child: const Text('تمرين اليوم')),
      ),
    );

    expect(find.byType(FieldAttendanceAppShell), findsOneWidget);
    expect(find.byType(MasterAdminAppShell), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('اللاعبون'), findsNothing);
    expect(find.text('الكشوفات'), findsNothing);
    expect(find.text('الإعدادات'), findsNothing);
  });

  testWidgets('master role builds the administrative navigation shell', (
    tester,
  ) async {
    final router = AppRouter(
      deviceRole: DeviceRole.masterAdmin,
      contentBuilder: (_, _) => const Text('الرئيسية'),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: router.wrapWithDeviceShell(child: const SizedBox.shrink()),
      ),
    );

    expect(find.byType(MasterAdminAppShell), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('اللاعبون'), findsOneWidget);
    expect(find.text('الكشوفات'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);
  });
}
