class ClubPlayer {
  const ClubPlayer({
    required this.id,
    required this.name,
    required this.teamId,
    required this.joinDate,
    required this.updatedAt,
    this.jerseyNumber,
    this.position,
    this.notes,
    this.isArchived = false,
  });

  final String id;
  final String name;
  final String teamId;
  final int? jerseyNumber;
  final String? position;
  final DateTime joinDate;
  final bool isArchived;
  final String? notes;
  final DateTime updatedAt;
}
