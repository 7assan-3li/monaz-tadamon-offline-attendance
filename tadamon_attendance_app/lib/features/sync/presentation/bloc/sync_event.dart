import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';

sealed class SyncEvent {
  const SyncEvent();
}

final class GenerateQrRequested extends SyncEvent {
  const GenerateQrRequested(this.session);
  final AttendanceSession session;
}

final class ImportQrRequested extends SyncEvent {
  const ImportQrRequested(this.qrData);
  final String qrData;
}

final class StartP2pServerRequested extends SyncEvent {
  const StartP2pServerRequested({this.port = 8089});
  final int port;
}

final class StopP2pServerRequested extends SyncEvent {
  const StopP2pServerRequested();
}

final class SyncWithMasterRequested extends SyncEvent {
  const SyncWithMasterRequested(this.host, {this.port = 8089});
  final String host;
  final int port;
}
