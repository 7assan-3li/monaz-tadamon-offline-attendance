import 'package:tadamon_attendance_app/features/attendance/data/datasources/attendance_dao.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  const AttendanceRepositoryImpl(this._dao);
  final AttendanceDao _dao;
  @override
  Future<AttendanceSession> startTodaySession(String teamId) =>
      _dao.startToday(teamId);
  @override
  Future<AttendanceSession?> readSession(String id) => _dao.read(id);
  @override
  Future<AttendanceSession> markAllPresent(String id) =>
      _dao.markAllPresent(id);
  @override
  Future<AttendanceSession> updateStatus(
    String id,
    String playerId,
    PlayerAttendanceStatus status,
  ) => _dao.updateStatus(id, playerId, status);
  @override
  Future<AttendanceSession> dispatch(String id) => _dao.dispatch(id);
}
