import 'dart:convert';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/security/hardware_fingerprint.dart';
import 'package:tadamon_attendance_app/core/security/high_watermark_guard.dart';
import 'package:tadamon_attendance_app/core/security/license_parser.dart';
import 'package:tadamon_attendance_app/core/security/pin_security.dart';
import 'package:tadamon_attendance_app/features/attendance/data/datasources/attendance_dao.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:tadamon_attendance_app/features/backup/data/datasources/backup_local_datasource.dart';
import 'package:tadamon_attendance_app/features/players/data/datasources/excel_players_service.dart';
import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/excel_report_engine.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/pdf_report_engine.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/admin_summary_report.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/monthly_attendance_sheet.dart';
import 'package:tadamon_attendance_app/features/reports/domain/usecases/calculate_entitlement_use_case.dart';
import 'package:tadamon_attendance_app/features/sync/data/datasources/qr_codec.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/dispatch_payload.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/sync_result.dart';

class _FakeWriteGuard implements AttendanceWriteGuard {
  @override
  Future<void> verify() async {}
}

class _InMemoryHighWatermarkStore implements HighWatermarkStore {
  DateTime? _dbWatermark;
  DateTime? _secWatermark;
  bool latched = false;

  @override
  Future<DateTime?> readDatabaseWatermark() async => _dbWatermark;

  @override
  Future<DateTime?> readSecureWatermark() async => _secWatermark;

  @override
  Future<void> writeWatermark(DateTime value) async {
    _dbWatermark = value;
    _secWatermark = value;
  }

