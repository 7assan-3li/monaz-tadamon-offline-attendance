import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/repositories/attendance_repository.dart';

class StartTodaySessionUseCase {
  const StartTodaySessionUseCase(this.repository);
  final AttendanceRepository repository;
  Future<AttendanceSession> call(String teamId) =>
      repository.startTodaySession(teamId);
}

class MarkAllPresentUseCase {
  const MarkAllPresentUseCase(this.repository);
  final AttendanceRepository repository;
  Future<AttendanceSession> call(String id) => repository.markAllPresent(id);
}

class UpdatePlayerStatusUseCase {
  const UpdatePlayerStatusUseCase(this.repository);
  final AttendanceRepository repository;
  Future<AttendanceSession> call(
    String id,
    String playerId,
    PlayerAttendanceStatus status,
  ) => repository.updateStatus(id, playerId, status);
}

class DispatchSessionUseCase {
  const DispatchSessionUseCase(this.repository);
  final AttendanceRepository repository;
  Future<AttendanceSession> call(String id) => repository.dispatch(id);
}
