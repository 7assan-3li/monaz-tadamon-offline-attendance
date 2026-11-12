import 'dart:math';
import 'package:excel/excel.dart';
import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';

class ExcelImportResult {
  const ExcelImportResult({
    required this.players,
    required this.warnings,
    required this.totalRowsRead,
  });

  final List<ClubPlayer> players;
  final List<String> warnings;
  final int totalRowsRead;
}

class ExcelPlayersService {
  const ExcelPlayersService();

  /// توليد قالب إكسل رسمي معتمد لتسجيل لاعبي النادي
  List<int> generateTemplate({
    required String clubName,
    String? teamName,
  }) {
    final excel = Excel.createExcel();
    const sheetName = 'كشف تسجيل اللاعبين';
    excel.rename('Sheet1', sheetName);
    final sheet = excel[sheetName];

    // 1. الترويسة الرسمية للنادي
    sheet.appendRow([
      TextCellValue('الجمهورية اليمنية - $clubName'),
    ]);
    sheet.appendRow([
      TextCellValue('كشف تسجيل اللاعبين المعتمد | الفئة المستهدفة: ${teamName ?? 'كافة الفئات'} | نظام موناز للتحضير الرياضي الميداني'),
    ]);
    sheet.appendRow([
      TextCellValue('تعليمات: يرجى تعبئة أسماء اللاعبين وأرقام القمصان بدقة. رقم القميص يجب أن يكون فريداً داخل نفس الفريق.'),
    ]);
    sheet.appendRow([TextCellValue('')]); // سطر فاصل

    // 2. ترويسة أعمدة الجدول
    sheet.appendRow([
      TextCellValue('رقم القميص'),
      TextCellValue('اسم اللاعب الكامل'),
      TextCellValue('المركز / الخانة'),
      TextCellValue('الفئة / التشكيلة'),
      TextCellValue('ملاحظات'),
    ]);

    // 3. صفوف نموذجية توضيحية للمستخدم
    final sampleRows = [
      [IntCellValue(1), TextCellValue('محمد سالم باحاج'), TextCellValue('حارس مرمى'), TextCellValue(teamName ?? 'الفريق الأول'), TextCellValue('أساسي')],
      [IntCellValue(4), TextCellValue('عمر خالد بن محفوظ'), TextCellValue('مدافع'), TextCellValue(teamName ?? 'الفريق الأول'), TextCellValue('كابتن الفريق')],
      [IntCellValue(10), TextCellValue('سعيد أحمد العمودي'), TextCellValue('صانع ألعاب'), TextCellValue(teamName ?? 'الفريق الأول'), TextCellValue('')],
      [IntCellValue(9), TextCellValue('عبدالله علي باوزير'), TextCellValue('مهاجم'), TextCellValue(teamName ?? 'الفريق الأول'), TextCellValue('')],
    ];

    for (final row in sampleRows) {
      sheet.appendRow(row);
    }

    // 4. ضبط أبعاد الأعمدة لقراءة وتنسيق مثالي
    sheet.setColumnWidth(0, 14.0); // رقم القميص
    sheet.setColumnWidth(1, 32.0); // اسم اللاعب
    sheet.setColumnWidth(2, 18.0); // المركز
    sheet.setColumnWidth(3, 20.0); // الفئة
    sheet.setColumnWidth(4, 25.0); // ملاحظات

    return excel.encode()!;
  }

