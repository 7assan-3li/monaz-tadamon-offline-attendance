import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';
import 'package:tadamon_attendance_app/features/players/domain/repositories/players_repository.dart';

class GetPlayersUseCase {
  const GetPlayersUseCase(this._repository);
  final PlayersRepository _repository;
  Future<List<ClubPlayer>> call({String query = ''}) =>
      _repository.getActivePlayers(query: query);
}
