import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/security/pin_security.dart';
import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';
import 'package:tadamon_attendance_app/features/attendance/data/datasources/attendance_dao.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:tadamon_attendance_app/features/backup/data/datasources/backup_local_datasource.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/audit_log_dao.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/excel_report_engine.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/pdf_report_engine.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/admin_summary_report.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/monthly_attendance_sheet.dart';
import 'package:tadamon_attendance_app/features/reports/domain/usecases/calculate_entitlement_use_case.dart';
import 'package:tadamon_attendance_app/features/sync/data/datasources/qr_codec.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/dispatch_payload.dart';

class _FakeWriteGuard implements AttendanceWriteGuard {
  @override
  Future<void> verify() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Full 100% Offline Workflow Simulation (Stages 1 through 7 E2E)', () {
    late AppDatabase masterDb;
    late AppDatabase fieldDb;

    final now = DateTime.utc(2026, 10, 8, 16, 0);

    setUp(() async {
      masterDb = AppDatabase.forTesting(NativeDatabase.memory());
      fieldDb = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await masterDb.close();
      await fieldDb.close();
    });

    test('executes end-to-end air-gapped lifecycle completely offline without errors', () async {
      // =================================================================
      // STAGE 1 & 2: LICENSING & PIN SECURITY
      // =================================================================
      final pinSecurity = PinSecurity();
      const pinCode = '1969';
      final pinHash = await pinSecurity.hash(pinCode);
      expect(await pinSecurity.verify(pinCode, pinHash), isTrue);
      expect(await pinSecurity.verify('0000', pinHash), isFalse);

      await masterDb.into(masterDb.clubSettings).insert(
            ClubSettingsCompanion.insert(
              id: const Value(1),
              clubName: 'نادي تضامن حضرموت الرياضي',
              season: '2026 / 2027',
              adminName: const Value('الكابتن فائز بالرقعان'),
              managerName: const Value('سعيد بامحسون'),
              pinCodeHash: Value(pinHash),
            ),
          );

      // =================================================================
      // STAGE 3: MASTER ADMIN ROSTER SETUP
      // =================================================================
      await masterDb.into(masterDb.teams).insert(
            TeamsCompanion.insert(
              id: 'team-first',
              name: 'الفريق الأول لكرة القدم',
              category: 'الفريق الأول',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await masterDb.into(masterDb.players).insert(
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

      await masterDb.into(masterDb.players).insert(
            PlayersCompanion.insert(
              id: 'p2',
              name: 'محسن فضل العكبري',
              teamId: 'team-first',
              jerseyNumber: const Value(7),
              position: const Value('وسط'),
              joinDate: now,
              updatedAt: now,
            ),
          );

      // =================================================================
      // STAGE 4: FIELD ATTENDANCE FLOW & DISPATCH LOCK
      // =================================================================
      await fieldDb.into(fieldDb.teams).insert(
            TeamsCompanion.insert(
              id: 'team-first',
              name: 'الفريق الأول لكرة القدم',
              category: 'الفريق الأول',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await fieldDb.into(fieldDb.players).insert(
            PlayersCompanion.insert(
              id: 'p1',
              name: 'سالم مبارك بن ركيز',
              teamId: 'team-first',
              jerseyNumber: const Value(10),
              joinDate: now,
              updatedAt: now,
            ),
          );
      await fieldDb.into(fieldDb.players).insert(
            PlayersCompanion.insert(
              id: 'p2',
              name: 'محسن فضل العكبري',
              teamId: 'team-first',
              jerseyNumber: const Value(7),
              joinDate: now,
              updatedAt: now,
            ),
          );

      final attendanceDao = AttendanceDao(fieldDb, _FakeWriteGuard());
      final fieldSession = await attendanceDao.startToday('team-first');
      expect(fieldSession.items.length, 2);

      // 1-touch mark all present
      final markedSession = await attendanceDao.markAllPresent(fieldSession.sessionUuid);
      expect(markedSession.presentCount, 2);

      // Dispatch session -> immutable lock applied
      final dispatched = await attendanceDao.dispatch(fieldSession.sessionUuid);
      expect(dispatched.isLocked, isTrue);
      expect(dispatched.isDispatched, isTrue);

      // Attempting to write after dispatch lock throws error
      expect(
        () => attendanceDao.updateStatus(
          fieldSession.sessionUuid,
          'p1',
          PlayerAttendanceStatus.excused,
        ),
        throwsA(isA<LockedAttendanceSessionException>()),
      );

      // =================================================================
      // STAGE 5: OFFLINE AIR-GAP QR PAYLOAD TRANSFER
      // =================================================================
      const qrCodec = QrCodec();
      final dispatchPayload = DispatchPayload(
        sessionUuid: fieldSession.sessionUuid,
        teamId: 'team-first',
        sessionDate: now,
        sourceDeviceId: 'FIELD_DEVICE_001',
        absentees: const [],
        signature: 'dummy_sig',
      );

      final syncPayload = await qrCodec.encode(
        payload: dispatchPayload,
        pairingSecret: 'TD_SECRET_SYNC_KEY',
      );
      expect(syncPayload, isNotEmpty);

      // Master device scans/imports air-gap payload
      final importedPayload = await qrCodec.decode(
        rawData: syncPayload,
        pairingSecret: 'TD_SECRET_SYNC_KEY',
      );
      expect(importedPayload.sessionUuid, fieldSession.sessionUuid);

      // Insert dispatched session & records into Master DB
      await masterDb.into(masterDb.sessions).insert(
            SessionsCompanion.insert(
              sessionUuid: importedPayload.sessionUuid,
              teamId: importedPayload.teamId,
              sessionDate: importedPayload.sessionDate,
              sessionHash: 'hash_${importedPayload.sessionUuid}',
              status: const Value('dispatched'),
              isLocked: const Value(true),
              isDispatched: const Value(true),
            ),
          );

      for (final item in dispatched.items) {
        await masterDb.into(masterDb.attendanceRecords).insert(
              AttendanceRecordsCompanion.insert(
                id: '${importedPayload.sessionUuid}_${item.playerId}',
                sessionUuid: importedPayload.sessionUuid,
                playerId: item.playerId,
                status: item.status.value,
              ),
            );
      }

      // =================================================================
      // STAGE 6: MASTER REVIEW, MANDATORY AUDIT & OFFICIAL REPORTS
      // =================================================================
      final auditLogDao = AuditLogDao(masterDb);

      // Exceptional edit with mandatory reason
      const reason = 'ظرف عائلي طارئ معتمد من إدارة الفريق';
      await auditLogDao.logExceptionalChange(
        sessionUuid: importedPayload.sessionUuid,
        playerId: 'p2',
        newStatus: AttendanceStatus.excused,
        modifiedBy: 'مدير النادي',
        reason: reason,
      );

      // Master approves session
      await auditLogDao.approveSession(
        sessionUuid: importedPayload.sessionUuid,
        approvedBy: 'مدير النادي الكابتن فائز',
      );

      final auditLogs = await auditLogDao.getAuditLogs();
      expect(auditLogs.length, 1);
      expect(auditLogs.first.reason, reason);

      // Calculate athletic entitlement (Strict No Finance)
      const entitlementUseCase = CalculateEntitlementUseCase();
      final entitlement = entitlementUseCase(
        totalSessions: 1,
        presentCount: 1,
        excusedCount: 1,
        unexcusedCount: 0,
        lateCount: 0,
      );
      expect(entitlement.entitlementDays, 1);
      expect(entitlement.disciplineStatus, contains('مؤهل'));

      // Generate PDF & Excel binaries locally
      const pdfEngine = PdfReportEngine();
      const excelEngine = ExcelReportEngine();

      final sheet = MonthlyAttendanceSheet(
        teamId: 'team-first',
        teamName: 'الفريق الأول لكرة القدم',
        month: now,
        sessionDates: [now],
        records: const [],
        totalSessions: 1,
      );
      final pdfBytes = await pdfEngine.generateMonthlySheetPdf(sheet);
      expect(pdfBytes, isNotEmpty);

      final summaryReport = AdminSummaryReport(
        clubName: 'نادي تضامن حضرموت الرياضي',
        season: '2026 / 2027',
        teamName: 'الفريق الأول لكرة القدم',
        month: now,
        teamManagerName: 'سعيد بامحسون',
        clubDirectorName: 'الكابتن فائز بالرقعان',
        totalSessions: 1,
        rows: const [],
      );
      final excelBytes = excelEngine.generateAdminSummaryExcel(summaryReport);
      expect(excelBytes, isNotEmpty);

      // =================================================================
      // STAGE 7: USB BACKUP, SHA-256 VERIFICATION & RESTORE ISOLATION
      // =================================================================
      final backupSource = BackupLocalDataSource(masterDb);
      final backupPackage = await backupSource.createBackupPackage();

      expect(backupPackage.manifest.sha256Checksum, isNotEmpty);
      expect(backupPackage.manifest.tableCounts['players'], 2);
      expect(backupPackage.manifest.tableCounts['sessions'], 1);

      // Verify backup on a fresh restore destination
      final freshDb = AppDatabase.forTesting(NativeDatabase.memory());
      // Fresh DB has its own unique license
      await freshDb.into(freshDb.licenseSecurityStore).insert(
            LicenseSecurityStoreCompanion.insert(
              deviceId: 'NEW_DESTINATION_DEVICE',
              deviceMode: 'master',
              licenseKey: 'TD-NEW-KEY',
              clubName: 'نادي تضامن حضرموت',
              packageType: 'pro',
              activatedAt: now,
              expiresAt: now.add(const Duration(days: 365)),
              highWatermarkTimestamp: now,
              signatureProof: 'NEW_SIG_PROOF',
            ),
          );

      final freshBackupSource = BackupLocalDataSource(freshDb);
      final verification = await freshBackupSource.verifyPackage(backupPackage.rawContent);
      expect(verification.isValid, isTrue);

      await freshBackupSource.restorePackage(backupPackage.rawContent);

      // Verify data restored
      final restoredPlayers = await freshDb.select(freshDb.players).get();
      expect(restoredPlayers.length, 2);

      final restoredAuditLogs = await freshDb.select(freshDb.auditLogs).get();
      expect(restoredAuditLogs.length, 1);

      // Verify License was protected and untouched
      final destinationLicense = await freshDb.select(freshDb.licenseSecurityStore).getSingle();
      expect(destinationLicense.deviceId, 'NEW_DESTINATION_DEVICE');
      expect(destinationLicense.licenseKey, 'TD-NEW-KEY');

      await freshDb.close();
    });
  });
}
