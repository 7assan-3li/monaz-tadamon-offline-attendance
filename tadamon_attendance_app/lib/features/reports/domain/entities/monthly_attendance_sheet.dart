import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';

final class PlayerMonthlyRecord {
  const PlayerMonthlyRecord({
    required this.playerId,
    required this.playerName,
    required this.jerseyNumber,
    required this.statusByDate,
    required this.presentCount,
    required this.excusedCount,
    required this.unexcusedCount,
    required this.lateCount,
    required this.athleticEntitlementDays,
  });

  final String playerId;
  final String playerName;
  final int jerseyNumber;
  final Map<DateTime, AttendanceStatus> statusByDate;
  final int presentCount;
  final int excusedCount;
  final int unexcusedCount;
  final int lateCount;
  final int athleticEntitlementDays;
}

final class MonthlyAttendanceSheet {
  const MonthlyAttendanceSheet({
    required this.teamId,
    required this.teamName,
    required this.month,
    required this.sessionDates,
    required this.records,
    required this.totalSessions,
  });

  final String teamId;
  final String teamName;
  final DateTime month;
  final List<DateTime> sessionDates;
  final List<PlayerMonthlyRecord> records;
  final int totalSessions;
}
