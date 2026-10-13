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

  static const PdfColor royalBlue = PdfColor.fromInt(0xFF0E4B94);
  static const PdfColor navyDark = PdfColor.fromInt(0xFF0A2540);
  static const PdfColor goldAccent = PdfColor.fromInt(0xFFD97706);
  static const PdfColor lightBg = PdfColor.fromInt(0xFFF8FAFC);
  static const PdfColor borderColor = PdfColor.fromInt(0xFFCBD5E1);

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

  Future<pw.MemoryImage?> _loadLogo() async {
    try {
      final bytes = await rootBundle.load('assets/images/main_logo.png');
      return pw.MemoryImage(bytes.buffer.asUint8List());
    } catch (_) {
      try {
        final file = File('assets/images/main_logo.png');
        if (file.existsSync()) {
          final fileBytes = await file.readAsBytes();
          return pw.MemoryImage(fileBytes);
        }
      } catch (_) {}
      return null;
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
    final theme = await _buildTheme();
    final logoImage = await _loadLogo();
    final pdf = pw.Document(theme: theme);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 1. Official Administrative Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Right: Official Yemeni Ministry Branding
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'الجمهورية اليمنية',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'وزارة الشباب والرياضة | ساحل حضرموت',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'نادي تضامن حضرموت الرياضي الثقافي الاجتماعي',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: royalBlue,
                        ),
                      ),
                      pw.Text(
                        'تأسس عام 1959م - المكلا',
                        style: const pw.TextStyle(fontSize: 7.5, color: goldAccent),
                      ),
                    ],
                  ),

                  // Center: Club Logo & Title
                  pw.Column(
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          width: 44,
                          height: 44,
                          child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                        )
                      else
                        pw.Container(
                          width: 36,
                          height: 36,
                          decoration: pw.BoxDecoration(
                            color: royalBlue,
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            'تضامن',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 9,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'حافظة التحضير المفتوحة',
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: royalBlue,
                        ),
                      ),
                    ],
                  ),

                  // Left: Team, Month & Period Meta
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'الفريق: ${sheet.teamName}',
                        style: pw.TextStyle(fontSize: 9.5, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'الشهر: ${sheet.month.month} / ${sheet.month.year}',
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                      pw.Text(
                        'الفترة: ${sheet.periodLabel}',
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                          color: royalBlue,
                        ),
                      ),
                      pw.Text(
                        'إجمالي التمارين: ${sheet.totalSessions}',
                        style: const pw.TextStyle(fontSize: 8.5),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 5),
              // Royal & Gold Accent Lines
              pw.Container(height: 2, color: royalBlue),
              pw.SizedBox(height: 1),
              pw.Container(height: 1, color: goldAccent),
              pw.SizedBox(height: 6),

              // 2. Summary KPI Ribbon
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius: pw.BorderRadius.circular(4),
                  border: pw.TableBorder.all(color: borderColor, width: 0.5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Text('إجمالي التمارين: ${sheet.totalSessions}', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('عدد اللاعبين: ${sheet.records.length}', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text('الفترة: ${sheet.periodLabel}', style: const pw.TextStyle(fontSize: 8, color: royalBlue)),
                    pw.Text('نظام التحضير: معتمد ميدانياً (أوفلاين 100%)', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ),

              pw.SizedBox(height: 6),

              // 3. Attendance Sheet Table
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: borderColor, width: 0.5),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: royalBlue,
                ),
                rowDecoration: const pw.BoxDecoration(),
                oddRowDecoration: const pw.BoxDecoration(
                  color: lightBg,
                ),
                cellStyle: const pw.TextStyle(fontSize: 7.5),
                cellAlignment: pw.Alignment.center,
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

              // 4. Official Signatures and Club Stamp
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    // Team Manager
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('إداري الفريق: .......................................', style: const pw.TextStyle(fontSize: 8.5)),
                        pw.SizedBox(height: 6),
                        pw.Text('التوقيع: .......................................', style: const pw.TextStyle(fontSize: 8.5)),
                      ],
                    ),

                    // Official Stamp Box
                    pw.Container(
                      width: 80,
                      height: 38,
                      decoration: pw.BoxDecoration(
                        border: pw.TableBorder.all(
                          color: royalBlue,
                          width: 0.8,
                          style: pw.BorderStyle.dashed,
                        ),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        'موضع الختم الرسمي\nلنادي التضامن',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.blueGrey),
                      ),
                    ),

                    // Club Director
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('مدير النادي: .......................................', style: const pw.TextStyle(fontSize: 8.5)),
                        pw.SizedBox(height: 6),
                        pw.Text('الاعتماد: .......................................', style: const pw.TextStyle(fontSize: 8.5)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 3),
              // Footnote
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'وثيقة رياضية رسمية معتمدة صادرة عن نظام موناز (MONAZ) الميداني - نادي تضامن حضرموت | استحقاق رياضي بحت خالي من أي معاملات مالية',
                  style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<List<int>> generateAdminSummaryPdf(AdminSummaryReport report) async {
    final theme = await _buildTheme();
    final logoImage = await _loadLogo();
    final pdf = pw.Document(theme: theme);

    final avgRate = report.rows.isEmpty
        ? 0.0
        : report.rows.map((r) => r.attendanceRate).reduce((a, b) => a + b) / report.rows.length;
    final disciplinedCount = report.rows.where((r) => r.athleticDisciplineStatus.contains('منضبط')).length;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        textDirection: pw.TextDirection.rtl,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 1. Official Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'الجمهورية اليمنية',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                      pw.Text(
                        'وزارة الشباب والرياضة | ساحل حضرموت',
                        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        report.clubName,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: royalBlue,
                        ),
                      ),
                      pw.Text(
                        'تأسس عام 1959م - المكلا',
                        style: const pw.TextStyle(fontSize: 7.5, color: goldAccent),
                      ),
                    ],
                  ),

                  pw.Column(
                    children: [
                      if (logoImage != null)
                        pw.Container(
                          width: 48,
                          height: 48,
                          child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                        )
                      else
                        pw.Container(
                          width: 38,
                          height: 38,
                          decoration: pw.BoxDecoration(
                            color: royalBlue,
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            'تضامن',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 10,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'كشف التحضير وخلاصة الإداري الرسمية',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: royalBlue,
                        ),
                      ),
                    ],
                  ),

                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('الفريق: ${report.teamName}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text('الموسم: ${report.season}', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text('الشهر: ${report.month.month} / ${report.month.year}', style: const pw.TextStyle(fontSize: 8)),
                      pw.Text(
                        'الفترة: ${report.periodLabel}',
                        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: royalBlue),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 5),
              pw.Container(height: 2, color: royalBlue),
              pw.SizedBox(height: 1),
              pw.Container(height: 1, color: goldAccent),
              pw.SizedBox(height: 8),

              // 2. KPI Summary Cards
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.TableBorder.all(color: borderColor, width: 0.5),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text('إجمالي التمارين', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                        pw.Text('${report.totalSessions}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: royalBlue)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('قوام الفريق', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                        pw.Text('${report.rows.length} لاعب', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: navyDark)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('متوسط الحضور', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                        pw.Text('${avgRate.toStringAsFixed(1)}%', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.green800)),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text('الانضباط التام', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
                        pw.Text('$disciplinedCount لاعب', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: goldAccent)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 8),

              // 3. Player Performance Table
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: borderColor, width: 0.5),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: royalBlue,
                ),
                oddRowDecoration: const pw.BoxDecoration(
                  color: lightBg,
                ),
                cellStyle: const pw.TextStyle(fontSize: 7.5),
                cellAlignment: pw.Alignment.center,
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

              // 4. Official Signatures and Stamp Section
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('إداري الفريق: ${report.teamManagerName}', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 8),
                        pw.Text('التوقيع: .......................................', style: const pw.TextStyle(fontSize: 8.5)),
                      ],
                    ),

                    pw.Container(
                      width: 90,
                      height: 48,
                      decoration: pw.BoxDecoration(
                        border: pw.TableBorder.all(
                          color: royalBlue,
                          width: 0.8,
                          style: pw.BorderStyle.dashed,
                        ),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      alignment: pw.Alignment.center,
                      child: pw.Text(
                        'موضع الختم الرسمي\nلنادي التضامن',
                        textAlign: pw.TextAlign.center,
                        style: const pw.TextStyle(fontSize: 7, color: PdfColors.blueGrey),
                      ),
                    ),

                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('مدير النادي: ${report.clubDirectorName}', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 8),
                        pw.Text('الاعتماد والختم: .......................................', style: const pw.TextStyle(fontSize: 8.5)),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 4),
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'وثيقة رياضية رسمية معتمدة صادرة عن نظام موناز (MONAZ) الميداني - نادي تضامن حضرموت | لا تتضمن أي مبالغ أو بدلات مالية',
                  style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600),
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
