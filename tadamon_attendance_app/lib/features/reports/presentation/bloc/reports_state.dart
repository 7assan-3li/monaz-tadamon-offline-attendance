import 'package:tadamon_attendance_app/features/reports/domain/entities/admin_summary_report.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/audit_entry.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/monthly_attendance_sheet.dart';

sealed class ReportsState {
  const ReportsState();
}

final class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

final class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

final class ReportsLoaded extends ReportsState {
  const ReportsLoaded({
    required this.sheet,
    required this.summary,
    this.auditLogs = const [],
    this.exportedPdfBytes,
    this.exportedExcelBytes,
    this.actionMessage,
  });

  final MonthlyAttendanceSheet sheet;
  final AdminSummaryReport summary;
  final List<AuditEntry> auditLogs;
  final List<int>? exportedPdfBytes;
  final List<int>? exportedExcelBytes;
  final String? actionMessage;

  ReportsLoaded copyWith({
    MonthlyAttendanceSheet? sheet,
    AdminSummaryReport? summary,
    List<AuditEntry>? auditLogs,
    List<int>? exportedPdfBytes,
    List<int>? exportedExcelBytes,
    String? actionMessage,
  }) {
    return ReportsLoaded(
      sheet: sheet ?? this.sheet,
      summary: summary ?? this.summary,
      auditLogs: auditLogs ?? this.auditLogs,
      exportedPdfBytes: exportedPdfBytes ?? this.exportedPdfBytes,
      exportedExcelBytes: exportedExcelBytes ?? this.exportedExcelBytes,
      actionMessage: actionMessage,
    );
  }
}

final class ReportsError extends ReportsState {
  const ReportsError(this.message);

  final String message;
}
