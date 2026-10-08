import 'package:excel/excel.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/admin_summary_report.dart';

class ExcelReportEngine {
  const ExcelReportEngine();

  List<int> generateAdminSummaryExcel(AdminSummaryReport report) {
    final excel = Excel.createExcel();
    const sheetName = 'خلاصة الإداري';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    // Meta row
    sheet.appendRow([
      TextCellValue(report.clubName),
      TextCellValue('الفريق: ${report.teamName}'),
      TextCellValue('الموسم: ${report.season}'),
      TextCellValue('الشهر: ${report.month.month} / ${report.month.year}'),
    ]);

    // Header row
    sheet.appendRow([
      TextCellValue('رقم القميص'),
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

    final encoded = excel.encode();
    return encoded ?? <int>[];
  }
}
