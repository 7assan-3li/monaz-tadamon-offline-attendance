import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/admin_summary_report.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/audit_entry.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/monthly_attendance_sheet.dart';
import 'package:tadamon_attendance_app/features/reports/domain/repositories/reports_repository.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/screens/reports_hub_screen.dart';

class _MockReportsRepoForRange implements ReportsRepository {
  DateTime? receivedStartDate;
  DateTime? receivedEndDate;

  final dummySheet = MonthlyAttendanceSheet(
    teamId: 'team-first',
    teamName: 'الفريق الأول',
    month: DateTime.utc(2026, 10, 1),
    sessionDates: [DateTime.utc(2026, 10, 15), DateTime.utc(2026, 11, 2)],
    records: const [
      PlayerMonthlyRecord(
        playerId: '10',
        playerName: 'سالم مبارك',
        jerseyNumber: 10,
        statusByDate: {},
        presentCount: 20,
        excusedCount: 2,
        unexcusedCount: 0,
        lateCount: 0,
        athleticEntitlementDays: 22,
      ),
    ],
    totalSessions: 22,
    dateRangeLabel: 'الفترة: من 15/10/2026 إلى 05/11/2026',
    customStartDate: DateTime.utc(2026, 10, 15),
    customEndDate: DateTime.utc(2026, 11, 5),
  );

  final dummySummary = AdminSummaryReport(
    clubName: 'نادي تضامن حضرموت',
    season: 'الموسم الرياضي 2026',
    teamName: 'الفريق الأول',
    month: DateTime.utc(2026, 10, 1),
    teamManagerName: 'سعيد بن مخاشن',
    clubDirectorName: 'خالد بن سليم',
    totalSessions: 22,
    rows: const [],
    dateRangeLabel: 'الفترة: من 15/10/2026 إلى 05/11/2026',
    customStartDate: DateTime.utc(2026, 10, 15),
    customEndDate: DateTime.utc(2026, 11, 5),
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
    receivedStartDate = customStartDate;
    receivedEndDate = customEndDate;
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
  }) async {
    receivedStartDate = customStartDate;
    receivedEndDate = customEndDate;
    return dummySummary;
  }

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
  testWidgets('ReportsHubScreen supports custom date range selection and quick presets', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = _MockReportsRepoForRange();
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

    // 1. Verify screen loaded
    expect(find.text('تقارير الحضور'), findsOneWidget);

    // 2. Open Month/Period Sheet
    await tester.tap(find.text('الشهر المعتمد'));
    await tester.pumpAndSettle();

    // 3. Verify Custom Range Card and Quick Presets are visible
    expect(find.text('تحديد فترة مخصصة (من - إلى)'), findsOneWidget);
    expect(find.text('هذا الشهر'), findsOneWidget);
    expect(find.text('آخر 30 يوماً'), findsOneWidget);
    expect(find.text('آخر 7 أيام'), findsOneWidget);

    // 4. Tap 'آخر 30 يوماً' Quick Preset
    await tester.tap(find.text('آخر 30 يوماً'));
    await tester.pumpAndSettle();

    // 5. Verify the repository received the custom start and end date
    expect(repo.receivedStartDate, isNotNull);
    expect(repo.receivedEndDate, isNotNull);
    expect(repo.receivedEndDate!.difference(repo.receivedStartDate!).inDays, greaterThanOrEqualTo(28));
  });
}

