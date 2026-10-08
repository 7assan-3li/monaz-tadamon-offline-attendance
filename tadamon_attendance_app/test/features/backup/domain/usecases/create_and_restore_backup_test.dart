import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/features/backup/data/datasources/backup_local_datasource.dart';
import 'package:tadamon_attendance_app/features/backup/data/repositories/backup_repository_impl.dart';
import 'package:tadamon_attendance_app/features/backup/domain/usecases/create_backup_use_case.dart';
import 'package:tadamon_attendance_app/features/backup/domain/usecases/restore_backup_use_case.dart';

void main() {
  group('Backup & Restore System (SHA-256 Verification & Security Isolation)', () {
    late AppDatabase sourceDb;
    late AppDatabase targetDb;
    late BackupLocalDataSource sourceDataSource;
    late BackupLocalDataSource targetDataSource;
    late CreateBackupUseCase createBackupUseCase;
    late RestoreBackupUseCase restoreBackupUseCase;

    final now = DateTime.utc(2026, 10, 8, 14, 0);

    setUp(() async {
      sourceDb = AppDatabase.forTesting(NativeDatabase.memory());
      targetDb = AppDatabase.forTesting(NativeDatabase.memory());

      // 1. Seed Source DB with Club Data
      await sourceDb.into(sourceDb.clubSettings).insert(
            ClubSettingsCompanion.insert(
              id: const Value(1),
              clubName: 'نادي تضامن حضرموت',
              season: '2026 / 2027',
              adminName: const Value('الكابتن فائز'),
              managerName: const Value('سعيد بامحسون'),
            ),
          );

      await sourceDb.into(sourceDb.teams).insert(
            TeamsCompanion.insert(
              id: 'team-first',
              name: 'الفريق الأول',
              category: 'الفريق الأول',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await sourceDb.into(sourceDb.players).insert(
            PlayersCompanion.insert(
              id: 'p1',
              name: 'سالم مبارك بن ركيز',
              teamId: 'team-first',
              jerseyNumber: const Value(10),
              position: const Value('مهاجم'),
              joinDate: now,
              updatedAt: now,
            ),
          );

      await sourceDb.into(sourceDb.sessions).insert(
            SessionsCompanion.insert(
              sessionUuid: 'session-101',
              teamId: 'team-first',
              sessionDate: now,
              sessionHash: 'hash-101',
              status: const Value('approved'),
              isLocked: const Value(true),
              isDispatched: const Value(true),
            ),
          );

      await sourceDb.into(sourceDb.attendanceRecords).insert(
            AttendanceRecordsCompanion.insert(
              id: 'session-101_p1',
              sessionUuid: 'session-101',
              playerId: 'p1',
              status: 'present',
            ),
          );

      // 2. Seed Target DB with ITS OWN UNIQUE LICENSE & Watermark
      await targetDb.into(targetDb.licenseSecurityStore).insert(
            LicenseSecurityStoreCompanion.insert(
              deviceId: 'TARGET_DEVICE_9999',
              deviceMode: 'master',
              licenseKey: 'TD-ORIGINAL-TARGET-LICENSE',
              clubName: 'نادي تضامن حضرموت',
              packageType: 'pro',
              activatedAt: now,
              expiresAt: now.add(const Duration(days: 365)),
              highWatermarkTimestamp: now,
              signatureProof: 'TARGET_SIGNATURE_PROOF',
            ),
          );

      sourceDataSource = BackupLocalDataSource(sourceDb);
      targetDataSource = BackupLocalDataSource(targetDb);

      createBackupUseCase = CreateBackupUseCase(BackupRepositoryImpl(sourceDataSource));
      restoreBackupUseCase = RestoreBackupUseCase(BackupRepositoryImpl(targetDataSource));
    });

    tearDown(() async {
      await sourceDb.close();
      await targetDb.close();
    });

    test('creates backup package with valid manifest and SHA-256 checksum', () async {
      final package = await createBackupUseCase();

      expect(package.manifest.clubName, 'نادي تضامن حضرموت');
      expect(package.manifest.sha256Checksum, isNotEmpty);
      expect(package.manifest.sha256Checksum.length, 64); // SHA-256 hex length
      expect(package.manifest.tableCounts['teams'], 1);
      expect(package.manifest.tableCounts['players'], 1);
      expect(package.manifest.tableCounts['sessions'], 1);

      // Verify package passes integrity check
      final verification = await restoreBackupUseCase.verify(package.rawContent);
      expect(verification.isValid, isTrue);
      expect(verification.manifest?.backupId, package.manifest.backupId);
    });

    test('rejects tampered backup package when checksum or payload does not match', () async {
      final package = await createBackupUseCase();

      // Tamper with content
      final decoded = jsonDecode(package.rawContent) as Map<String, dynamic>;
      decoded['data'] = jsonEncode({'tampered': 'malicious data injection'});
      final tamperedContent = jsonEncode(decoded);

      final verification = await restoreBackupUseCase.verify(tamperedContent);
      expect(verification.isValid, isFalse);
      expect(verification.errorMessage, contains('SHA-256'));

      expect(
        () => restoreBackupUseCase(tamperedContent),
        throwsA(isA<FormatException>()),
      );
    });

    test('restores club data into target DB while strictly preserving target license store', () async {
      final package = await createBackupUseCase();

      // Ensure target DB has no players initially
      final initialTargetPlayers = await targetDb.select(targetDb.players).get();
      expect(initialTargetPlayers, isEmpty);

      // Restore package
      await restoreBackupUseCase(package.rawContent);

      // Verify club data was restored
      final restoredPlayers = await targetDb.select(targetDb.players).get();
      expect(restoredPlayers.length, 1);
      expect(restoredPlayers.first.name, 'سالم مبارك بن ركيز');

      final restoredTeams = await targetDb.select(targetDb.teams).get();
      expect(restoredTeams.length, 1);
      expect(restoredTeams.first.name, 'الفريق الأول');

      // CRITICAL SECURITY INVARIANT:
      // Target device license MUST remain untouched!
      final targetLicense = await targetDb.select(targetDb.licenseSecurityStore).getSingle();
      expect(targetLicense.deviceId, 'TARGET_DEVICE_9999');
      expect(targetLicense.licenseKey, 'TD-ORIGINAL-TARGET-LICENSE');
      expect(targetLicense.signatureProof, 'TARGET_SIGNATURE_PROOF');
      expect(targetLicense.highWatermarkTimestamp.toUtc(), now);
    });
  });
}
