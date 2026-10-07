import 'package:tadamon_attendance_app/features/players/domain/repositories/players_repository.dart';

class ArchivePlayerUseCase {
  const ArchivePlayerUseCase(this._repository);
  final PlayersRepository _repository;
  Future<void> call(String playerId) => _repository.archivePlayer(playerId);
}
