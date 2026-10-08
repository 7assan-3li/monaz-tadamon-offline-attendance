import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/sync_result.dart';

sealed class SyncState {
  const SyncState();
}

final class SyncInitial extends SyncState {
  const SyncInitial();
}

final class SyncLoading extends SyncState {
  const SyncLoading();
}

final class QrGeneratedState extends SyncState {
  const QrGeneratedState({
    required this.qrData,
    required this.session,
  });

  final String qrData;
  final AttendanceSession session;
}

final class SyncSuccessState extends SyncState {
  const SyncSuccessState(this.result);
  final SyncResult result;
}

final class SyncFailureState extends SyncState {
  const SyncFailureState(this.message);
  final String message;
}
