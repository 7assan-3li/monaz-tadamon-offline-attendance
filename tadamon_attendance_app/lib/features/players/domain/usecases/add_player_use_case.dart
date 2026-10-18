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
    if (number != null) {
      final active = await _repository.getActivePlayers();
      final hasDuplicate = active.any((p) =>
          p.id != player.id &&
          p.teamId == player.teamId &&
          p.jerseyNumber == number);
      if (hasDuplicate) {
        throw FormatException(
          'رقم القميص ($number) مسجل بالفعل للاعب آخر في هذا الفريق.',
        );
      }
    }
    await _repository.addPlayer(player);
  }
}
