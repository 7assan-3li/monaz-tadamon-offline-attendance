import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/di/service_locator.dart';
import 'package:tadamon_attendance_app/core/presentation/design_system_gallery_screen.dart';
import 'package:tadamon_attendance_app/features/activation/data/datasources/license_local_data_source.dart';

void main() {
  setUp(() async {
    await serviceLocator.reset();
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    configureActivationDependencies(
      currentDeviceId: 'TD-TEST-0001',
      secureStore: _MemorySecureValueStore(),
    );
    await initializeCoreDependencies(database: database);
    configureAttendanceDependencies();
    configureSyncDependencies();
  });

  tearDown(() async {
    await serviceLocator.reset();
  });

  testWidgets('tapping بدء تحضير تمرين اليوم opens QuickAttendanceScreen with players', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: DesignSystemGalleryScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('بدء تحضير تمرين اليوم'), findsOneWidget);

    await tester.tap(find.text('بدء تحضير تمرين اليوم'));
    await tester.pumpAndSettle();

    expect(find.text('تحضير تمرين اليوم'), findsOneWidget);
    expect(find.text('محمد باعباد'), findsOneWidget);
    expect(find.text('تحديد الجميع حاضر'), findsOneWidget);
  });
}

class _MemorySecureValueStore implements SecureValueStore {
  final _data = <String, String>{};

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> write(String key, String value) async => _data[key] = value;
}
