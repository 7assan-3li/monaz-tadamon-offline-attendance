import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';

sealed class PlayersEvent {
  const PlayersEvent();
}

class PlayersRequested extends PlayersEvent {
  const PlayersRequested({this.query = ''});
  final String query;
}

class PlayerAdded extends PlayersEvent {
  const PlayerAdded(this.player);
  final ClubPlayer player;
}

class PlayerUpdated extends PlayersEvent {
  const PlayerUpdated(this.player);
  final ClubPlayer player;
}

class PlayerArchived extends PlayersEvent {
  const PlayerArchived(this.playerId);
  final String playerId;
}
