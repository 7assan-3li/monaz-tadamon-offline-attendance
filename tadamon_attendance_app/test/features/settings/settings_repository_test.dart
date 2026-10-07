import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/security/pin_security.dart';
import 'package:tadamon_attendance_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:tadamon_attendance_app/features/settings/domain/entities/club_profile_settings.dart';

void main() {
  test('persists club settings and verifies only the correct PIN', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = SettingsRepositoryImpl(database, PinSecurity());
    await repository.save(
      const ClubProfileSettings(
        clubName: 'نادي تضامن حضرموت',
        season: '2026–2027',
        adminName: 'إداري الفريق',
        managerName: 'مدير النادي',
      ),
    );
    await repository.setPin('1959');
    final settings = await repository.read();
    expect(settings.clubName, 'نادي تضامن حضرموت');
    expect(settings.hasPin, isTrue);
    expect(await repository.verifyPin('1959'), isTrue);
    expect(await repository.verifyPin('0000'), isFalse);
    await database.close();
  });
}
