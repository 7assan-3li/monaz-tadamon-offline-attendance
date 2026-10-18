import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/repositories/attendance_repository.dart';

class StartTodaySessionUseCase {
  const StartTodaySessionUseCase(this.repository);
  final AttendanceRepository repository;
  Future<AttendanceSession> call(
    String teamId, {
    String period = 'مسائي',
    String? location,
  }) => repository.startTodaySession(
    teamId,
    period: period,
    location: location,
  );
}

class CreateSessionUseCase {
  const CreateSessionUseCase(this.repository);
  final AttendanceRepository repository;
  Future<AttendanceSession> call({
    required String teamId,
    String period = 'مسائي',
    String? location,
    String? sessionTitle,
  }) => repository.createSession(
    teamId: teamId,
    period: period,
    location: location,
    sessionTitle: sessionTitle,
  );
}

class GetActiveDraftsUseCase {
  const GetActiveDraftsUseCase(this.repository);
  final AttendanceRepository repository;
  Future<List<AttendanceSession>> call({String? teamId}) =>
      repository.getActiveDrafts(teamId: teamId);
}

class GetTodaySessionsUseCase {
  const GetTodaySessionsUseCase(this.repository);
  final AttendanceRepository repository;
  Future<List<AttendanceSession>> call({String? teamId}) =>
      repository.getTodaySessions(teamId: teamId);
}

class ReadSessionUseCase {
  const ReadSessionUseCase(this.repository);
  final AttendanceRepository repository;
  Future<AttendanceSession?> call(String sessionUuid) =>
      repository.readSession(sessionUuid);
}

class MarkAllPresentUseCase {
  const MarkAllPresentUseCase(this.repository);
  final AttendanceRepository repository;
  Future<AttendanceSession> call(
    String id, {
    bool allowAdminOverride = false,
  }) => repository.markAllPresent(id, allowAdminOverride: allowAdminOverride);
}

class UpdatePlayerStatusUseCase {
  const UpdatePlayerStatusUseCase(this.repository);
  final AttendanceRepository repository;
  Future<AttendanceSession> call(
    String id,
    String playerId,
    PlayerAttendanceStatus status, {
    bool allowAdminOverride = false,
  }) => repository.updateStatus(
    id,
    playerId,
    status,
    allowAdminOverride: allowAdminOverride,
  );
}

class DispatchSessionUseCase {
  const DispatchSessionUseCase(this.repository);
  final AttendanceRepository repository;
  Future<AttendanceSession> call(String id) => repository.dispatch(id);
}
