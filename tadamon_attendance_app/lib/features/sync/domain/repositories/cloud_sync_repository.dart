import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/cloud_master_data.dart';

abstract interface class CloudSyncRepository {
  Future<bool> checkConnectivity();

  Future<bool> registerDevice({
    required String deviceId,
    required String deviceName,
    required String role,
    String? clubName,
    String? season,
    String? primaryColorHex,
  });

  Future<bool> pushMasterData({
    required String sourceDeviceId,
    required Map<String, dynamic> clubProfile,
    required List<Map<String, dynamic>> teams,
    required List<Map<String, dynamic>> players,
    String? clubId,
    int? versionTimestamp,
  });

  Future<CloudMasterData?> pullMasterData({String? clubId});

  Future<bool> dispatchSessionToCloud(
    AttendanceSession session, {
    String? sourceDeviceId,
    String? clubId,
  });

  Future<List<Map<String, dynamic>>> fetchDispatchedSessionsFromCloud({
    String? teamId,
    String? clubId,
  });

  Future<bool> approveSessionOnCloud(String sessionUuid, {String? approverDeviceId});
}
