import 'package:drift/drift.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/security/high_watermark_guard.dart';

abstract interface class SecureValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);
}

final class FlutterSecureValueStore implements SecureValueStore {
  FlutterSecureValueStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
}

final class LicenseLocalDataSource implements HighWatermarkStore {
  LicenseLocalDataSource({required this.database, required this.secureStore});

  static const _watermarkKey = 'license_high_watermark_utc';

  final AppDatabase database;
  final SecureValueStore secureStore;

  Future<LicenseSecurityStoreData?> readLicense() =>
      database.select(database.licenseSecurityStore).getSingleOrNull();

  Future<void> saveLicense(LicenseSecurityStoreCompanion license) async {
    await database.transaction(() async {
      await database
          .into(database.licenseSecurityStore)
          .insertOnConflictUpdate(license);
      await secureStore.write(
        _watermarkKey,
        license.highWatermarkTimestamp.value.toUtc().toIso8601String(),
      );
    });
  }

  @override
  Future<void> latchClockTampering() => database
      .update(database.licenseSecurityStore)
      .write(const LicenseSecurityStoreCompanion(tamperFlag: Value(true)));

  @override
  Future<DateTime?> readDatabaseWatermark() async =>
      (await readLicense())?.highWatermarkTimestamp;

  @override
  Future<DateTime?> readSecureWatermark() async {
    final value = await secureStore.read(_watermarkKey);
    return value == null ? null : DateTime.tryParse(value);
  }

  @override
  Future<void> writeWatermark(DateTime value) async {
    await database
        .update(database.licenseSecurityStore)
        .write(
          LicenseSecurityStoreCompanion(
            highWatermarkTimestamp: Value(value.toUtc()),
          ),
        );
    await secureStore.write(_watermarkKey, value.toUtc().toIso8601String());
  }
}
