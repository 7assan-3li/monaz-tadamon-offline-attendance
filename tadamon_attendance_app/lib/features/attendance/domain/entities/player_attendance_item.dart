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
    this.position,
    this.notes,
    this.statusTag,
  });

  final String playerId;
  final String playerName;
  final int? jerseyNumber;
  final String? position;
  final String? notes;
  final String? statusTag;
  final PlayerAttendanceStatus status;

  PlayerAttendanceItem copyWith({
    PlayerAttendanceStatus? status,
    String? position,
    String? notes,
    String? statusTag,
  }) =>
      PlayerAttendanceItem(
        playerId: playerId,
        playerName: playerName,
        jerseyNumber: jerseyNumber,
        position: position ?? this.position,
        notes: notes ?? this.notes,
        statusTag: statusTag ?? this.statusTag,
        status: status ?? this.status,
      );
}
