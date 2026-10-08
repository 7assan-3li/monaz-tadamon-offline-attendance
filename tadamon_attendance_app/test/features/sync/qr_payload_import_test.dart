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
  const pairingSecret = 'test-pairing-secret-offline';

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

    // Insert 4 Players
    final playerIds = ['p1', 'p2', 'p3', 'p4'];
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

  group('QR Payload Import Tests (Stage 5)', () {
    test('accurately imports session and sets defaults to present while respecting absentees', () async {
      const codec = QrCodec();
      final payload = DispatchPayload(
        sessionUuid: 'session-20261008-first',
        teamId: 'team-first',
        sessionDate: DateTime.parse('2026-10-08T16:00:00Z'),
        sourceDeviceId: 'TD-FLD1-3302',
        absentees: const [
          AbsenteePayloadItem(
            playerId: 'p1',
            status: PlayerAttendanceStatus.excused,
          ),
          AbsenteePayloadItem(
            playerId: 'p2',
            status: PlayerAttendanceStatus.unexcused,
          ),
        ],
        signature: '',
      );

      final encoded = await codec.encode(
        payload: payload,
        pairingSecret: pairingSecret,
      );

      final result = await syncRepository.importSessionFromQr(encoded);

      expect(result.status, equals(SyncStatus.success));
      expect(result.importedItemsCount, equals(4));
      expect(result.sessionUuid, equals('session-20261008-first'));

      // Check Session in DB
      final savedSession = await (database.select(database.sessions)
            ..where((row) => row.sessionUuid.equals('session-20261008-first')))
          .getSingle();

      expect(savedSession.isLocked, isTrue);
      expect(savedSession.isDispatched, isTrue);
      expect(savedSession.syncStatus, equals('received'));
      expect(savedSession.status, equals('pending_approval'));

      // Check Attendance Records in DB
      final records = await (database.select(database.attendanceRecords)
            ..where((row) => row.sessionUuid.equals('session-20261008-first')))
          .get();

      expect(records.length, equals(4));

      final recordMap = {for (final r in records) r.playerId: r.status};
      expect(recordMap['p1'], equals(PlayerAttendanceStatus.excused.value));
      expect(recordMap['p2'], equals(PlayerAttendanceStatus.unexcused.value));
      expect(recordMap['p3'], equals(PlayerAttendanceStatus.present.value)); // defaulted to present
      expect(recordMap['p4'], equals(PlayerAttendanceStatus.present.value)); // defaulted to present

      // Check Sync Audit Logs
      final auditLogs = await database.select(database.syncAuditLogs).get();
      expect(auditLogs.length, equals(1));
      expect(auditLogs.first.sessionUuid, equals('session-20261008-first'));
      expect(auditLogs.first.status, equals('success'));
      expect(auditLogs.first.syncDirection, equals('field_to_master'));
    });
  });
}
