class ClubTeam {
  const ClubTeam({
    required this.id,
    required this.name,
    required this.category,
    this.updatedAt,
  });
  final String id;
  final String name;
  final String category;
  final DateTime? updatedAt;
}
