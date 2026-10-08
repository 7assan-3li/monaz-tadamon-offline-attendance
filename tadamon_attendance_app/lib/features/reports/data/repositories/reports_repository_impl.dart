import 'package:drift/drift.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/audit_log_dao.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/excel_report_engine.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/pdf_report_engine.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/admin_summary_report.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/audit_entry.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/monthly_attendance_sheet.dart';
import 'package:tadamon_attendance_app/features/reports/domain/repositories/reports_repository.dart';
import 'package:tadamon_attendance_app/features/reports/domain/usecases/calculate_entitlement_use_case.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  ReportsRepositoryImpl({
    required this.database,
    required this.auditLogDao,
    required this.pdfEngine,
    required this.excelEngine,
    this.entitlementUseCase = const CalculateEntitlementUseCase(),
  });

  final AppDatabase database;
  final AuditLogDao auditLogDao;
  final PdfReportEngine pdfEngine;
  final ExcelReportEngine excelEngine;
  final CalculateEntitlementUseCase entitlementUseCase;

  @override
  Future<void> approveSession({
    required String sessionUuid,
    required String approvedBy,
  }) {
    return auditLogDao.approveSession(
      sessionUuid: sessionUuid,
      approvedBy: approvedBy,
    );
  }

  @override
  Future<void> recordExceptionalEdit({
    required String sessionUuid,
    required String playerId,
    required AttendanceStatus newStatus,
    required String modifiedBy,
    required String reason,
  }) {
    return auditLogDao.logExceptionalChange(
      sessionUuid: sessionUuid,
      playerId: playerId,
      newStatus: newStatus,
      modifiedBy: modifiedBy,
      reason: reason,
    );
  }

  @override
  Future<List<AuditEntry>> getAuditLogs({String? sessionUuid}) {
    return auditLogDao.getAuditLogs(sessionUuid: sessionUuid);
  }

  @override
  Future<MonthlyAttendanceSheet> getMonthlyAttendanceSheet({
    required String teamId,
    required int year,
    required int month,
  }) async {
    final team = await (database.select(database.teams)
          ..where((tbl) => tbl.id.equals(teamId)))
        .getSingleOrNull();
    final teamName = team?.name ?? 'الفريق الأول';

    final startDate = DateTime.utc(year, month, 1);
    final endDate = DateTime.utc(year, month + 1, 1);

    // Fetch sessions in month
    final sessions = await (database.select(database.sessions)
          ..where((tbl) =>
              tbl.teamId.equals(teamId) &
              tbl.sessionDate.isBiggerOrEqualValue(startDate) &
              tbl.sessionDate.isSmallerThanValue(endDate))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.sessionDate, mode: OrderingMode.asc),
          ]))
        .get();

    final sessionDates = sessions.map((s) => s.sessionDate).toList();
    final sessionUuids = sessions.map((s) => s.sessionUuid).toList();

    // Fetch players
    final players = await (database.select(database.players)
          ..where((tbl) => tbl.teamId.equals(teamId) & tbl.isArchived.equals(false))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.jerseyNumber, mode: OrderingMode.asc),
          ]))
        .get();

    // Fetch attendance records
    final recordsQuery = database.select(database.attendanceRecords);
    if (sessionUuids.isNotEmpty) {
      recordsQuery.where((tbl) => tbl.sessionUuid.isIn(sessionUuids));
    }
    final allRecords = sessionUuids.isEmpty ? <AttendanceRecord>[] : await recordsQuery.get();

    final List<PlayerMonthlyRecord> playerRecords = [];

    for (final player in players) {
      final playerRecordsForMonth =
          allRecords.where((r) => r.playerId == player.id).toList();

      final Map<DateTime, AttendanceStatus> statusByDate = {};
      int presentCount = 0;
      int excusedCount = 0;
      int unexcusedCount = 0;
      int lateCount = 0;

      for (final session in sessions) {
        final record = playerRecordsForMonth
            .where((r) => r.sessionUuid == session.sessionUuid)
            .firstOrNull;

        if (record != null) {
          final status = AttendanceStatusVisuals.fromDb(record.status);
          statusByDate[session.sessionDate] = status;

          switch (status) {
            case AttendanceStatus.present:
              presentCount++;
            case AttendanceStatus.excused:
              excusedCount++;
            case AttendanceStatus.unexcused:
              unexcusedCount++;
          }
          if (record.lateMinutes > 0) {
            lateCount++;
          }
        }
      }

      final entitlement = entitlementUseCase(
        totalSessions: sessions.length,
        presentCount: presentCount,
        excusedCount: excusedCount,
        unexcusedCount: unexcusedCount,
        lateCount: lateCount,
      );

      playerRecords.add(
        PlayerMonthlyRecord(
          playerId: player.id,
          playerName: player.name,
          jerseyNumber: player.jerseyNumber ?? 0,
          statusByDate: statusByDate,
          presentCount: presentCount,
          excusedCount: excusedCount,
          unexcusedCount: unexcusedCount,
          lateCount: lateCount,
          athleticEntitlementDays: entitlement.entitlementDays,
        ),
      );
    }

    return MonthlyAttendanceSheet(
      teamId: teamId,
      teamName: teamName,
      month: startDate,
      sessionDates: sessionDates,
      records: playerRecords,
      totalSessions: sessions.length,
    );
  }

  @override
  Future<AdminSummaryReport> getAdminSummaryReport({
    required String teamId,
    required int year,
    required int month,
  }) async {
    final settings = await (database.select(database.clubSettings)..limit(1)).getSingleOrNull();
    final team = await (database.select(database.teams)..where((tbl) => tbl.id.equals(teamId))).getSingleOrNull();

    final clubName = settings?.clubName ?? 'نادي تضامن حضرموت';
    final season = settings?.season ?? 'الموسم الرياضي';
    final teamName = team?.name ?? 'الفريق الأول';
    final teamManagerName = settings?.managerName ?? 'إداري الفريق المعتمد';
    final clubDirectorName = settings?.adminName ?? 'مدير النادي المعتمد';

    final startDate = DateTime.utc(year, month, 1);
    final endDate = DateTime.utc(year, month + 1, 1);

    final sessions = await (database.select(database.sessions)
          ..where((tbl) =>
              tbl.teamId.equals(teamId) &
              tbl.sessionDate.isBiggerOrEqualValue(startDate) &
              tbl.sessionDate.isSmallerThanValue(endDate)))
        .get();

    final sessionUuids = sessions.map((s) => s.sessionUuid).toList();

    final players = await (database.select(database.players)
          ..where((tbl) => tbl.teamId.equals(teamId) & tbl.isArchived.equals(false))
          ..orderBy([
            (tbl) => OrderingTerm(expression: tbl.jerseyNumber, mode: OrderingMode.asc),
          ]))
        .get();

    final recordsQuery = database.select(database.attendanceRecords);
    if (sessionUuids.isNotEmpty) {
      recordsQuery.where((tbl) => tbl.sessionUuid.isIn(sessionUuids));
    }
    final allRecords = sessionUuids.isEmpty ? <AttendanceRecord>[] : await recordsQuery.get();

    final List<PlayerSummaryRow> rows = [];

    for (final player in players) {
      final pRecords = allRecords.where((r) => r.playerId == player.id).toList();

      int presentCount = 0;
      int excusedCount = 0;
      int unexcusedCount = 0;
      int lateCount = 0;

      for (final r in pRecords) {
        final status = AttendanceStatusVisuals.fromDb(r.status);
        switch (status) {
          case AttendanceStatus.present:
            presentCount++;
          case AttendanceStatus.excused:
            excusedCount++;
          case AttendanceStatus.unexcused:
            unexcusedCount++;
        }
        if (r.lateMinutes > 0) {
          lateCount++;
        }
      }

      final entitlement = entitlementUseCase(
        totalSessions: sessions.length,
        presentCount: presentCount,
        excusedCount: excusedCount,
        unexcusedCount: unexcusedCount,
        lateCount: lateCount,
      );

      rows.add(
        PlayerSummaryRow(
          playerId: player.id,
          playerName: player.name,
          jerseyNumber: player.jerseyNumber ?? 0,
          position: player.position ?? 'لاعب',
          presentCount: presentCount,
          excusedAbsenceCount: excusedCount,
          unexcusedAbsenceCount: unexcusedCount,
          lateCount: lateCount,
          attendanceRate: entitlement.attendanceRate,
          athleticEntitlementDays: entitlement.entitlementDays,
          athleticDisciplineStatus: entitlement.disciplineStatus,
        ),
      );
    }

    return AdminSummaryReport(
      clubName: clubName,
      season: season,
      teamName: teamName,
      month: startDate,
      teamManagerName: teamManagerName,
      clubDirectorName: clubDirectorName,
      totalSessions: sessions.length,
      rows: rows,
    );
  }

  @override
  Future<List<int>> generateMonthlySheetPdf(MonthlyAttendanceSheet sheet) {
    return pdfEngine.generateMonthlySheetPdf(sheet);
  }

  @override
  Future<List<int>> generateAdminSummaryPdf(AdminSummaryReport report) {
    return pdfEngine.generateAdminSummaryPdf(report);
  }

  @override
  Future<List<int>> generateAdminSummaryExcel(AdminSummaryReport report) async {
    return excelEngine.generateAdminSummaryExcel(report);
  }
}
