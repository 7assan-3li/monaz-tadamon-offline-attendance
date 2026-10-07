import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';

abstract interface class PlayersRepository {
  Future<List<ClubPlayer>> getActivePlayers({String query = ''});
  Future<void> addPlayer(ClubPlayer player);
  Future<void> updatePlayer(ClubPlayer player);
  Future<void> archivePlayer(String playerId);
}

class UnauthorizedDeviceOperationException implements Exception {
  const UnauthorizedDeviceOperationException();

  @override
  String toString() => 'هذه العملية متاحة في جهاز الإدارة فقط.';
}
