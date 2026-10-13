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

  Future<AttendanceSession> createSession({
    required String teamId,
    String period = 'مسائي',
    String? location,
    String? sessionTitle,
  }) async {
    await _guard.verify();
    final now = DateTime.now().toUtc();
    final day =
        '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final id = 'session-$teamId-$day-$period-${now.millisecondsSinceEpoch}';

    final players = await (_database.select(_database.players)
          ..where(
            (row) => row.teamId.equals(teamId) & row.isArchived.equals(false),
          ))
        .get();

    await _database.transaction(() async {
      await _database.into(_database.sessions).insert(
            SessionsCompanion.insert(
              sessionUuid: id,
              teamId: teamId,
              sessionDate: now,
              period: Value(period),
              location: Value(location ?? 'ملعب بارادم'),
              sessionHash: 'local-$id',
            ),
          );
      for (final player in players) {
        await _database.into(_database.attendanceRecords).insert(
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

  Future<AttendanceSession> startToday(
    String teamId, {
    String period = 'مسائي',
    String? location,
  }) async {
    await _guard.verify();
    final drafts = await getActiveDrafts(teamId: teamId);
    final matching = drafts.where((d) => d.period == period).firstOrNull;
    if (matching != null && matching.items.isNotEmpty) {
      return matching;
    }
    if (drafts.isNotEmpty && matching == null) {
      return drafts.first;
    }
    return createSession(
      teamId: teamId,
      period: period,
      location: location,
    );
  }

  Future<List<AttendanceSession>> getActiveDrafts({String? teamId}) async {
    final query = _database.select(_database.sessions)
      ..where((row) {
        var predicate =
            row.isLocked.equals(false) & row.isDispatched.equals(false);
        if (teamId != null) {
          predicate = predicate & row.teamId.equals(teamId);
        }
        return predicate;
      })
      ..orderBy([
        (row) =>
            OrderingTerm(expression: row.sessionDate, mode: OrderingMode.desc),
      ]);
    final rows = await query.get();
    final list = <AttendanceSession>[];
    for (final row in rows) {
      final s = await read(row.sessionUuid);
      if (s != null) list.add(s);
    }
    return list;
  }

  Future<List<AttendanceSession>> getTodaySessions({String? teamId}) async {
    final now = DateTime.now().toUtc();
    final startOfDay = DateTime.utc(now.year, now.month, now.day);
    final endOfDay = DateTime.utc(now.year, now.month, now.day, 23, 59, 59);
    final query = _database.select(_database.sessions)
      ..where((row) {
        var predicate = row.sessionDate.isBiggerOrEqualValue(startOfDay) &
            row.sessionDate.isSmallerOrEqualValue(endOfDay);
        if (teamId != null) {
          predicate = predicate & row.teamId.equals(teamId);
        }
        return predicate;
      })
      ..orderBy([
        (row) =>
            OrderingTerm(expression: row.sessionDate, mode: OrderingMode.desc),
      ]);
    final rows = await query.get();
    final list = <AttendanceSession>[];
    for (final row in rows) {
      final s = await read(row.sessionUuid);
      if (s != null) list.add(s);
    }
    return list;
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
    final periodName = session.period;
    final title = periodName == 'صباحي'
        ? 'تمرين صباحي - لياقة وإعداد بدني'
        : periodName == 'إضافي'
            ? 'حصة تدريبية إضافية - تكتيك خاص'
            : 'تمرين مسائي رئيسي - جاهزية فنية';
    return AttendanceSession(
      sessionUuid: id,
      teamId: session.teamId,
      date: session.sessionDate,
      isLocked: session.isLocked,
      isDispatched: session.isDispatched,
      period: session.period,
      location: session.location ?? 'ملعب بارادم',
      sessionTitle: title,
      items: rows.map((row) {
        final record = row.readTable(_database.attendanceRecords);
        final player = row.readTable(_database.players);
        return PlayerAttendanceItem(
          playerId: player.id,
          playerName: player.name,
          jerseyNumber: player.jerseyNumber,
          position: player.position,
          notes: player.notes,
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
    )..where((row) => row.sessionUuid.equals(id))).getSingleOrNull();
    if (session == null || session.isLocked || session.isDispatched) {
      throw const LockedAttendanceSessionException();
    }
  }
}
