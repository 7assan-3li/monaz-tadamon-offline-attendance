import 'package:drift/drift.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/repositories/attendance_repository.dart';

abstract interface class AttendanceWriteGuard {
  Future<void> verify();
}

class AttendanceDao {
  const AttendanceDao(this._database, this._guard);
  final AppDatabase _database;
  final AttendanceWriteGuard _guard;

  Future<AttendanceSession> startToday(String teamId) async {
    await _guard.verify();
    final now = DateTime.now().toUtc();
    final day =
        '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final id = 'session-$teamId-$day';
    final existing = await read(id);
    if (existing != null) return existing;
    final players =
        await (_database.select(_database.players)..where(
              (row) => row.teamId.equals(teamId) & row.isArchived.equals(false),
            ))
            .get();
    await _database.transaction(() async {
      await _database
          .into(_database.sessions)
          .insert(
            SessionsCompanion.insert(
              sessionUuid: id,
              teamId: teamId,
              sessionDate: now,
              sessionHash: 'local-$id',
            ),
          );
      for (final player in players) {
        await _database
            .into(_database.attendanceRecords)
            .insert(
              AttendanceRecordsCompanion.insert(
                id: '$id-${player.id}',
                sessionUuid: id,
                playerId: player.id,
                status: PlayerAttendanceStatus.unmarked.value,
              ),
            );
      }
    });
    return (await read(id))!;
  }

  Future<AttendanceSession?> read(String id) async {
    final session = await (_database.select(
      _database.sessions,
    )..where((row) => row.sessionUuid.equals(id))).getSingleOrNull();
    if (session == null) return null;
    final query = _database.select(_database.attendanceRecords).join([
      innerJoin(
        _database.players,
        _database.players.id.equalsExp(_database.attendanceRecords.playerId),
      ),
    ])..where(_database.attendanceRecords.sessionUuid.equals(id));
    final rows = await query.get();
    return AttendanceSession(
      sessionUuid: id,
      teamId: session.teamId,
      date: session.sessionDate,
      isLocked: session.isLocked,
      isDispatched: session.isDispatched,
      items: rows.map((row) {
        final record = row.readTable(_database.attendanceRecords);
        final player = row.readTable(_database.players);
        return PlayerAttendanceItem(
          playerId: player.id,
          playerName: player.name,
          jerseyNumber: player.jerseyNumber,
          status: PlayerAttendanceStatus.values.byName(record.status),
        );
      }).toList(),
    );
  }

  Future<AttendanceSession> markAllPresent(String id) async {
    await _ensureWritable(id);
    await (_database.update(
      _database.attendanceRecords,
    )..where((row) => row.sessionUuid.equals(id))).write(
      AttendanceRecordsCompanion(
        status: Value(PlayerAttendanceStatus.present.value),
      ),
    );
    return (await read(id))!;
  }

  Future<AttendanceSession> updateStatus(
    String id,
    String playerId,
    PlayerAttendanceStatus status,
  ) async {
    await _ensureWritable(id);
    await (_database.update(_database.attendanceRecords)..where(
          (row) => row.sessionUuid.equals(id) & row.playerId.equals(playerId),
        ))
        .write(AttendanceRecordsCompanion(status: Value(status.value)));
    return (await read(id))!;
  }

  Future<AttendanceSession> dispatch(String id) async {
    await _ensureWritable(id);
    await (_database.update(
      _database.sessions,
    )..where((row) => row.sessionUuid.equals(id))).write(
      SessionsCompanion(
        isDispatched: const Value(true),
        isLocked: const Value(true),
        dispatchedAt: Value(DateTime.now().toUtc()),
        status: const Value('dispatched'),
      ),
    );
    return (await read(id))!;
  }

  Future<void> _ensureWritable(String id) async {
    await _guard.verify();
    final session = await (_database.select(
      _database.sessions,
    )..where((row) => row.sessionUuid.equals(id))).getSingle();
    if (session.isLocked || session.isDispatched) {
      throw const LockedAttendanceSessionException();
    }
  }
}
