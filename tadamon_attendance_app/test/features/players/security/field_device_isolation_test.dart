import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/routing/device_role_guard.dart';
import 'package:tadamon_attendance_app/features/players/data/datasources/players_dao.dart';
import 'package:tadamon_attendance_app/features/players/data/repositories/players_repository_impl.dart';
import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';
import 'package:tadamon_attendance_app/features/players/domain/repositories/players_repository.dart';

void main() {
  late AppDatabase database;
  setUp(() => database = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('rejects field-device player reads and mutations', () async {
    final repository = PlayersRepositoryImpl(
      PlayersDao(database),
      DeviceRole.fieldAttendance,
    );
    final now = DateTime.utc(2026, 10, 7);
    final player = ClubPlayer(
      id: 'player-1',
      name: 'سالم مبارك',
      teamId: 'team-1',
      joinDate: now,
      updatedAt: now,
    );
    expect(
      () => repository.getActivePlayers(),
      throwsA(isA<UnauthorizedDeviceOperationException>()),
    );
    expect(
      () => repository.addPlayer(player),
      throwsA(isA<UnauthorizedDeviceOperationException>()),
    );
  });

  test('archives without deleting the player row', () async {
    final now = DateTime.utc(2026, 10, 7);
    await database
        .into(database.teams)
        .insert(
          TeamsCompanion.insert(
            id: 'team-1',
            name: 'الفريق الأول',
            category: 'الفريق الأول',
            createdAt: now,
            updatedAt: now,
          ),
        );
    final repository = PlayersRepositoryImpl(
      PlayersDao(database),
      DeviceRole.masterAdmin,
    );
    await repository.addPlayer(
      ClubPlayer(
        id: 'player-1',
        name: 'سالم مبارك',
        teamId: 'team-1',
        joinDate: now,
        updatedAt: now,
      ),
    );
    await repository.archivePlayer('player-1');
    expect(await repository.getActivePlayers(), isEmpty);
    expect(
      (await database.select(database.players).getSingle()).isArchived,
      isTrue,
    );
  });
}
