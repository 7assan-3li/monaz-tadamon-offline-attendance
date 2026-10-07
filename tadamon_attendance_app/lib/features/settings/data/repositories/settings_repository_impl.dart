import 'package:drift/drift.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/security/pin_security.dart';
import 'package:tadamon_attendance_app/features/settings/domain/entities/club_profile_settings.dart';
import 'package:tadamon_attendance_app/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._database, this._pinSecurity);
  final AppDatabase _database;
  final PinSecurity _pinSecurity;

  @override
  Future<ClubProfileSettings> read() async {
    final row = await (_database.select(
      _database.clubSettings,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (row == null) {
      return const ClubProfileSettings(
        clubName: 'نادي تضامن حضرموت',
        season: 'الموسم الرياضي',
      );
    }
    return ClubProfileSettings(
      clubName: row.clubName,
      season: row.season,
      adminName: row.adminName,
      managerName: row.managerName,
      hasPin: row.pinCodeHash != null,
    );
  }

  @override
  Future<void> save(ClubProfileSettings settings) async {
    final current = await (_database.select(
      _database.clubSettings,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    await _database
        .into(_database.clubSettings)
        .insertOnConflictUpdate(
          ClubSettingsCompanion.insert(
            id: const Value(1),
            clubName: settings.clubName.trim(),
            season: settings.season.trim(),
            adminName: Value(settings.adminName?.trim()),
            managerName: Value(settings.managerName?.trim()),
            pinCodeHash: Value(current?.pinCodeHash),
          ),
        );
  }

  @override
  Future<void> setPin(String pin) async {
    final hash = await _pinSecurity.hash(pin);
    final settings = await read();
    await save(settings);
    await (_database.update(_database.clubSettings)
          ..where((t) => t.id.equals(1)))
        .write(ClubSettingsCompanion(pinCodeHash: Value(hash)));
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final row = await (_database.select(
      _database.clubSettings,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (row?.pinCodeHash == null) return false;
    return _pinSecurity.verify(pin, row!.pinCodeHash!);
  }
}
