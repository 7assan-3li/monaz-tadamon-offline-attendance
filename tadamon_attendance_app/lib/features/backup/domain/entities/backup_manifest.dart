final class BackupManifest {
  const BackupManifest({
    required this.backupId,
    required this.createdAt,
    required this.appVersion,
    required this.clubName,
    required this.sha256Checksum,
    required this.tableCounts,
  });

  final String backupId;
  final DateTime createdAt;
  final String appVersion;
  final String clubName;
  final String sha256Checksum;
  final Map<String, int> tableCounts;

  Map<String, dynamic> toJson() => {
        'backup_id': backupId,
        'created_at': createdAt.toIso8601String(),
        'app_version': appVersion,
        'club_name': clubName,
        'sha256_checksum': sha256Checksum,
        'table_counts': tableCounts,
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) => BackupManifest(
        backupId: json['backup_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        appVersion: json['app_version'] as String,
        clubName: json['club_name'] as String,
        sha256Checksum: json['sha256_checksum'] as String,
        tableCounts: Map<String, int>.from(
          (json['table_counts'] as Map).map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          ),
        ),
      );
}
