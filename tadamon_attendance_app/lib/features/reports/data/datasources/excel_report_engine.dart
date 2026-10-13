import 'package:excel/excel.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/admin_summary_report.dart';

class ExcelReportEngine {
  const ExcelReportEngine();

  List<int> generateAdminSummaryExcel(AdminSummaryReport report) {
    final excel = Excel.createExcel();
    const sheetName = 'خلاصة الإداري';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    // 1. Official Club Header Row
    sheet.appendRow([
      TextCellValue('الجمهورية اليمنية - وزارة الشباب والرياضة - نادي تضامن حضرموت الرياضي الثقافي الاجتماعي'),
    ]);

    // 2. Report Metadata Sub-header
    sheet.appendRow([
      TextCellValue('كشف التحضير وخلاصة الإداري الرسمية | الموسم: ${report.season} | الفريق: ${report.teamName} | الشهر: ${report.month.month} / ${report.month.year} | الفترة: ${report.periodLabel}'),
    ]);

    // 3. Operational KPIs Row
    sheet.appendRow([
      TextCellValue('إجمالي التمارين: ${report.totalSessions} | قوام الفريق: ${report.rows.length} لاعب | نظام التحضير: معتمد ميدانياً (أوفلاين 100%)'),
    ]);

    // 4. Spacer Row
    sheet.appendRow([TextCellValue('')]);

    // 5. Official Table Headers
    sheet.appendRow([
      TextCellValue('#'),
      TextCellValue('اسم اللاعب'),
      TextCellValue('المركز'),
      TextCellValue('حاضر'),
      TextCellValue('غائب بعذر'),
      TextCellValue('غائب بدون عذر'),
      TextCellValue('متأخر'),
      TextCellValue('نسبة الحضور'),
      TextCellValue('الاستحقاق الرياضي (أيام)'),
      TextCellValue('الحالة الانضباطية'),
    ]);

    // 6. Data Rows
    for (final row in report.rows) {
      sheet.appendRow([
        IntCellValue(row.jerseyNumber),
        TextCellValue(row.playerName),
        TextCellValue(row.position),
        IntCellValue(row.presentCount),
        IntCellValue(row.excusedAbsenceCount),
        IntCellValue(row.unexcusedAbsenceCount),
        IntCellValue(row.lateCount),
        TextCellValue('${row.attendanceRate}%'),
        IntCellValue(row.athleticEntitlementDays),
        TextCellValue(row.athleticDisciplineStatus),
      ]);
    }

    // 7. Spacer & Signatures
    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([
      TextCellValue('إداري الفريق: ${report.teamManagerName}'),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('مدير النادي: ${report.clubDirectorName}'),
    ]);

    // 8. Explicit Column Widths for Optimal Display & Printing
    sheet.setColumnWidth(0, 10.0);
    sheet.setColumnWidth(1, 28.0);
    sheet.setColumnWidth(2, 16.0);
    sheet.setColumnWidth(3, 10.0);
    sheet.setColumnWidth(4, 12.0);
    sheet.setColumnWidth(5, 14.0);
    sheet.setColumnWidth(6, 10.0);
    sheet.setColumnWidth(7, 14.0);
    sheet.setColumnWidth(8, 22.0);
    sheet.setColumnWidth(9, 22.0);

    final encoded = excel.encode();
    return encoded ?? <int>[];
  }
}
