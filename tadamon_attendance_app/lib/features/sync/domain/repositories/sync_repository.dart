import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/sync_result.dart';

abstract interface class SyncRepository {
  Future<String> exportSessionToQr(AttendanceSession session);

  Future<SyncResult> importSessionFromQr(String qrData);

  Future<void> startP2pServer({int port = 8089});

  Future<void> stopP2pServer();

  Future<SyncResult> syncWithP2pMaster(String host, {int port = 8089});
}
