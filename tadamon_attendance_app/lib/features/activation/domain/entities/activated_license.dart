enum ActivatedDeviceRole { masterAdmin, fieldAttendance }

final class ActivatedLicense {
  const ActivatedLicense({
    required this.deviceId,
    required this.role,
    required this.clubName,
    required this.teamName,
    required this.expiresAt,
  });

  final String deviceId;
  final ActivatedDeviceRole role;
  final String clubName;
  final String? teamName;
  final DateTime expiresAt;
}
