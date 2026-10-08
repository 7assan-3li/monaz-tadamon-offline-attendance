import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/excel_report_engine.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/pdf_report_engine.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/admin_summary_report.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/monthly_attendance_sheet.dart';

void main() {
  group('PdfReportEngine and ExcelReportEngine (Document Generation)', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    const pdfEngine = PdfReportEngine();
    const excelEngine = ExcelReportEngine();

    final testMonth = DateTime.utc(2026, 10, 1);
    final sessionDates = [
      DateTime.utc(2026, 10, 2),
      DateTime.utc(2026, 10, 4),
      DateTime.utc(2026, 10, 6),
    ];

    final monthlySheet = MonthlyAttendanceSheet(
      teamId: 'team-first',
      teamName: 'الفريق الأول',
      month: testMonth,
      sessionDates: sessionDates,
      totalSessions: 3,
      records: [
        PlayerMonthlyRecord(
          playerId: 'p1',
          playerName: 'سالم مبارك بن ركيز',
          jerseyNumber: 10,
          statusByDate: {
            sessionDates[0]: AttendanceStatus.present,
            sessionDates[1]: AttendanceStatus.present,
            sessionDates[2]: AttendanceStatus.excused,
          },
          presentCount: 2,
          excusedCount: 1,
          unexcusedCount: 0,
          lateCount: 0,
          athleticEntitlementDays: 2,
        ),
      ],
    );

    final adminSummary = AdminSummaryReport(
      clubName: 'نادي تضامن حضرموت الرياضي',
      season: '2026 / 2027',
      teamName: 'الفريق الأول',
      month: testMonth,
      teamManagerName: 'سعيد بامحسون',
      clubDirectorName: 'الكابتن فائز بالرقعان',
      totalSessions: 3,
      rows: const [
        PlayerSummaryRow(
          playerId: 'p1',
          playerName: 'سالم مبارك بن ركيز',
          jerseyNumber: 10,
          position: 'مهاجم',
          presentCount: 2,
          excusedAbsenceCount: 1,
          unexcusedAbsenceCount: 0,
          lateCount: 0,
          attendanceRate: 66.7,
          athleticEntitlementDays: 2,
          athleticDisciplineStatus: 'تحت التقييم الفني',
        ),
      ],
    );

    test('generates valid Monthly Attendance Sheet PDF (Model 1)', () async {
      final pdfBytes = await pdfEngine.generateMonthlySheetPdf(monthlySheet);
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
      // PDF header check (%PDF)
      final header = ascii.decode(pdfBytes.sublist(0, 4));
      expect(header, '%PDF');
    });

    test('generates valid Admin Summary Report PDF (Model 2)', () async {
      final pdfBytes = await pdfEngine.generateAdminSummaryPdf(adminSummary);
      expect(pdfBytes, isNotEmpty);
      expect(pdfBytes.length, greaterThan(1000));
      final header = ascii.decode(pdfBytes.sublist(0, 4));
      expect(header, '%PDF');
    });

    test('generates valid Excel Workbook (.xlsx) with Arabic Sheet and Data', () {
      final excelBytes = excelEngine.generateAdminSummaryExcel(adminSummary);
      expect(excelBytes, isNotEmpty);
      expect(excelBytes.length, greaterThan(500));
      // ZIP / XLSX header check (PK)
      expect(excelBytes[0], 0x50);
      expect(excelBytes[1], 0x4B);
    });
  });
}
