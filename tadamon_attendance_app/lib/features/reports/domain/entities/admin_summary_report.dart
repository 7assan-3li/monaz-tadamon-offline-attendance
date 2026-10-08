final class PlayerSummaryRow {
  const PlayerSummaryRow({
    required this.playerId,
    required this.playerName,
    required this.jerseyNumber,
    required this.position,
    required this.presentCount,
    required this.excusedAbsenceCount,
    required this.unexcusedAbsenceCount,
    required this.lateCount,
    required this.attendanceRate,
    required this.athleticEntitlementDays,
    required this.athleticDisciplineStatus,
  });

  final String playerId;
  final String playerName;
  final int jerseyNumber;
  final String position;
  final int presentCount;
  final int excusedAbsenceCount;
  final int unexcusedAbsenceCount;
  final int lateCount;
  final double attendanceRate;
  final int athleticEntitlementDays;
  final String athleticDisciplineStatus;
}

final class AdminSummaryReport {
  const AdminSummaryReport({
    required this.clubName,
    required this.season,
    required this.teamName,
    required this.month,
    required this.teamManagerName,
    required this.clubDirectorName,
    required this.totalSessions,
    required this.rows,
  });

  final String clubName;
  final String season;
  final String teamName;
  final DateTime month;
  final String teamManagerName;
  final String clubDirectorName;
  final int totalSessions;
  final List<PlayerSummaryRow> rows;
}
