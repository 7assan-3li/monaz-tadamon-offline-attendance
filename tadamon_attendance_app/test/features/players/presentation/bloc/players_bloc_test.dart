import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';
import 'package:tadamon_attendance_app/features/players/domain/repositories/players_repository.dart';
import 'package:tadamon_attendance_app/features/players/domain/usecases/add_player_use_case.dart';
import 'package:tadamon_attendance_app/features/players/domain/usecases/archive_player_use_case.dart';
import 'package:tadamon_attendance_app/features/players/domain/usecases/get_players_use_case.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_bloc.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_event.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_state.dart';

void main() {
  late _MemoryRepository repository;
  late PlayersBloc bloc;
  setUp(() {
    repository = _MemoryRepository([
      _player('1', 'سالم مبارك'),
      _player('2', 'علي حسن'),
    ]);
    bloc = PlayersBloc(
      GetPlayersUseCase(repository),
      AddPlayerUseCase(repository),
      ArchivePlayerUseCase(repository),
      repository,
    );
  });
  tearDown(() => bloc.close());

  blocTest<PlayersBloc, PlayersState>(
    'loads active players and filters locally by name',
    build: () => bloc,
    act: (bloc) => bloc.add(const PlayersRequested(query: 'سالم')),
    expect: () => [
      isA<PlayersLoading>(),
      isA<PlayersReady>().having((state) => state.players.length, 'count', 1),
    ],
  );

  blocTest<PlayersBloc, PlayersState>(
    'archives a player and reloads the active list',
    build: () => bloc,
    act: (bloc) => bloc.add(const PlayerArchived('1')),
    expect: () => [
      isA<PlayersReady>().having((state) => state.players.length, 'count', 1),
    ],
  );
}

ClubPlayer _player(String id, String name) {
  final now = DateTime.utc(2026, 10, 7);
  return ClubPlayer(
    id: id,
    name: name,
    teamId: 'team-1',
    joinDate: now,
    updatedAt: now,
  );
}

class _MemoryRepository implements PlayersRepository {
  _MemoryRepository(this.players);
  final List<ClubPlayer> players;
  @override
  Future<void> addPlayer(ClubPlayer player) async => players.add(player);
  @override
  Future<void> archivePlayer(String playerId) async =>
      players.removeWhere((p) => p.id == playerId);
  @override
  Future<List<ClubPlayer>> getActivePlayers({String query = ''}) async =>
      players
          .where((player) => player.name.contains(query))
          .toList(growable: false);
  @override
  Future<void> updatePlayer(ClubPlayer player) async {
    final index = players.indexWhere((item) => item.id == player.id);
    players[index] = player;
  }
}
