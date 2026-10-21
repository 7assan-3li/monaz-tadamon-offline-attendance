import 'package:tadamon_attendance_app/features/sync/domain/entities/cloud_master_data.dart';

abstract class CloudSyncState {
  const CloudSyncState();
}

class CloudSyncInitial extends CloudSyncState {
  const CloudSyncInitial();
}

class CloudSyncLoading extends CloudSyncState {
  final String operation;
  const CloudSyncLoading({required this.operation});
}

class CloudHealthState extends CloudSyncState {
  final bool isOnline;
  const CloudHealthState({required this.isOnline});
}

class CloudDeviceRegisteredState extends CloudSyncState {
  final String message;
  final String deviceId;
  final String role;
  const CloudDeviceRegisteredState({
    required this.message,
    required this.deviceId,
    required this.role,
  });
}

class MasterDataPushedState extends CloudSyncState {
  final String message;
  const MasterDataPushedState({required this.message});
}

class MasterDataPulledState extends CloudSyncState {
  final String message;
  final CloudMasterData masterData;
  const MasterDataPulledState({
    required this.message,
    required this.masterData,
  });
}

class SessionDispatchedCloudState extends CloudSyncState {
  final String message;
  final String sessionUuid;
  const SessionDispatchedCloudState({
    required this.message,
    required this.sessionUuid,
  });
}

class CloudSessionsFetchedState extends CloudSyncState {
  final List<Map<String, dynamic>> sessions;
  const CloudSessionsFetchedState({required this.sessions});
}

class SessionApprovedCloudState extends CloudSyncState {
  final String message;
  final String sessionUuid;
  const SessionApprovedCloudState({
    required this.message,
    required this.sessionUuid,
  });
}

class CloudSyncFailure extends CloudSyncState {
  final String error;
  const CloudSyncFailure({required this.error});
}
