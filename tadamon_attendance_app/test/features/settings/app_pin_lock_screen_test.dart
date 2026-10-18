import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/features/settings/domain/entities/club_profile_settings.dart';
import 'package:tadamon_attendance_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:tadamon_attendance_app/features/settings/presentation/screens/app_pin_lock_screen.dart';

class _FakeSettingsRepo implements SettingsRepository {
  _FakeSettingsRepo({this.hasPin = false, this.correctPin = '1959'});

  final bool hasPin;
  final String correctPin;

  @override
  Future<ClubProfileSettings> read() async => ClubProfileSettings(
        clubName: 'نادي تضامن حضرموت',
        season: '2026–2027',
        hasPin: hasPin,
      );

  @override
  Future<bool> verifyPin(String pin) async => pin == correctPin;

  @override
  Future<bool> isPinLockEnabled() async => true;

  @override
  Future<void> removePin() async {}

  @override
  Future<void> save(ClubProfileSettings settings) async {}

  @override
  Future<void> setPin(String pin) async {}

  @override
  Future<void> setPinLockEnabled(bool enabled) async {}
}

void main() {
  testWidgets('AppPinLockScreen unlocks when entering correct 4-digit PIN',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var unlocked = false;
    final repo = _FakeSettingsRepo(hasPin: true, correctPin: '1234');

    await tester.pumpWidget(
      MaterialApp(
        home: AppPinLockScreen(
          settingsRepository: repo,
          onUnlocked: () => unlocked = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('نادي تضامن حضرموت الرياضي'), findsOneWidget);
    expect(find.text('أدخل رمز المرور السريع (PIN)'), findsOneWidget);

    // Tap 1, 2, 3, 4
    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('4'));
    await tester.pumpAndSettle();

    expect(unlocked, isTrue);
  });

  testWidgets('AppPinLockScreen shows error message on incorrect PIN',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    var unlocked = false;
    final repo = _FakeSettingsRepo(hasPin: true, correctPin: '1234');

    await tester.pumpWidget(
      MaterialApp(
        home: AppPinLockScreen(
          settingsRepository: repo,
          onUnlocked: () => unlocked = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap 0, 0, 0, 0
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.pump();

    expect(unlocked, isFalse);
    expect(find.text('رمز المرور غير صحيح، يرجى المحاولة مرة أخرى'),
        findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
  });
}
