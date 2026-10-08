import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/admin_summary_report.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/audit_entry.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/monthly_attendance_sheet.dart';

abstract interface class ReportsRepository {
  Future<void> approveSession({
    required String sessionUuid,
    required String approvedBy,
  });

  Future<void> recordExceptionalEdit({
    required String sessionUuid,
    required String playerId,
    required AttendanceStatus newStatus,
    required String modifiedBy,
    required String reason,
  });

  Future<List<AuditEntry>> getAuditLogs({String? sessionUuid});

  Future<MonthlyAttendanceSheet> getMonthlyAttendanceSheet({
    required String teamId,
    required int year,
    required int month,
  });

  Future<AdminSummaryReport> getAdminSummaryReport({
    required String teamId,
    required int year,
    required int month,
  });

  Future<List<int>> generateMonthlySheetPdf(MonthlyAttendanceSheet sheet);

  Future<List<int>> generateAdminSummaryPdf(AdminSummaryReport report);

  Future<List<int>> generateAdminSummaryExcel(AdminSummaryReport report);
}
