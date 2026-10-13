class ClubProfileSettings {
  const ClubProfileSettings({
    required this.clubName,
    required this.season,
    this.adminName,
    this.managerName,
    this.hasPin = false,
    this.reportsExportPath,
    this.autoShareOnExport = true,
  });

  final String clubName;
  final String season;
  final String? adminName;
  final String? managerName;
  final bool hasPin;
  final String? reportsExportPath;
  final bool autoShareOnExport;

  ClubProfileSettings copyWith({
    String? clubName,
    String? season,
    String? adminName,
    String? managerName,
    bool? hasPin,
    String? reportsExportPath,
    bool? autoShareOnExport,
  }) {
    return ClubProfileSettings(
      clubName: clubName ?? this.clubName,
      season: season ?? this.season,
      adminName: adminName ?? this.adminName,
      managerName: managerName ?? this.managerName,
      hasPin: hasPin ?? this.hasPin,
      reportsExportPath: reportsExportPath ?? this.reportsExportPath,
      autoShareOnExport: autoShareOnExport ?? this.autoShareOnExport,
    );
  }
}