  /// تصدير كشف لاعبي الفريق الحاليين إلى ملف إكسل رسمي
  List<int> exportSquadToExcel({
    required String clubName,
    required String teamName,
    required List<ClubPlayer> players,
  }) {
    final excel = Excel.createExcel();
    final sheetName = teamName.replaceAll(RegExp(r'[\\/*?:\[\]]'), '').trim();
    excel.rename('Sheet1', sheetName.isEmpty ? 'كشف الفريق' : sheetName);
    final sheet = excel[sheetName.isEmpty ? 'كشف الفريق' : sheetName];

    // الترويسة الرسمية
    sheet.appendRow([
      TextCellValue('$clubName - كشف اللاعبين المعتمدين'),
    ]);
    sheet.appendRow([
      TextCellValue('الفريق: $teamName | إجمالي اللاعبين: ${players.length} | تاريخ التصدير: ${DateTime.now().toLocal().toString().split(' ')[0]}'),
    ]);
    sheet.appendRow([TextCellValue('')]);

    // ترويسة الجدول
    sheet.appendRow([
      TextCellValue('م'),
      TextCellValue('رقم القميص'),
      TextCellValue('اسم اللاعب الكامل'),
      TextCellValue('المركز'),
      TextCellValue('تاريخ التسجيل'),
      TextCellValue('ملاحظات'),
    ]);

    var index = 1;
    for (final p in players) {
      sheet.appendRow([
        IntCellValue(index++),
        p.jerseyNumber != null ? IntCellValue(p.jerseyNumber!) : TextCellValue('-'),
        TextCellValue(p.name),
        TextCellValue(p.position ?? 'لاعب'),
        TextCellValue(p.joinDate.toLocal().toString().split(' ')[0]),
        TextCellValue(p.notes ?? ''),
      ]);
    }

    sheet.setColumnWidth(0, 8.0);
    sheet.setColumnWidth(1, 14.0);
    sheet.setColumnWidth(2, 32.0);
    sheet.setColumnWidth(3, 18.0);
    sheet.setColumnWidth(4, 16.0);
    sheet.setColumnWidth(5, 25.0);

    return excel.encode()!;
  }

