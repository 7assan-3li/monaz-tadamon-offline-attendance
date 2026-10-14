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
import 'package:tadamon_attendance_app/features/reports/presentation/screens/reports_hub_screen.dart';

class _FakeReportsRepo implements ReportsRepository {
  final dummySheet = MonthlyAttendanceSheet(
    teamId: 'team-first',
    teamName: 'الفريق الأول',
    month: DateTime.utc(2026, 10, 1),
    sessionDates: [DateTime.utc(2026, 10, 5)],
    records: const [
      PlayerMonthlyRecord(
        playerId: '10',
        playerName: 'سالم مبارك',
        jerseyNumber: 10,
        statusByDate: {},
        presentCount: 22,
        excusedCount: 2,
        unexcusedCount: 0,
        lateCount: 0,
        athleticEntitlementDays: 24,
      ),
    ],
    totalSessions: 24,
  );

  final dummySummary = AdminSummaryReport(
    clubName: 'نادي تضامن حضرموت',
    season: 'الموسم الرياضي 2026',
    teamName: 'الفريق الأول',
    month: DateTime.utc(2026, 10, 1),
    teamManagerName: 'سعيد بن مخاشن',
    clubDirectorName: 'خالد بن سليم',
    totalSessions: 24,
    rows: const [
      PlayerSummaryRow(
        playerId: '10',
        playerName: 'سالم مبارك النهدي',
        jerseyNumber: 10,
        position: 'مهاجم • قائد الفريق الأول',
        presentCount: 22,
        excusedAbsenceCount: 2,
        unexcusedAbsenceCount: 0,
        lateCount: 0,
        attendanceRate: 91.6,
        athleticEntitlementDays: 24,
        athleticDisciplineStatus: 'انضباط تام',
      ),
    ],
  );

  @override
  Future<MonthlyAttendanceSheet> getMonthlyAttendanceSheet({
    required String teamId,
    required int year,
    required int month,
    String? period,
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) async => dummySheet;

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
  testWidgets('ReportsHubScreen renders correctly and supports interactions', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = _FakeReportsRepo();
    final bloc = ReportsBloc(repo);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ReportsBloc>.value(
          value: bloc,
          child: ReportsHubScreen(
            onNavigateTab: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Title and Header
    expect(find.text('تقارير الحضور'), findsOneWidget);
    expect(find.text('كشف الحضور الشهري'), findsOneWidget);
    expect(find.text('الخلاصة الإدارية'), findsOneWidget);

    // 2. Verify Hub Content
    expect(find.text('سجل الحصص'), findsOneWidget);

    // 3. Test Notifications Sheet
    await tester.tap(find.byIcon(LucideIcons.bell));
    await tester.pumpAndSettle();
    expect(find.text('التنبيهات الميدانية للكشوفات'), findsOneWidget);
    await tester.tap(find.text('فهمت ذلك'));
    await tester.pumpAndSettle();

    // 4. Test Profile Sheet
    await tester.tap(find.byIcon(LucideIcons.user));
    await tester.pumpAndSettle();
    expect(find.text('الملف الإداري وجهاز الماستر'), findsOneWidget);
    await tester.tap(find.text('إغلاق'));
    await tester.pumpAndSettle();

    // 5. Test Month Picker Sheet
    await tester.tap(find.text('الشهر المعتمد'));
    await tester.pumpAndSettle();
    expect(find.text('اختيار الشهر المعتمد'), findsOneWidget);
    await tester.tap(find.text('سبتمبر 2026'));
    await tester.pumpAndSettle();

    // 6. Test Squad Selector Sheet
    await tester.tap(find.text('الفئة والتشكيلة'));
    await tester.pumpAndSettle();
    expect(find.text('اختيار الفئة والتشكيلة'), findsOneWidget);
    await tester.tap(find.text('فريق الشباب (U-19)'));
    await tester.pumpAndSettle();

    // 7. Test Segmented Control Switcher to Tab 1 (Admin Summary)
    await tester.tap(find.text('الخلاصة الإدارية'));
    await tester.pumpAndSettle();
    expect(find.text('خلاصة حضور وانضباط اللاعبين'), findsOneWidget);

    // 8. Test Export Actions (PDF and Excel)
    final exportBtnFinder = find.text('تصدير كشف الجداول (Excel XLSX)');
    await tester.scrollUntilVisible(
      exportBtnFinder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('تصدير خلاصة الإداري (PDF الرسمية)'), findsOneWidget);
    await tester.tap(exportBtnFinder);
    await tester.pumpAndSettle();
  });
}
