import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';

sealed class PlayersState {
  const PlayersState();
}

class PlayersInitial extends PlayersState {
  const PlayersInitial();
}

class PlayersLoading extends PlayersState {
  const PlayersLoading();
}

class PlayersReady extends PlayersState {
  const PlayersReady(this.players, {this.query = ''});
  final List<ClubPlayer> players;
  final String query;
}

class PlayersFailure extends PlayersState {
  const PlayersFailure(this.message);
  final String message;
}
