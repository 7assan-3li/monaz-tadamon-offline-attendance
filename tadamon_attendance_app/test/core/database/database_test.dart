import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/database/connection/native.dart';
import 'package:tadamon_attendance_app/core/di/service_locator.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    if (serviceLocator.isRegistered<AppDatabase>()) {
      await resetCoreDependencies();
    } else {
      await database.close();
    }
  });

  test('creates every approved Phase 1 table in memory', () async {
    final tableRows = await database
        .customSelect(
          "SELECT name FROM sqlite_master "
          "WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
        )
        .get();
    final tableNames = tableRows.map((row) => row.read<String>('name')).toSet();

    expect(
      tableNames,
      containsAll(<String>{
        'license_security_store',
        'club_settings',
        'teams',
        'players',
        'sessions',
        'attendance_records',
        'audit_logs',
        'sync_audit_logs',
      }),
    );
  });

  test(
    'stores attendance records and preserves dispatch lock defaults',
    () async {
      final timestamp = DateTime.utc(2026, 10, 7, 18);

      await database
          .into(database.teams)
          .insert(
            TeamsCompanion.insert(
              id: 'team-first',
              name: 'الفريق الأول',
              category: 'الفريق الأول',
              createdAt: timestamp,
              updatedAt: timestamp,
            ),
          );
      await database
          .into(database.players)
          .insert(
            PlayersCompanion.insert(
              id: 'player-10',
              name: 'سالم مبارك',
              teamId: 'team-first',
              jerseyNumber: const Value(10),
              joinDate: timestamp,
              updatedAt: timestamp,
            ),
          );
      await database
          .into(database.sessions)
          .insert(
            SessionsCompanion.insert(
              sessionUuid: 'session-2026-10-07',
              teamId: 'team-first',
              sessionDate: timestamp,
              sessionHash: 'sha256-placeholder',
            ),
          );
      await database
          .into(database.attendanceRecords)
          .insert(
            AttendanceRecordsCompanion.insert(
              id: 'attendance-10',
              sessionUuid: 'session-2026-10-07',
              playerId: 'player-10',
              status: 'present',
            ),
          );

      final session = await database.select(database.sessions).getSingle();
      final attendance = await database
          .select(database.attendanceRecords)
          .getSingle();

      expect(session.isDispatched, isFalse);
      expect(session.isLocked, isFalse);
      expect(session.syncStatus, 'local');
      expect(session.status, 'draft');
      expect(attendance.status, 'present');
    },
  );

  test('prevents duplicate attendance for one player and session', () async {
    final timestamp = DateTime.utc(2026, 10, 7, 18);

    await database
        .into(database.teams)
        .insert(
          TeamsCompanion.insert(
            id: 'team-first',
            name: 'الفريق الأول',
            category: 'الفريق الأول',
            createdAt: timestamp,
            updatedAt: timestamp,
          ),
        );
    await database
        .into(database.players)
        .insert(
          PlayersCompanion.insert(
            id: 'player-10',
            name: 'سالم مبارك',
            teamId: 'team-first',
            joinDate: timestamp,
            updatedAt: timestamp,
          ),
        );
    await database
        .into(database.sessions)
        .insert(
          SessionsCompanion.insert(
            sessionUuid: 'session-2026-10-07',
            teamId: 'team-first',
            sessionDate: timestamp,
            sessionHash: 'sha256-placeholder',
          ),
        );

    AttendanceRecordsCompanion attendance(String id) =>
        AttendanceRecordsCompanion.insert(
          id: id,
          sessionUuid: 'session-2026-10-07',
          playerId: 'player-10',
          status: 'present',
        );

    await database.into(database.attendanceRecords).insert(attendance('first'));

    expect(
      () => database
          .into(database.attendanceRecords)
          .insert(attendance('duplicate')),
      throwsA(isA<Exception>()),
    );
  });

  test('registers the database through the core service locator', () async {
    configureCoreDependencies(database: database);

    expect(serviceLocator<AppDatabase>(), same(database));
  });

  test('opens the registered database during application bootstrap', () async {
    await initializeCoreDependencies(database: database);

    final result = await serviceLocator<AppDatabase>()
        .customSelect('SELECT 1 AS ready')
        .getSingle();
    expect(result.read<int>('ready'), 1);
  });

  test('uses the approved persistent database file name', () {
    expect(databaseFileName, 'tadamon_attendance.sqlite');
  });
}
