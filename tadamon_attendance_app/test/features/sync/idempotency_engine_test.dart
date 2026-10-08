import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/sync/data/datasources/qr_codec.dart';
import 'package:tadamon_attendance_app/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/dispatch_payload.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/sync_result.dart';

void main() {
  late AppDatabase database;
  late SyncRepositoryImpl syncRepository;
  const pairingSecret = 'test-pairing-secret-idempotency';

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    syncRepository = SyncRepositoryImpl(
      database: database,
      explicitPairingSecret: pairingSecret,
    );

    final now = DateTime.now().toUtc();
    // Insert Team
    await database.into(database.teams).insert(
          TeamsCompanion.insert(
            id: 'team-first',
            name: 'الفريق الأول',
            category: 'الفريق الأول',
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Insert 3 Players
    final playerIds = ['player-a', 'player-b', 'player-c'];
    for (var i = 0; i < playerIds.length; i++) {
      await database.into(database.players).insert(
            PlayersCompanion.insert(
              id: playerIds[i],
              name: 'لاعب $i',
              teamId: 'team-first',
              joinDate: now,
              updatedAt: now,
            ),
          );
    }
  });

  tearDown(() async {
    await database.close();
  });

  group('Idempotency Engine Tests (Stage 5)', () {
    test('rescan or duplicate import preserves single session and prevents record multiplication', () async {
      const codec = QrCodec();
      final payload = DispatchPayload(
        sessionUuid: 'session-idempotent-unique-uuid',
        teamId: 'team-first',
        sessionDate: DateTime.parse('2026-10-08T17:00:00Z'),
        sourceDeviceId: 'TD-FLD1-3302',
        absentees: const [
          AbsenteePayloadItem(
            playerId: 'player-b',
            status: PlayerAttendanceStatus.excused,
          ),
        ],
        signature: '',
      );

      final encoded = await codec.encode(
        payload: payload,
        pairingSecret: pairingSecret,
      );

      // 1. First Scan / Import
      final firstResult = await syncRepository.importSessionFromQr(encoded);
      expect(firstResult.status, equals(SyncStatus.success));
      expect(firstResult.importedItemsCount, equals(3));

      // 2. Second Scan / Duplicate Import
      final secondResult = await syncRepository.importSessionFromQr(encoded);
      expect(secondResult.status, equals(SyncStatus.duplicate));
      expect(secondResult.message, contains('مسجل مسبقاً'));

      // 3. Verify Database Invariant: Exactly 1 session, exactly 3 attendance records
      final allSessions = await database.select(database.sessions).get();
      expect(allSessions.length, equals(1));
      expect(allSessions.first.sessionUuid, equals('session-idempotent-unique-uuid'));

      final allRecords = await database.select(database.attendanceRecords).get();
      expect(allRecords.length, equals(3));

      // 4. Verify Sync Audit Logs: Recorded both attempts (success, then duplicate)
      final auditLogs = await database.select(database.syncAuditLogs).get();
      expect(auditLogs.length, equals(2));
      expect(auditLogs[0].status, equals('success'));
      expect(auditLogs[1].status, equals('duplicate'));
    });
  });
}
