import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/admin_summary_report.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/monthly_attendance_sheet.dart';

class PdfReportEngine {
  const PdfReportEngine({
    this.customRegularFontBytes,
    this.customBoldFontBytes,
  });

  final List<int>? customRegularFontBytes;
  final List<int>? customBoldFontBytes;

  Future<pw.Font> _loadFont(String path, List<int>? overrideBytes) async {
    if (overrideBytes != null) {
      return pw.Font.ttf(ByteData.sublistView(Uint8List.fromList(overrideBytes)));
    }
    try {
      final bytes = await rootBundle.load(path);
      return pw.Font.ttf(bytes);
    } catch (_) {
      // Fallback for tests reading filesystem directly
      final file = File('assets/fonts/cairo/${path.split('/').last}');
      if (file.existsSync()) {
        final fileBytes = await file.readAsBytes();
        return pw.Font.ttf(ByteData.sublistView(fileBytes));
      }
      return pw.Font.helvetica();
    }
  }

  Future<pw.ThemeData> _buildTheme() async {
    final regular = await _loadFont(
      'assets/fonts/cairo/Cairo-Regular.ttf',
      customRegularFontBytes,
    );
    final bold = await _loadFont(
      'assets/fonts/cairo/Cairo-Bold.ttf',
      customBoldFontBytes,
    );
    return pw.ThemeData.withFont(
      base: regular,
      bold: bold,
    );
  }

  Future<List<int>> generateMonthlySheetPdf(MonthlyAttendanceSheet sheet) async {
    final pdf = pw.Document(theme: await _buildTheme());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'نادي تضامن حضرموت الرياضي الثقافي الاجتماعي',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.Text(
                        'حافظة التحضير المفتوحة - ${sheet.teamName}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Text(
                    'الشهر: ${sheet.month.month} / ${sheet.month.year} | إجمالي التمارين: ${sheet.totalSessions}',
                    style: pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: PdfColors.blue900),
              pw.SizedBox(height: 8),

              // Attendance Table
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0E4B94),
                ),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headers: [
                  '#',
                  'اسم اللاعب',
                  ...sheet.sessionDates.map((d) => '${d.day}'),
                  'حاضر',
                  'بعذر',
                  'بدون عذر',
                  'متأخر',
                  'الاستحقاق الرياضي',
                ],
                data: sheet.records.map((r) {
                  return [
                    '${r.jerseyNumber}',
                    r.playerName,
                    ...sheet.sessionDates.map((d) {
                      final status = r.statusByDate[d];
                      return status?.shortArabicSymbol ?? '-';
                    }),
                    '${r.presentCount}',
                    '${r.excusedCount}',
                    '${r.unexcusedCount}',
                    '${r.lateCount}',
                    '${r.athleticEntitlementDays} حصة',
                  ];
                }).toList(),
              ),

              pw.Spacer(),

              // Signatures
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('إداري الفريق: .......................................'),
                  pw.Text('مدير النادي: .......................................'),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<List<int>> generateAdminSummaryPdf(AdminSummaryReport report) async {
    final pdf = pw.Document(theme: await _buildTheme());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        report.clubName,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: const PdfColor.fromInt(0xFF0E4B94),
                        ),
                      ),
                      pw.Text(
                        'كشف التحضير وخلاصة الإداري الرسمية',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('الفريق: ${report.teamName}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('الموسم: ${report.season}', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('الشهر: ${report.month.month} / ${report.month.year}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1.5, color: const PdfColor.fromInt(0xFF0E4B94)),
              pw.SizedBox(height: 8),

              // KPI Summary row
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text('إجمالي التمارين: ${report.totalSessions}'),
                    pw.Text('عدد اللاعبين: ${report.rows.length}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // Table
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8.5,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0E4B94),
                ),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headers: [
                  '#',
                  'اسم اللاعب',
                  'المركز',
                  'حاضر',
                  'بعذر',
                  'بدون عذر',
                  'متأخر',
                  'نسبة الحضور',
                  'الاستحقاق الرياضي',
                  'الحالة الانضباطية',
                ],
                data: report.rows.map((row) {
                  return [
                    '${row.jerseyNumber}',
                    row.playerName,
                    row.position,
                    '${row.presentCount}',
                    '${row.excusedAbsenceCount}',
                    '${row.unexcusedAbsenceCount}',
                    '${row.lateCount}',
                    '${row.attendanceRate}%',
                    '${row.athleticEntitlementDays} يوم',
                    row.athleticDisciplineStatus,
                  ];
                }).toList(),
              ),

              pw.Spacer(),

              // Signatures
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 12),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('إداري الفريق: ${report.teamManagerName}'),
                        pw.SizedBox(height: 16),
                        pw.Text('التوقيع: .......................................'),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('مدير النادي: ${report.clubDirectorName}'),
                        pw.SizedBox(height: 16),
                        pw.Text('الختم والاعتماد: .......................................'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
