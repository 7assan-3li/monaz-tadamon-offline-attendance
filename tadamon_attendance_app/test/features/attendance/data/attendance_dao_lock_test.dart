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
}

class _Guard implements AttendanceWriteGuard {
  @override
  Future<void> verify() async {}
}
