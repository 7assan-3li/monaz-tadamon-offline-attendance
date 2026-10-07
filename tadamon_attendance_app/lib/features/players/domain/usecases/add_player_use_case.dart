import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';
import 'package:tadamon_attendance_app/features/players/domain/repositories/players_repository.dart';

class AddPlayerUseCase {
  const AddPlayerUseCase(this._repository);
  final PlayersRepository _repository;

  Future<void> call(ClubPlayer player) async {
    if (player.name.trim().length < 3) {
      throw const FormatException('اكتب اسم اللاعب كاملاً.');
    }
    final number = player.jerseyNumber;
    if (number != null && (number < 1 || number > 99)) {
      throw const FormatException('رقم القميص يجب أن يكون بين 1 و99.');
    }
    await _repository.addPlayer(player);
  }
}