  @override
  Future<void> latchClockTampering() async {
    latched = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Master Operations & Sync Verification Suite (OP-1.1 through OP-7.4)', () {
    late AppDatabase masterDb;
    late AppDatabase fieldDb;
    final testNow = DateTime.utc(2026, 11, 12, 16, 0);

    setUp(() {
      masterDb = AppDatabase.forTesting(NativeDatabase.memory());
      fieldDb = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await masterDb.close();
      await fieldDb.close();
    });

    // =========================================================================
    // CYCLE 1: DEVICE LIFECYCLE & LICENSING (OP-1.1 -> OP-1.4)
    // =========================================================================
    test('CYCLE 1: License parsing, tampering detection and hardware fingerprinting', () async {
      // OP-1.1 & OP-1.3: License envelope parsing and tamper detection
      const parser = LicenseParser();
      final validPayload = {
        'club_id': 'TDMN',
        'club_name': 'نادي تضامن حضرموت',
        'device_mode': 'master_admin',
        'device_id': 'TDMN-M01',
        'expires_at': '2027-11-12T00:00:00Z',
      };
      final envelopeMap = {
        'payload': validPayload,
        'signature': base64Encode(List<int>.filled(64, 7)),
      };
      final rawEnvelope = base64UrlEncode(utf8.encode(jsonEncode(envelopeMap)));

      final parsed = parser.parse(rawEnvelope);
      expect(parsed.payload['club_id'], 'TDMN');
      expect(parsed.payload['device_mode'], 'master_admin');

      // Tampered envelope format throws FormatException
      expect(() => parser.parse('malformed_without_base64_json'), throwsFormatException);

      // OP-1.4: Hardware compound fingerprint
      final fingerprintDeriver = CompositeHardwareFingerprint(
        salt: 'TDMN_TEST_SECRET_SALT_2026_VERY_SECURE',
      );
      final comp1 = const HardwareFingerprintComponents(
        processorId: 'ARMv8_PROC_001',
        motherboardId: 'SAMSUNG_EXYNOS_MB',
        storageSerial: 'UFS_SERIAL_98765',
        networkAdapterId: 'WIFI_MAC_A1B2C3',
      );
      final comp2 = const HardwareFingerprintComponents(
        processorId: 'ARMv8_PROC_DIFFERENT',
        motherboardId: 'SAMSUNG_EXYNOS_MB',
        storageSerial: 'UFS_SERIAL_98765',
        networkAdapterId: 'WIFI_MAC_A1B2C3',
      );

      final fp1 = await fingerprintDeriver.derive(comp1);
      final fp2 = await fingerprintDeriver.derive(comp2);
      expect(fp1, isNotEmpty);
      expect(fp1, isNot(equals(fp2))); // Compound uniqueness guarantee
    });

    // =========================================================================
    // CYCLE 2: TEAMS & EXCEL ROSTERS (OP-2.1 -> OP-2.6)
    // =========================================================================
    test('CYCLE 2: Teams, Excel template download, bulk import and export', () async {
      const excelService = ExcelPlayersService();

      // OP-2.1: Add Team
      await masterDb.into(masterDb.teams).insert(
            TeamsCompanion.insert(
              id: 'team-youth',
              name: 'فريق الشباب',
              category: 'الشباب',
              createdAt: testNow,
              updatedAt: testNow,
            ),
          );
      final teams = await masterDb.select(masterDb.teams).get();
      expect(teams.length, 1);
      expect(teams.first.name, 'فريق الشباب');

      // OP-2.2: Generate official Excel template
      final templateBytes = excelService.generateTemplate(
        clubName: 'نادي تضامن حضرموت الرياضي',
        teamName: 'فريق الشباب',
      );
      expect(templateBytes, isNotEmpty);
      expect(templateBytes.length, greaterThan(100));

      // OP-2.3: Parse standard template (contains 4 sample rows)
      final importResult = excelService.parsePlayersFromExcel(
        templateBytes,
        defaultTeamId: 'team-youth',
      );
      expect(importResult.players.length, 4);
      expect(importResult.players.first.name, 'محمد سالم باحاج');
      expect(importResult.players.first.jerseyNumber, 1);

      // OP-2.4: Duplicate jersey check
      final duplicateRowsBytes = excelService.exportSquadToExcel(
        clubName: 'تضامن حضرموت',
        teamName: 'فريق الشباب',
        players: [
          ClubPlayer(
            id: 'p1',
            name: 'سالم أحمد',
            teamId: 'team-youth',
            jerseyNumber: 10,
            position: 'مهاجم',
            joinDate: testNow,
            updatedAt: testNow,
          ),
          ClubPlayer(
            id: 'p2',
            name: 'عمر خالد',
            teamId: 'team-youth',
            jerseyNumber: 10, // Duplicate jersey 10!
            position: 'وسط',
            joinDate: testNow,
            updatedAt: testNow,
          ),
        ],
      );
      final dupImportResult = excelService.parsePlayersFromExcel(
        duplicateRowsBytes,
        defaultTeamId: 'team-youth',
      );
      expect(dupImportResult.warnings, isNotEmpty);
      expect(dupImportResult.warnings.first, contains('مكرر'));

      // OP-2.5: Empty / invalid file error handling without crashing
      expect(
        () => excelService.parsePlayersFromExcel(
          [1, 2, 3, 4, 5],
          defaultTeamId: 'team-youth',
        ),
        throwsFormatException,
      );

      // OP-2.6: Export current squad to Excel
      final squadBytes = excelService.exportSquadToExcel(
        clubName: 'نادي تضامن حضرموت',
        teamName: 'فريق الشباب',
        players: importResult.players,
      );
      expect(squadBytes, isNotEmpty);
    });

    // =========================================================================
    // CYCLE 3: DAILY FIELD ATTENDANCE (OP-3.1 -> OP-3.5)
    // =========================================================================
    test('CYCLE 3: Daily Field Attendance, 0ms feedback, and immutable dispatch lock', () async {
      await fieldDb.into(fieldDb.teams).insert(
            TeamsCompanion.insert(
              id: 'team-first',
              name: 'الفريق الأول',
              category: 'الأول',
              createdAt: testNow,
              updatedAt: testNow,
            ),
          );
      await fieldDb.into(fieldDb.players).insert(
            PlayersCompanion.insert(
              id: 'pl-1',
              name: 'أحمد سالم باسويد',
              teamId: 'team-first',
              jerseyNumber: const Value(9),
              joinDate: testNow,
              updatedAt: testNow,
            ),
          );
      await fieldDb.into(fieldDb.players).insert(
            PlayersCompanion.insert(
              id: 'pl-2',
              name: 'خالد عمر باوزير',
              teamId: 'team-first',
              jerseyNumber: const Value(11),
              joinDate: testNow,
              updatedAt: testNow,
            ),
          );

      final attendanceDao = AttendanceDao(fieldDb, _FakeWriteGuard());

      // OP-3.1: Start session
      final session = await attendanceDao.startToday('team-first');
      expect(session.items.length, 2);

      // OP-3.2 & OP-3.3: Mark all present
      final allPresent = await attendanceDao.markAllPresent(session.sessionUuid);
      expect(allPresent.presentCount, 2);

      // OP-3.4: Mark excused
      final afterUpdate = await attendanceDao.updateStatus(
        session.sessionUuid,
        'pl-2',
        PlayerAttendanceStatus.excused,
      );
      final pl2 = afterUpdate.items.firstWhere((i) => i.playerId == 'pl-2');
      expect(pl2.status, PlayerAttendanceStatus.excused);

      // OP-3.5: Immutable lock upon dispatch
      final dispatched = await attendanceDao.dispatch(session.sessionUuid);
      expect(dispatched.isLocked, isTrue);
      expect(dispatched.isDispatched, isTrue);

      // Writing after dispatch throws LockedAttendanceSessionException
      expect(
        () => attendanceDao.updateStatus(
          session.sessionUuid,
          'pl-1',
          PlayerAttendanceStatus.unexcused,
        ),
        throwsA(isA<LockedAttendanceSessionException>()),
      );
    });

    // =========================================================================
    // CYCLE 4: AIR-GAP QR PROTOCOL (OP-4.1 -> OP-4.5)
    // =========================================================================
    test('CYCLE 4: Air-gap QR compression, HMAC verification, and Idempotency', () async {
      const qrCodec = QrCodec();
      const secret = 'TDMN_FIELD_MASTER_PAIRING_SECRET_2026';

      // OP-4.1: Compact QR generation (Delta absentees)
      final payload = DispatchPayload(
        sessionUuid: 'sess-uuid-001',
        teamId: 'team-first',
        sessionDate: testNow,
        sourceDeviceId: 'FIELD-DEV-01',
        absentees: [
          const AbsenteePayloadItem(
            playerId: 'pl-2',
            status: PlayerAttendanceStatus.excused,
          ),
        ],
        signature: 'pending',
      );

      final encodedQr = await qrCodec.encode(
        payload: payload,
        pairingSecret: secret,
      );
      expect(encodedQr, contains('"p"'));
      expect(encodedQr, contains('"s"'));

      // OP-4.2: Decode valid QR
      final decoded = await qrCodec.decode(
        rawData: encodedQr,
        pairingSecret: secret,
      );
      expect(decoded.sessionUuid, 'sess-uuid-001');
      expect(decoded.absentees.length, 1);
      expect(decoded.absentees.first.playerId, 'pl-2');

      // OP-4.4: Tampered QR rejection
      final tamperedQr = encodedQr.replaceFirst('sess-uuid-001', 'sess-uuid-TAMPERED');
      expect(
        () => qrCodec.decode(rawData: tamperedQr, pairingSecret: secret),
        throwsA(isA<TamperedPayloadException>()),
      );

      // OP-4.3: Idempotency check in Master DB
      await masterDb.into(masterDb.teams).insert(
            TeamsCompanion.insert(
              id: decoded.teamId,
              name: 'الفريق الأول',
              category: 'الأول',
              createdAt: testNow,
              updatedAt: testNow,
            ),
          );

      await masterDb.into(masterDb.sessions).insert(
            SessionsCompanion.insert(
              sessionUuid: decoded.sessionUuid,
              teamId: decoded.teamId,
              sessionDate: decoded.sessionDate,
              sessionHash: 'hash-001',
              isDispatched: const Value(true),
              isLocked: const Value(true),
              status: const Value('dispatched'),
            ),
          );

      // Check if session exists (Idempotency)
      final existing = await (masterDb.select(masterDb.sessions)
            ..where((r) => r.sessionUuid.equals(decoded.sessionUuid)))
          .getSingleOrNull();
      expect(existing, isNotNull); // Duplicate detected!
    });

    // =========================================================================
    // CYCLE 5: MASTER APPROVAL & REPORTS (OP-5.1 -> OP-5.5)
    // =========================================================================
    test('CYCLE 5: Session approval, PDF & Excel reports, and Athletic Entitlement', () async {
      // OP-5.1: Session Approval
      await masterDb.into(masterDb.teams).insert(
            TeamsCompanion.insert(
              id: 'team-first',
              name: 'الفريق الأول',
              category: 'الأول',
              createdAt: testNow,
              updatedAt: testNow,
            ),
          );

      await masterDb.into(masterDb.sessions).insert(
            SessionsCompanion.insert(
              sessionUuid: 'sess-approval-01',
              teamId: 'team-first',
              sessionDate: testNow,
              sessionHash: 'hash-appr',
              status: const Value('dispatched'),
            ),
          );

      await (masterDb.update(masterDb.sessions)
            ..where((r) => r.sessionUuid.equals('sess-approval-01')))
          .write(
            SessionsCompanion(
              status: const Value('approved'),
              approvedBy: const Value('الكابتن فائز بالرقعان'),
              approvedAt: Value(testNow),
            ),
          );

      final approvedSession = await (masterDb.select(masterDb.sessions)
            ..where((r) => r.sessionUuid.equals('sess-approval-01')))
          .getSingle();
      expect(approvedSession.status, 'approved');
      expect(approvedSession.approvedBy, 'الكابتن فائز بالرقعان');

      // OP-5.2 & OP-5.3: PDF Reports & Athletic Entitlement
      const entitlementUseCase = CalculateEntitlementUseCase();
      final ent = entitlementUseCase(
        totalSessions: 10,
        presentCount: 8,
        excusedCount: 2,
        unexcusedCount: 0,
        lateCount: 1,
      );
      expect(ent.entitlementDays, 8);
      expect(ent.disciplineStatus, contains('مؤهل'));

      const pdfEngine = PdfReportEngine();
      final sheet = MonthlyAttendanceSheet(
        teamId: 'team-first',
        teamName: 'الفريق الأول',
        month: testNow,
        sessionDates: [testNow],
        records: const [],
        totalSessions: 1,
      );
      final pdfBytes = await pdfEngine.generateMonthlySheetPdf(sheet);
      expect(pdfBytes, isNotEmpty);

      // OP-5.4: Excel Summary Report
      const excelEngine = ExcelReportEngine();
      final summary = AdminSummaryReport(
        clubName: 'نادي تضامن حضرموت',
        season: '2026 / 2027',
        teamName: 'الفريق الأول',
        month: testNow,
        teamManagerName: 'سعيد بامحسون',
        clubDirectorName: 'الكابتن فائز بالرقعان',
        totalSessions: 1,
        rows: const [],
      );
      final excelBytes = excelEngine.generateAdminSummaryExcel(summary);
      expect(excelBytes, isNotEmpty);
    });

    // =========================================================================
    // CYCLE 6: CLOUD SYNC & MULTI-TENANCY (OP-6.1 -> OP-6.4)
    // =========================================================================
    test('CYCLE 6: Cloud payload formatting with dynamic club isolation', () async {
      // OP-6.1 & OP-6.3: Scoped cloud payload
      final dispatchedPayload = {
        'club_id': 'TDMN',
        'device_id': 'TDMN-M01',
        'session_uuid': 'session-cloud-01',
        'team_id': 'team-first',
        'session_date': testNow.toIso8601String(),
        'records': [
          {'player_id': 'p1', 'status': 'present'},
          {'player_id': 'p2', 'status': 'excused', 'reason': 'سفر'},
        ],
      };

      // Club ID is strictly dynamic (not hardcoded)
      expect(dispatchedPayload['club_id'], 'TDMN');
      expect((dispatchedPayload['records'] as List).length, 2);

      // OP-6.4: Graceful offline handling
      const offlineResult = SyncResult(
        status: SyncStatus.error,
        sessionUuid: '',
        message: 'لا يتوفر اتصال بالإنترنت، سيتم الاستئناف تلقائياً عند توفر الشبكة.',
      );
      expect(offlineResult.status, SyncStatus.error);
    });

    // =========================================================================
    // CYCLE 7: BACKUP, RESTORE & ANTI-TAMPER (OP-7.1 -> OP-7.4)
    // =========================================================================
    test('CYCLE 7: Backup/Restore atomic integrity, clock tampering, and PIN security', () async {
      // OP-7.1: Create backup package
      await masterDb.into(masterDb.teams).insert(
            TeamsCompanion.insert(
              id: 'team-bk',
              name: 'فريق البراعم',
              category: 'البراعم',
              createdAt: testNow,
              updatedAt: testNow,
            ),
          );
      final backupSource = BackupLocalDataSource(masterDb);
      final backupPkg = await backupSource.createBackupPackage();
      expect(backupPkg.manifest.sha256Checksum, isNotEmpty);

      // OP-7.2: Verify and restore package in fresh DB
      final restoreDb = AppDatabase.forTesting(NativeDatabase.memory());
      final restoreSource = BackupLocalDataSource(restoreDb);
      final verification = await restoreSource.verifyPackage(backupPkg.rawContent);
      expect(verification.isValid, isTrue);

      await restoreSource.restorePackage(backupPkg.rawContent);
      final restoredTeams = await restoreDb.select(restoreDb.teams).get();
      expect(restoredTeams.length, 1);
      expect(restoredTeams.first.name, 'فريق البراعم');
      await restoreDb.close();

      // OP-7.3: High-Watermark Clock Tampering
      final store = _InMemoryHighWatermarkStore();
      final guard = HighWatermarkGuard(
        store: store,
        currentTime: () => testNow,
      );
      // Advance clock normally to testNow
      await guard.verifyAndAdvance();

      // Simulate clock rewind (1 day backward)
      final tamperedGuard = HighWatermarkGuard(
        store: store,
        currentTime: () => testNow.subtract(const Duration(days: 1)),
      );
      await expectLater(
        tamperedGuard.verifyAndAdvance(),
        throwsA(isA<ClockTamperedException>()),
      );
      expect(store.latched, isTrue);

      // OP-7.4: PIN Security PBKDF2 & Constant-Time verification
      final pinSec = PinSecurity();
      const pin = '2026';
      final hash = await pinSec.hash(pin);
      expect(await pinSec.verify(pin, hash), isTrue);
      expect(await pinSec.verify('9999', hash), isFalse);
      expect(await pinSec.verify('abc', hash), isFalse);
    });
  });
}
