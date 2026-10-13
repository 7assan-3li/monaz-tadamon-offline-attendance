import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/features/attendance/data/datasources/attendance_dao.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/repositories/attendance_repository.dart';

void main() {
  test(
    'locks dispatched session and rejects every later attendance write',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final now = DateTime.utc(2026, 10, 7);
      await db
          .into(db.teams)
          .insert(
            TeamsCompanion.insert(
              id: 'team-first',
              name: 'الفريق الأول',
              category: 'الفريق الأول',
              createdAt: now,
              updatedAt: now,
            ),
          );
      await db
          .into(db.players)
          .insert(
            PlayersCompanion.insert(
              id: 'p1',
              name: 'سالم مبارك',
              teamId: 'team-first',
              jerseyNumber: const Value(10),
              joinDate: now,
              updatedAt: now,
            ),
          );
      final dao = AttendanceDao(db, _Guard());
      final session = await dao.startToday('team-first');
      final dispatched = await dao.dispatch(session.sessionUuid);
      expect(dispatched.isLocked, isTrue);
      expect(dispatched.isDispatched, isTrue);
      await expectLater(
        dao.updateStatus(
          session.sessionUuid,
          'p1',
          PlayerAttendanceStatus.present,
        ),
        throwsA(isA<LockedAttendanceSessionException>()),
      );
      await expectLater(
        dao.markAllPresent(session.sessionUuid),
        throwsA(isA<LockedAttendanceSessionException>()),
      );
      await db.close();
    },
  );

  test(
    'allows starting a second session on the same day after dispatching the first',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final now = DateTime.utc(2026, 10, 7);
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
              joinDate: now,
              updatedAt: now,
            ),
          );
      final dao = AttendanceDao(db, _Guard());

      // 1. First session (evening)
      final session1 = await dao.startToday('team-first', period: 'مسائي');
      await dao.markAllPresent(session1.sessionUuid);
      final dispatched1 = await dao.dispatch(session1.sessionUuid);
      expect(dispatched1.isLocked, isTrue);

      // 2. Second session (morning) started on the same calendar day
      final session2 = await dao.startToday('team-first', period: 'صباحي');
      expect(session2.sessionUuid, isNot(session1.sessionUuid));
      expect(session2.isLocked, isFalse);
      expect(session2.period, 'صباحي');

      // 3. Second session is fully editable
      final updated2 = await dao.updateStatus(
        session2.sessionUuid,
        'p1',
        PlayerAttendanceStatus.excused,
      );
      expect(updated2.items.first.status, PlayerAttendanceStatus.excused);

      // 4. First session remains strictly locked
      await expectLater(
        dao.updateStatus(
          session1.sessionUuid,
          'p1',
          PlayerAttendanceStatus.present,
        ),
        throwsA(isA<LockedAttendanceSessionException>()),
      );

      await db.close();
    },
  );

  test(
    'supports multiple parallel drafts and lists them in getActiveDrafts',
    () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final now = DateTime.utc(2026, 10, 7);
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
              joinDate: now,
              updatedAt: now,
            ),
          );
      final dao = AttendanceDao(db, _Guard());

      // Create draft 1 (morning)
      final draft1 = await dao.createSession(
        teamId: 'team-first',
        period: 'صباحي',
      );
      // Create draft 2 (evening)
      final draft2 = await dao.createSession(
        teamId: 'team-first',
        period: 'مسائي',
      );

      final activeDrafts = await dao.getActiveDrafts(teamId: 'team-first');
      expect(activeDrafts.length, 2);
      expect(activeDrafts.map((d) => d.sessionUuid), containsAll([
        draft1.sessionUuid,
        draft2.sessionUuid,
      ]));

      // Dispatch draft 1 only
      await dao.dispatch(draft1.sessionUuid);

      final remainingDrafts = await dao.getActiveDrafts(teamId: 'team-first');
      expect(remainingDrafts.length, 1);
      expect(remainingDrafts.first.sessionUuid, draft2.sessionUuid);
      expect(remainingDrafts.first.isLocked, isFalse);

      await db.close();
    },
  );
}

class _Guard implements AttendanceWriteGuard {
  @override
  Future<void> verify() async {}
}
