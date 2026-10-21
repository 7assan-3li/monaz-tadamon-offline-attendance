class CloudMasterData {
  final Map<String, dynamic> clubProfile;
  final int versionTimestamp;
  final String? sourceDeviceId;
  final List<Map<String, dynamic>> teams;
  final List<Map<String, dynamic>> players;

  const CloudMasterData({
    required this.clubProfile,
    required this.versionTimestamp,
    this.sourceDeviceId,
    required this.teams,
    required this.players,
  });

  factory CloudMasterData.fromJson(Map<String, dynamic> json) {
    return CloudMasterData(
      clubProfile: (json['club_profile'] as Map<String, dynamic>?) ?? {},
      versionTimestamp: (json['version_timestamp'] as num?)?.toInt() ?? 0,
      sourceDeviceId: json['source_device_id'] as String?,
      teams: ((json['teams'] as List<dynamic>?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      players: ((json['players'] as List<dynamic>?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'club_profile': clubProfile,
        'version_timestamp': versionTimestamp,
        'source_device_id': sourceDeviceId,
        'teams': teams,
        'players': players,
      };
}
