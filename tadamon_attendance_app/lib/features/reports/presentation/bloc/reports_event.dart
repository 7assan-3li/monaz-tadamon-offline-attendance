import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';

sealed class ReportsEvent {
  const ReportsEvent();
}

final class LoadReportsHubEvent extends ReportsEvent {
  const LoadReportsHubEvent({
    required this.teamId,
    required this.year,
    required this.month,
  });

  final String teamId;
  final int year;
  final int month;
}

final class ApproveSessionEvent extends ReportsEvent {
  const ApproveSessionEvent({
    required this.sessionUuid,
    required this.approvedBy,
  });

  final String sessionUuid;
  final String approvedBy;
}

final class SubmitExceptionalEditEvent extends ReportsEvent {
  const SubmitExceptionalEditEvent({
    required this.sessionUuid,
    required this.playerId,
    required this.newStatus,
    required this.reason,
    required this.modifiedBy,
  });

  final String sessionUuid;
  final String playerId;
  final AttendanceStatus newStatus;
  final String reason;
  final String modifiedBy;
}

final class ExportMonthlyPdfEvent extends ReportsEvent {
  const ExportMonthlyPdfEvent();
}

final class ExportAdminSummaryPdfEvent extends ReportsEvent {
  const ExportAdminSummaryPdfEvent();
}

final class ExportAdminSummaryExcelEvent extends ReportsEvent {
  const ExportAdminSummaryExcelEvent();
}

final class LoadAuditLogsEvent extends ReportsEvent {
  const LoadAuditLogsEvent({this.sessionUuid});

  final String? sessionUuid;
}