  /// تحليل واستخراج اللاعبين من ملف إكسل مع التحقق الشامل
  ExcelImportResult parsePlayersFromExcel(
    List<int> fileBytes, {
    required String defaultTeamId,
  }) {
    final excel = Excel.decodeBytes(fileBytes);
    final warnings = <String>[];
    final parsedPlayers = <ClubPlayer>[];

    // اختيار أول ورقة تحتوي على بيانات
    String? targetSheetName;
    for (final name in excel.tables.keys) {
      final t = excel.tables[name];
      if (t != null && t.maxRows > 0) {
        targetSheetName = name;
        break;
      }
    }

    if (targetSheetName == null) {
      throw const FormatException('ملف الإكسل فارغ ولا يحتوي على أي جداول.');
    }

    final table = excel.tables[targetSheetName]!;
    final rows = table.rows;

    // البحث الذكي عن صف الترويسة في أول 6 صفوف
    int headerRowIndex = -1;
    int nameColIndex = -1;
    int jerseyColIndex = -1;
    int posColIndex = -1;
    int teamColIndex = -1;
    int notesColIndex = -1;

    for (var r = 0; r < min(rows.length, 6); r++) {
      final row = rows[r];
      for (var c = 0; c < row.length; c++) {
        final cellVal = _extractCellValue(row[c]).trim().toLowerCase();
        if (nameColIndex == -1 &&
            (cellVal.contains('الاسم') ||
                cellVal.contains('اسم اللاعب') ||
                cellVal.contains('name') ||
                cellVal == 'اللاعب')) {
          nameColIndex = c;
          headerRowIndex = r;
        } else if (jerseyColIndex == -1 &&
            (cellVal.contains('القميص') ||
                cellVal.contains('رقم') ||
                cellVal.contains('فانلة') ||
                cellVal.contains('jersey') ||
                cellVal == 'no' ||
                cellVal == '#')) {
          jerseyColIndex = c;
          headerRowIndex = r;
        } else if (posColIndex == -1 &&
            (cellVal.contains('المركز') ||
                cellVal.contains('الخانة') ||
                cellVal.contains('pos') ||
                cellVal.contains('position'))) {
          posColIndex = c;
        } else if (teamColIndex == -1 &&
            (cellVal.contains('الفريق') ||
                cellVal.contains('الفئة') ||
                cellVal.contains('التشكيلة') ||
                cellVal.contains('team') ||
                cellVal.contains('category'))) {
          teamColIndex = c;
        } else if (notesColIndex == -1 &&
            (cellVal.contains('ملاحظات') ||
                cellVal.contains('ملاحظة') ||
                cellVal.contains('notes'))) {
          notesColIndex = c;
        }
      }
      if (nameColIndex != -1) break;
    }

    // إذا لم نجد الترويسة، نفترض الأعمدة الافتراضية
    if (nameColIndex == -1) {
      if (rows.isEmpty) {
        throw const FormatException('الملف لا يحتوي على أي صفوف صالحة.');
      }
      // افتراض: العمود الثاني (1) هو الاسم أو العمود الأول (0)
      nameColIndex = 1 < rows[0].length ? 1 : 0;
      jerseyColIndex = 0;
      posColIndex = 2 < rows[0].length ? 2 : -1;
      headerRowIndex = 0;
      warnings.add('لم يتم العثور على ترويسة صريحة، تم الاعتماد على الترتيب الافتراضي للأعمدة.');
    }

    final startRow = headerRowIndex + 1;
    final now = DateTime.now().toUtc();
    final seenNumbersInFile = <int, String>{};

    for (var r = startRow; r < rows.length; r++) {
      final row = rows[r];
      if (row.isEmpty) continue;

      final name = nameColIndex < row.length ? _extractCellValue(row[nameColIndex]).trim() : '';

      // تجاهل الصفوف الفارغة أو صفوف التوقيعات/الإجماليات
      if (name.length < 2 ||
          name.contains('توقيع') ||
          name.contains('إجمالي') ||
          name.contains('المدرب') ||
          name.contains('الإداري')) {
        continue;
      }

      int? jerseyNumber;
      if (jerseyColIndex != -1 && jerseyColIndex < row.length) {
        final val = _extractCellValue(row[jerseyColIndex]).trim();
        jerseyNumber = int.tryParse(val);
      }

      final position = (posColIndex != -1 && posColIndex < row.length)
          ? _extractCellValue(row[posColIndex]).trim()
          : 'لاعب';

      final notes = (notesColIndex != -1 && notesColIndex < row.length)
          ? _extractCellValue(row[notesColIndex]).trim()
          : null;

      // فحص تكرار رقم القميص داخل الملف نفسه
      if (jerseyNumber != null) {
        if (seenNumbersInFile.containsKey(jerseyNumber)) {
          warnings.add('تنبيه: رقم القميص ($jerseyNumber) مكرر للاعبين "$name" و "${seenNumbersInFile[jerseyNumber]}".');
        } else {
          seenNumbersInFile[jerseyNumber] = name;
        }
      }

      final randomSuffix = Random().nextInt(99999);
      final playerId = 'player-${now.microsecondsSinceEpoch}-$r-$randomSuffix';

      parsedPlayers.add(
        ClubPlayer(
          id: playerId,
          name: name,
          teamId: defaultTeamId,
          jerseyNumber: jerseyNumber,
          position: position.isEmpty ? 'لاعب' : position,
          notes: notes?.isEmpty == true ? null : notes,
          joinDate: now,
          updatedAt: now,
        ),
      );
    }

    if (parsedPlayers.isEmpty) {
      throw const FormatException('لم يتم العثور على أي أسماء لاعبين صالحة في الملف المرفق.');
    }

    return ExcelImportResult(
      players: parsedPlayers,
      warnings: warnings,
      totalRowsRead: rows.length - startRow,
    );
  }

  String _extractCellValue(Data? cell) {
    if (cell == null || cell.value == null) return '';
    final val = cell.value;
    if (val is TextCellValue) return val.value.toString();
    if (val is IntCellValue) return val.value.toString();
    if (val is DoubleCellValue) return val.value.toInt().toString();
    return val.toString();
  }
}

