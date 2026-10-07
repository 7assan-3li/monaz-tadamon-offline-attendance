import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';

abstract interface class AttendanceRepository {
  Future<AttendanceSession> startTodaySession(String teamId);
  Future<AttendanceSession?> readSession(String sessionUuid);
  Future<AttendanceSession> markAllPresent(String sessionUuid);
  Future<AttendanceSession> updateStatus(
    String sessionUuid,
    String playerId,
    PlayerAttendanceStatus status,
  );
  Future<AttendanceSession> dispatch(String sessionUuid);
}

class LockedAttendanceSessionException implements Exception {
  const LockedAttendanceSessionException();
  @override
  String toString() => 'التمرين مرحّل ومقفل إدارياً، ولا يمكن تعديله.';
}
