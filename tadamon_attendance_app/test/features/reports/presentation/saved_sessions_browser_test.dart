import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/admin_summary_report.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/audit_entry.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/monthly_attendance_sheet.dart';
import 'package:tadamon_attendance_app/features/reports/domain/repositories/reports_repository.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/screens/master_review_approval_screen.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/screens/reports_hub_screen.dart';

class _FakeReportsRepoWithSessions implements ReportsRepository {
  DateTime? capturedStartDate;
  DateTime? capturedEndDate;

  final dummySheet = MonthlyAttendanceSheet(
    teamId: 'team-first',
    teamName: 'الفريق الأول',
    month: DateTime.utc(2026, 10, 1),
    sessionDates: [
      DateTime.utc(2026, 10, 5),
      DateTime.utc(2026, 10, 10),
    ],
    totalSessions: 2,
    records: const [],
    sessions: [
      SessionReportItem(
        sessionUuid: 'session-uuid-1',
        date: DateTime.utc(2026, 10, 10),
        period: 'evening',
        location: 'ملعب بارادم بالمكلا',
        isApproved: true,
        isDispatched: true,
        isLocked: true,
        presentCount: 22,
        excusedCount: 2,
        unexcusedCount: 1,
        lateCount: 0,
        totalPlayers: 25,
        status: 'approved',
      ),
      SessionReportItem(
        sessionUuid: 'session-uuid-2',
        date: DateTime.utc(2026, 10, 5),
        period: 'morning',
        location: 'صالة النادي المغلقة',
        isApproved: false,
        isDispatched: true,
        isLocked: false,
        presentCount: 20,
        excusedCount: 3,
        unexcusedCount: 2,
        lateCount: 1,
        totalPlayers: 25,
        status: 'dispatched',
      ),
    ],
  );

  final dummySummary = AdminSummaryReport(
    clubName: 'نادي تضامن حضرموت',
    season: '2026 / 2027',
    teamName: 'الفريق الأول',
    month: DateTime.utc(2026, 10, 1),
    teamManagerName: 'سعيد بامحسون',
    clubDirectorName: 'الكابتن فائز بالرقعان',
    totalSessions: 2,
    rows: const [],
  );

  @override
  Future<MonthlyAttendanceSheet> getMonthlyAttendanceSheet({
    required String teamId,
    required int year,
    required int month,
    String? period,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) async {
    capturedStartDate = customStartDate;
    capturedEndDate = customEndDate;
    return dummySheet;
  }

  @override
  Future<AdminSummaryReport> getAdminSummaryReport({
    required String teamId,
    required int year,
    required int month,
    String? period,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) async => dummySummary;

  @override
  Future<List<AuditEntry>> getAuditLogs({String? sessionUuid}) async => [];

  @override
  Future<void> approveSession({required String sessionUuid, required String approvedBy}) async {}

  @override
  Future<void> recordExceptionalEdit({
    required String sessionUuid,
    required String playerId,
    required AttendanceStatus newStatus,
    required String modifiedBy,
    required String reason,
  }) async {}

  @override
  Future<List<int>> generateMonthlySheetPdf(MonthlyAttendanceSheet sheet) async => [1, 2, 3];

  @override
  Future<List<int>> generateAdminSummaryPdf(AdminSummaryReport summary) async => [1, 2, 3];

  @override
  Future<List<int>> generateAdminSummaryExcel(AdminSummaryReport summary) async => [1, 2, 3];
}

void main() {
  testWidgets('Saved Sessions Browser lists sessions and drills down to MasterReviewApprovalScreen',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = _FakeReportsRepoWithSessions();
    final bloc = ReportsBloc(repo);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ReportsBloc>.value(
          value: bloc,
          child: const ReportsHubScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Tab 0 is selected by default and displays saved sessions
    expect(find.text('سجل الحصص'), findsOneWidget);
    expect(find.text('ملخص حصص الفترة المحددة'), findsOneWidget);
    expect(find.text('الحصص التدريبية المسجلة (2)'), findsOneWidget);

    // 2. Verify Session 1 Cards Details
    expect(find.text('ملعب بارادم بالمكلا'), findsOneWidget);
    expect(find.text('صالة النادي المغلقة'), findsOneWidget);

    // 3. Drill-down: Tap on the first session card to open MasterReviewApprovalScreen
    final reviewButtons = find.text('عرض الكشف');
    expect(reviewButtons, findsNWidgets(2));

    await tester.tap(reviewButtons.first);
    await tester.pumpAndSettle();

    // 4. Verify MasterReviewApprovalScreen is opened
    expect(find.byType(MasterReviewApprovalScreen), findsOneWidget);
    expect(find.text('مراجعة واعتماد الكشف الميداني'), findsOneWidget);

    // 5. Pop back to Reports Hub
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ReportsHubScreen), findsOneWidget);
  });
}
