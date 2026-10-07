import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';
import 'package:tadamon_attendance_app/features/players/domain/repositories/players_repository.dart';
import 'package:tadamon_attendance_app/features/players/domain/usecases/add_player_use_case.dart';

void main() {
  test('adds a valid player through the repository contract', () async {
    final repository = _MemoryPlayersRepository();
    final player = _player();
    await AddPlayerUseCase(repository)(player);
    expect(repository.players, [player]);
  });

  test('rejects incomplete names and invalid jersey numbers', () async {
    final useCase = AddPlayerUseCase(_MemoryPlayersRepository());
    expect(
      () => useCase(_player(name: 'س', jersey: 10)),
      throwsFormatException,
    );
    expect(() => useCase(_player(jersey: 100)), throwsFormatException);
  });
}

ClubPlayer _player({String name = 'سالم مبارك', int? jersey = 10}) {
  final now = DateTime.utc(2026, 10, 7);
  return ClubPlayer(
    id: 'player-1',
    name: name,
    teamId: 'team-1',
    jerseyNumber: jersey,
    joinDate: now,
    updatedAt: now,
  );
}

class _MemoryPlayersRepository implements PlayersRepository {
  final List<ClubPlayer> players = [];
  @override
  Future<void> addPlayer(ClubPlayer player) async => players.add(player);
  @override
  Future<void> archivePlayer(String playerId) async {}
  @override
  Future<List<ClubPlayer>> getActivePlayers({String query = ''}) async =>
      players;
  @override
  Future<void> updatePlayer(ClubPlayer player) async {}
}
