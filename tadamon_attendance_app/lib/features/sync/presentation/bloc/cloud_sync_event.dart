import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';

abstract class CloudSyncEvent {
  const CloudSyncEvent();
}

class CheckCloudHealthEvent extends CloudSyncEvent {
  const CheckCloudHealthEvent();
}

class RegisterCloudDeviceEvent extends CloudSyncEvent {
  final String deviceId;
  final String deviceName;
  final String role;
  final String? clubName;
  final String? season;
  final String? primaryColorHex;

  const RegisterCloudDeviceEvent({
    required this.deviceId,
    required this.deviceName,
    required this.role,
    this.clubName,
    this.season,
    this.primaryColorHex,
  });
}

class PushMasterDataCloudEvent extends CloudSyncEvent {
  final String sourceDeviceId;
  final Map<String, dynamic> clubProfile;
  final List<Map<String, dynamic>> teams;
  final List<Map<String, dynamic>> players;
  final String? clubId;

  const PushMasterDataCloudEvent({
    required this.sourceDeviceId,
    required this.clubProfile,
    required this.teams,
    required this.players,
    this.clubId,
  });
}

class PullMasterDataCloudEvent extends CloudSyncEvent {
  final String? clubId;
  const PullMasterDataCloudEvent({this.clubId});
}

class DispatchSessionCloudEvent extends CloudSyncEvent {
  final AttendanceSession session;
  final String? clubId;
  final String? sourceDeviceId;

  const DispatchSessionCloudEvent(
    this.session, {
    this.clubId,
    this.sourceDeviceId,
  });
}

class FetchCloudSessionsEvent extends CloudSyncEvent {
  final String? teamId;
  final String? clubId;
  const FetchCloudSessionsEvent({this.teamId, this.clubId});
}

class ApproveCloudSessionEvent extends CloudSyncEvent {
  final String sessionUuid;
  final String approverDeviceId;
  const ApproveCloudSessionEvent(this.sessionUuid, {this.approverDeviceId = 'master_admin'});
}
