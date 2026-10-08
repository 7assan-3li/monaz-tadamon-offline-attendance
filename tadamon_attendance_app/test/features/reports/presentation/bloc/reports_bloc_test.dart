import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/admin_summary_report.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/audit_entry.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/monthly_attendance_sheet.dart';
import 'package:tadamon_attendance_app/features/reports/domain/repositories/reports_repository.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_event.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_state.dart';

void main() {
  late _MockReportsRepository repository;

  setUp(() {
    repository = _MockReportsRepository();
  });

  group('ReportsBloc', () {
    blocTest<ReportsBloc, ReportsState>(
      'loads reports hub data and emits ReportsLoaded',
      build: () => ReportsBloc(repository),
      act: (bloc) => bloc.add(const LoadReportsHubEvent(teamId: 'team-first', year: 2026, month: 10)),
      expect: () => [
        isA<ReportsLoading>(),
        isA<ReportsLoaded>()
            .having((s) => s.sheet.teamName, 'teamName', 'الفريق الأول')
            .having((s) => s.summary.clubName, 'clubName', 'نادي تضامن حضرموت'),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'approves session and updates actionMessage in ReportsLoaded',
      build: () => ReportsBloc(repository),
      seed: () => ReportsLoaded(
        sheet: repository.dummySheet,
        summary: repository.dummySummary,
        auditLogs: const [],
      ),
      act: (bloc) => bloc.add(const ApproveSessionEvent(
        sessionUuid: 'session-101',
        approvedBy: 'مدير النادي',
      )),
      expect: () => [
        isA<ReportsLoaded>().having(
          (s) => s.actionMessage,
          'actionMessage',
          contains('تم اعتماد التمرين نهائياً'),
        ),
      ],
      verify: (_) {
        expect(repository.approvedSessionUuid, 'session-101');
      },
    );

    blocTest<ReportsBloc, ReportsState>(
      'rejects exceptional edit without reason and emits ReportsError',
      build: () => ReportsBloc(repository),
      seed: () => ReportsLoaded(
        sheet: repository.dummySheet,
        summary: repository.dummySummary,
        auditLogs: const [],
      ),
      act: (bloc) => bloc.add(const SubmitExceptionalEditEvent(
        sessionUuid: 'session-101',
        playerId: 'p1',
        newStatus: AttendanceStatus.excused,
        modifiedBy: 'مدير النادي',
        reason: '   ',
      )),
      expect: () => [
        isA<ReportsError>().having(
          (s) => s.message,
          'message',
          contains('سبب التعديل الاستثنائي إجباري'),
        ),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'records valid exceptional edit and emits updated state with log',
      build: () => ReportsBloc(repository),
      seed: () => ReportsLoaded(
        sheet: repository.dummySheet,
        summary: repository.dummySummary,
        auditLogs: const [],
      ),
      act: (bloc) => bloc.add(const SubmitExceptionalEditEvent(
        sessionUuid: 'session-101',
        playerId: 'p1',
        newStatus: AttendanceStatus.excused,
        modifiedBy: 'مدير النادي',
        reason: 'إجازة معتمدة من الإدارة',
      )),
      expect: () => [
        isA<ReportsLoaded>()
            .having(
              (s) => s.actionMessage,
              'actionMessage',
              contains('تم تدوين التعديل الاستثنائي'),
            )
            .having((s) => s.auditLogs.length, 'auditLogsCount', 1),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'exports Monthly PDF and attaches bytes',
      build: () => ReportsBloc(repository),
      seed: () => ReportsLoaded(
        sheet: repository.dummySheet,
        summary: repository.dummySummary,
        auditLogs: const [],
      ),
      act: (bloc) => bloc.add(const ExportMonthlyPdfEvent()),
      expect: () => [
        isA<ReportsLoaded>().having((s) => s.exportedPdfBytes, 'pdfBytes', isNotNull),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'exports Admin Summary Excel and attaches bytes',
      build: () => ReportsBloc(repository),
      seed: () => ReportsLoaded(
        sheet: repository.dummySheet,
        summary: repository.dummySummary,
        auditLogs: const [],
      ),
      act: (bloc) => bloc.add(const ExportAdminSummaryExcelEvent()),
      expect: () => [
        isA<ReportsLoaded>().having((s) => s.exportedExcelBytes, 'excelBytes', isNotNull),
      ],
    );
  });
}

class _MockReportsRepository implements ReportsRepository {
  String? approvedSessionUuid;
  final List<AuditEntry> logs = [];

  final dummySheet = MonthlyAttendanceSheet(
    teamId: 'team-first',
    teamName: 'الفريق الأول',
    month: DateTime.utc(2026, 10, 1),
    sessionDates: [DateTime.utc(2026, 10, 5)],
    records: const [],
    totalSessions: 1,
  );

  final dummySummary = AdminSummaryReport(
    clubName: 'نادي تضامن حضرموت',
    season: '2026 / 2027',
    teamName: 'الفريق الأول',
    month: DateTime.utc(2026, 10, 1),
    teamManagerName: 'سعيد بامحسون',
    clubDirectorName: 'الكابتن فائز',
    totalSessions: 1,
    rows: const [],
  );

  @override
  Future<MonthlyAttendanceSheet> getMonthlyAttendanceSheet({
    required String teamId,
    required int year,
    required int month,
  }) async => dummySheet;

  @override
  Future<AdminSummaryReport> getAdminSummaryReport({
    required String teamId,
    required int year,
    required int month,
  }) async => dummySummary;

  @override
  Future<void> approveSession({
    required String sessionUuid,
    required String approvedBy,
  }) async {
    approvedSessionUuid = sessionUuid;
  }

  @override
  Future<void> recordExceptionalEdit({
    required String sessionUuid,
    required String playerId,
    required AttendanceStatus newStatus,
    required String modifiedBy,
    required String reason,
  }) async {
    logs.add(
      AuditEntry(
        id: '1',
        sessionUuid: sessionUuid,
        action: 'تعديل استثنائي',
        modifiedBy: modifiedBy,
        reason: reason,
        timestamp: DateTime.now(),
        diff: 'من غياب إلى عذر',
      ),
    );
  }

  @override
  Future<List<AuditEntry>> getAuditLogs({String? sessionUuid}) async => logs;

  @override
  Future<List<int>> generateMonthlySheetPdf(MonthlyAttendanceSheet sheet) async => [1, 2, 3];

  @override
  Future<List<int>> generateAdminSummaryPdf(AdminSummaryReport report) async => [1, 2, 3];

  @override
  Future<List<int>> generateAdminSummaryExcel(AdminSummaryReport report) async => [1, 2, 3];
}
