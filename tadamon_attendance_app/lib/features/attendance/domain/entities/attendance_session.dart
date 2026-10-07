import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';

class AttendanceSession {
  const AttendanceSession({
    required this.sessionUuid,
    required this.teamId,
    required this.date,
    required this.items,
    required this.isLocked,
    required this.isDispatched,
  });
  final String sessionUuid;
  final String teamId;
  final DateTime date;
  final List<PlayerAttendanceItem> items;
  final bool isLocked;
  final bool isDispatched;
  int get presentCount => items
      .where((item) => item.status == PlayerAttendanceStatus.present)
      .length;
  int get excusedCount => items
      .where((item) => item.status == PlayerAttendanceStatus.excused)
      .length;
  int get unexcusedCount => items
      .where((item) => item.status == PlayerAttendanceStatus.unexcused)
      .length;
  AttendanceSession copyWith({
    List<PlayerAttendanceItem>? items,
    bool? isLocked,
    bool? isDispatched,
  }) => AttendanceSession(
    sessionUuid: sessionUuid,
    teamId: teamId,
    date: date,
    items: items ?? this.items,
    isLocked: isLocked ?? this.isLocked,
    isDispatched: isDispatched ?? this.isDispatched,
  );
}
