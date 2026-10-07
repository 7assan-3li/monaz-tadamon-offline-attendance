class ClubProfileSettings {
  const ClubProfileSettings({
    required this.clubName,
    required this.season,
    this.adminName,
    this.managerName,
    this.hasPin = false,
  });
  final String clubName;
  final String season;
  final String? adminName;
  final String? managerName;
  final bool hasPin;
}
