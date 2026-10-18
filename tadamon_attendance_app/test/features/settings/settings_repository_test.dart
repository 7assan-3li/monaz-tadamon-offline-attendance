import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/security/pin_security.dart';
import 'package:tadamon_attendance_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:tadamon_attendance_app/features/settings/domain/entities/club_profile_settings.dart';

void main() {
  test('persists club settings, export preferences, and verifies only the correct PIN', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = SettingsRepositoryImpl(database, PinSecurity());
    await repository.save(
      const ClubProfileSettings(
        clubName: 'نادي تضامن حضرموت',
        season: '2026–2027',
        adminName: 'إداري الفريق',
        managerName: 'مدير النادي',
        reportsExportPath: 'C:\\Tadamon_Reports',
        autoShareOnExport: false,
      ),
    );
    await repository.setPin('1959');
    final settings = await repository.read();
    expect(settings.clubName, 'نادي تضامن حضرموت');
    expect(settings.hasPin, isTrue);
    expect(settings.reportsExportPath, 'C:\\Tadamon_Reports');
    expect(settings.autoShareOnExport, isFalse);
    expect(await repository.verifyPin('1959'), isTrue);
    expect(await repository.verifyPin('0000'), isFalse);
    expect(await repository.isPinLockEnabled(), isTrue);

    await repository.setPinLockEnabled(false);
    expect(await repository.isPinLockEnabled(), isFalse);

    await repository.removePin();
    final settingsAfterRemoval = await repository.read();
    expect(settingsAfterRemoval.hasPin, isFalse);
    expect(await repository.isPinLockEnabled(), isFalse);
    // When no custom PIN is set, default PIN 1959 is accepted
    expect(await repository.verifyPin('1959'), isTrue);
    expect(await repository.verifyPin('1234'), isFalse);

    await database.close();
  });
}
