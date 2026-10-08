import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';

void main() {
  group('Drift Schema Integrity and Non-Destructive Migration Tests', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('schema version is 1 and all 8 tables are created', () async {
      expect(db.schemaVersion, 1);

      // Verify all tables are accessible without errors
      expect(await db.select(db.licenseSecurityStore).get(), isEmpty);
      expect(await db.select(db.clubSettings).get(), isEmpty);
      expect(await db.select(db.teams).get(), isEmpty);
      expect(await db.select(db.players).get(), isEmpty);
      expect(await db.select(db.sessions).get(), isEmpty);
      expect(await db.select(db.attendanceRecords).get(), isEmpty);
      expect(await db.select(db.auditLogs).get(), isEmpty);
      expect(await db.select(db.syncAuditLogs).get(), isEmpty);
    });

    test('enforces foreign key constraints strictly', () async {
      final now = DateTime.utc(2026, 10, 8);

      // Attempting to insert a player with a non-existent teamId should fail
      expect(
        () => db.into(db.players).insert(
              PlayersCompanion.insert(
                id: 'orphan-player',
                name: 'لاعب بدون فريق',
                teamId: 'non-existent-team-id',
                joinDate: now,
                updatedAt: now,
              ),
            ),
        throwsA(anything),
      );
    });

    test('maintains data integrity through schema lifecycle', () async {
      final now = DateTime.utc(2026, 10, 8);

      // Seed valid team
      await db.into(db.teams).insert(
            TeamsCompanion.insert(
              id: 'team-first',
              name: 'الفريق الأول',
              category: 'الفريق الأول',
              createdAt: now,
              updatedAt: now,
            ),
          );

      // Seed valid player
      await db.into(db.players).insert(
            PlayersCompanion.insert(
              id: 'p1',
              name: 'سالم مبارك',
              teamId: 'team-first',
              joinDate: now,
              updatedAt: now,
            ),
          );

      final players = await db.select(db.players).get();
      expect(players.length, 1);
      expect(players.first.name, 'سالم مبارك');
    });
  });
}
