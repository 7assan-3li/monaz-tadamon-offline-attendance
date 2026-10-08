import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/audit_log_dao.dart';

void main() {
  group('AuditLogDao (Mandatory Audit Trail & Master Approvals)', () {
    late AppDatabase db;
    late AuditLogDao dao;
    final now = DateTime.utc(2026, 10, 8, 12, 0);

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      dao = AuditLogDao(db);

      // Seed team and player
      await db.into(db.teams).insert(
            TeamsCompanion.insert(
              id: 'team-first',
              name: 'الفريق الأول',
              category: 'الفريق الأول',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.players).insert(
            PlayersCompanion.insert(
              id: 'p1',
              name: 'سالم مبارك',
              teamId: 'team-first',
              jerseyNumber: const Value(10),
              position: const Value('مهاجم'),
              joinDate: now,
              updatedAt: now,
            ),
          );

      await db.into(db.sessions).insert(
            SessionsCompanion.insert(
              sessionUuid: 'session-101',
              teamId: 'team-first',
              sessionDate: now,
              sessionHash: 'hash-101',
              status: const Value('dispatched'),
              isLocked: const Value(true),
              isDispatched: const Value(true),
            ),
          );

      await db.into(db.attendanceRecords).insert(
            AttendanceRecordsCompanion.insert(
              id: 'session-101_p1',
              sessionUuid: 'session-101',
              playerId: 'p1',
              status: 'unexcused',
            ),
          );
    });

    tearDown(() async {
      await db.close();
    });

    test('rejects exceptional edit when reason is empty or whitespace', () async {
      expect(
        () => dao.logExceptionalChange(
          sessionUuid: 'session-101',
          playerId: 'p1',
          newStatus: AttendanceStatus.excused,
          modifiedBy: 'مدير النادي',
          reason: '   ',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('records exceptional change, updates attendance, and logs audit diff', () async {
      const reason = 'تقرير طبي معتمد من عيادة النادي يثبت الإصابة';
      await dao.logExceptionalChange(
        sessionUuid: 'session-101',
        playerId: 'p1',
        newStatus: AttendanceStatus.excused,
        modifiedBy: 'مدير النادي الكابتن فائز',
        reason: reason,
      );

      // Verify attendance record updated
      final updatedRecord = await (db.select(db.attendanceRecords)
            ..where((tbl) =>
                tbl.sessionUuid.equals('session-101') & tbl.playerId.equals('p1')))
          .getSingle();

      expect(updatedRecord.status, 'excused');
      expect(updatedRecord.reason, reason);

      // Verify audit log entry
      final logs = await dao.getAuditLogs(sessionUuid: 'session-101');
      expect(logs.length, 1);
      final log = logs.first;
      expect(log.sessionUuid, 'session-101');
      expect(log.modifiedBy, 'مدير النادي الكابتن فائز');
      expect(log.reason, reason);
      expect(log.diff, contains('من: unexcused إلى: excused'));
    });

    test('approves session and sets approval metadata', () async {
      await dao.approveSession(
        sessionUuid: 'session-101',
        approvedBy: 'مدير النادي الكابتن فائز',
      );

      final session = await (db.select(db.sessions)
            ..where((tbl) => tbl.sessionUuid.equals('session-101')))
          .getSingle();

      expect(session.status, 'approved');
      expect(session.approvedBy, 'مدير النادي الكابتن فائز');
      expect(session.approvedAt, isNotNull);
    });
  });
}
