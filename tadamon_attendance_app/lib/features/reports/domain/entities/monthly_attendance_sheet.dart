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

final class SessionReportItem {
  const SessionReportItem({
    required this.sessionUuid,
    required this.date,
    required this.period,
    required this.location,
    required this.isApproved,
    required this.isDispatched,
    required this.isLocked,
    required this.presentCount,
    required this.excusedCount,
    required this.unexcusedCount,
    required this.lateCount,
    required this.totalPlayers,
    this.approvedBy,
    this.approvedAt,
    this.status = 'draft',
    this.playerStatuses = const {},
  });

  final String sessionUuid;
  final DateTime date;
  final String period;
  final String location;
  final bool isApproved;
  final bool isDispatched;
  final bool isLocked;
  final int presentCount;
  final int excusedCount;
  final int unexcusedCount;
  final int lateCount;
  final int totalPlayers;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String status;
  final Map<String, AttendanceStatus> playerStatuses;

  double get attendanceRate =>
      totalPlayers > 0 ? (presentCount / totalPlayers) * 100 : 0.0;
}

final class MonthlyAttendanceSheet {
  const MonthlyAttendanceSheet({
    required this.teamId,
    required this.teamName,
    required this.month,
    required this.sessionDates,
    required this.records,
    required this.totalSessions,
    this.periodLabel = 'جميع الفترات التدريبية',
    this.sessions = const [],
  });

  final String teamId;
  final String teamName;
  final DateTime month;
  final List<DateTime> sessionDates;
  final List<PlayerMonthlyRecord> records;
  final int totalSessions;
  final String periodLabel;
  final List<SessionReportItem> sessions;
}
