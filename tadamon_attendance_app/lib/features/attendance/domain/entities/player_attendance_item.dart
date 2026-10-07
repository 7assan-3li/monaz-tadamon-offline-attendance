enum PlayerAttendanceStatus { unmarked, present, excused, unexcused }

extension PlayerAttendanceStatusStorage on PlayerAttendanceStatus {
  String get value => name;
  PlayerAttendanceStatus get next => switch (this) {
    PlayerAttendanceStatus.unmarked => PlayerAttendanceStatus.present,
    PlayerAttendanceStatus.present => PlayerAttendanceStatus.excused,
    PlayerAttendanceStatus.excused => PlayerAttendanceStatus.unexcused,
    PlayerAttendanceStatus.unexcused => PlayerAttendanceStatus.present,
  };
}

class PlayerAttendanceItem {
  const PlayerAttendanceItem({
    required this.playerId,
    required this.playerName,
    required this.status,
    this.jerseyNumber,
  });
  final String playerId;
  final String playerName;
  final int? jerseyNumber;
  final PlayerAttendanceStatus status;
  PlayerAttendanceItem copyWith({PlayerAttendanceStatus? status}) =>
      PlayerAttendanceItem(
        playerId: playerId,
        playerName: playerName,
        jerseyNumber: jerseyNumber,
        status: status ?? this.status,
      );
}
