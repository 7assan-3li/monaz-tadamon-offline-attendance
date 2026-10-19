class ClubProfileSettings {
  const ClubProfileSettings({
    required this.clubName,
    required this.season,
    this.adminName,
    this.managerName,
    this.hasPin = false,
    this.isPinLockEnabled = true,
    this.reportsExportPath,
    this.autoShareOnExport = true,
    this.logoPath,
    this.primaryColorHex,
    this.identityDocPath,
  });

  final String clubName;
  final String season;
  final String? adminName;
  final String? managerName;
  final bool hasPin;
  final bool isPinLockEnabled;
  final String? reportsExportPath;
  final bool autoShareOnExport;
  final String? logoPath;
  final String? primaryColorHex;
  final String? identityDocPath;

  ClubProfileSettings copyWith({
    String? clubName,
    String? season,
    String? adminName,
    String? managerName,
    bool? hasPin,
    bool? isPinLockEnabled,
    String? reportsExportPath,
    bool? autoShareOnExport,
    String? logoPath,
    String? primaryColorHex,
    String? identityDocPath,
  }) {
    return ClubProfileSettings(
      clubName: clubName ?? this.clubName,
      season: season ?? this.season,
      adminName: adminName ?? this.adminName,
      managerName: managerName ?? this.managerName,
      hasPin: hasPin ?? this.hasPin,
      isPinLockEnabled: isPinLockEnabled ?? this.isPinLockEnabled,
      reportsExportPath: reportsExportPath ?? this.reportsExportPath,
      autoShareOnExport: autoShareOnExport ?? this.autoShareOnExport,
      logoPath: logoPath ?? this.logoPath,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      identityDocPath: identityDocPath ?? this.identityDocPath,
    );
  }
}
