import 'package:drift/drift.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/security/pin_security.dart';
import 'package:tadamon_attendance_app/features/activation/data/datasources/license_local_data_source.dart';
import 'package:tadamon_attendance_app/features/settings/domain/entities/club_profile_settings.dart';
import 'package:tadamon_attendance_app/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._database, this._pinSecurity, [SecureValueStore? secureStore])
      : _secureStore = secureStore;

  final AppDatabase _database;
  final PinSecurity _pinSecurity;
  final SecureValueStore? _secureStore;

  static const _exportPathKey = 'reports_export_path';
  static const _autoShareKey = 'reports_auto_share_on_export';
  static const _pinLockEnabledKey = 'app_pin_lock_enabled';

  // In-memory fallback if no persistent SecureValueStore is supplied
  String? _fallbackExportPath;
  bool _fallbackAutoShare = true;
  bool _fallbackPinLockEnabled = true;

  @override
  Future<ClubProfileSettings> read() async {
    final row = await (_database.select(
      _database.clubSettings,
    )..where((t) => t.id.equals(1))).getSingleOrNull();

    String? exportPath;
    bool autoShare = true;
    bool pinLockEnabled = true;

    if (_secureStore != null) {
      exportPath = await _secureStore.read(_exportPathKey);
      final autoShareRaw = await _secureStore.read(_autoShareKey);
      if (autoShareRaw != null) {
        autoShare = autoShareRaw == 'true';
      }
      final pinLockRaw = await _secureStore.read(_pinLockEnabledKey);
      if (pinLockRaw != null) {
        pinLockEnabled = pinLockRaw == 'true';
      } else {
        pinLockEnabled = row?.pinCodeHash != null;
      }
    } else {
      exportPath = _fallbackExportPath;
      autoShare = _fallbackAutoShare;
      pinLockEnabled = _fallbackPinLockEnabled;
    }

    if (row == null) {
      return ClubProfileSettings(
        clubName: 'نادي تضامن حضرموت',
        season: 'الموسم الرياضي',
        hasPin: false,
        isPinLockEnabled: pinLockEnabled,
        reportsExportPath: exportPath,
        autoShareOnExport: autoShare,
      );
    }
    return ClubProfileSettings(
      clubName: row.clubName,
      season: row.season,
      adminName: row.adminName,
      managerName: row.managerName,
      hasPin: row.pinCodeHash != null,
      isPinLockEnabled: pinLockEnabled,
      reportsExportPath: exportPath,
      autoShareOnExport: autoShare,
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

    if (_secureStore != null) {
      if (settings.reportsExportPath != null) {
        await _secureStore.write(_exportPathKey, settings.reportsExportPath!.trim());
      }
      await _secureStore.write(_autoShareKey, settings.autoShareOnExport.toString());
      await _secureStore.write(_pinLockEnabledKey, settings.isPinLockEnabled.toString());
    } else {
      _fallbackExportPath = settings.reportsExportPath?.trim();
      _fallbackAutoShare = settings.autoShareOnExport;
      _fallbackPinLockEnabled = settings.isPinLockEnabled;
    }
  }

  @override
  Future<void> setPin(String pin) async {
    final hash = await _pinSecurity.hash(pin);
    final settings = await read();
    await save(settings.copyWith(isPinLockEnabled: true));
    await (_database.update(_database.clubSettings)
          ..where((t) => t.id.equals(1)))
        .write(ClubSettingsCompanion(pinCodeHash: Value(hash)));
    await setPinLockEnabled(true);
  }

  @override
  Future<void> removePin() async {
    await (_database.update(_database.clubSettings)
          ..where((t) => t.id.equals(1)))
        .write(const ClubSettingsCompanion(pinCodeHash: Value(null)));
    await setPinLockEnabled(false);
  }

  @override
  Future<bool> isPinLockEnabled() async {
    final settings = await read();
    return settings.isPinLockEnabled;
  }

  @override
  Future<void> setPinLockEnabled(bool enabled) async {
    if (_secureStore != null) {
      await _secureStore.write(_pinLockEnabledKey, enabled.toString());
    } else {
      _fallbackPinLockEnabled = enabled;
    }
  }

  @override
  Future<bool> verifyPin(String pin) async {
    final row = await (_database.select(
      _database.clubSettings,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (row?.pinCodeHash == null) {
      // Default founding PIN (1959) if custom PIN is not yet set
      return pin == '1959';
    }
    return _pinSecurity.verify(pin, row!.pinCodeHash!);
  }
}
