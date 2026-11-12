import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/features/players/data/datasources/excel_players_service.dart';
import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';

void main() {
  const service = ExcelPlayersService();

  group('ExcelPlayersService - Template Generation', () {
    test('generates valid official Excel template with headers and samples', () {
      final bytes = service.generateTemplate(
        clubName: 'نادي تضامن حضرموت',
        teamName: 'الفريق الأول',
      );

      expect(bytes, isNotEmpty);
      final excel = Excel.decodeBytes(bytes);
      expect(excel.tables.keys, contains('كشف تسجيل اللاعبين'));

      final table = excel.tables['كشف تسجيل اللاعبين']!;
      expect(table.maxRows, greaterThanOrEqualTo(5));

      // Header row
      final headerRow = table.rows[4].map((c) => c?.value.toString()).toList();
      expect(headerRow, contains('اسم اللاعب الكامل'));
      expect(headerRow, contains('رقم القميص'));
      expect(headerRow, contains('المركز / الخانة'));
    });
  });

  group('ExcelPlayersService - Squad Export', () {
    test('exports current squad to Excel with correct rows and metadata', () {
      final now = DateTime.now().toUtc();
      final players = [
        ClubPlayer(
          id: 'p-1',
          name: 'محمد سالم باحاج',
          teamId: 'team-first',
          jerseyNumber: 10,
          position: 'صانع ألعاب',
          joinDate: now,
          updatedAt: now,
        ),
        ClubPlayer(
          id: 'p-2',
          name: 'عمر خالد بن محفوظ',
          teamId: 'team-first',
          jerseyNumber: 4,
          position: 'مدافع',
          joinDate: now,
          updatedAt: now,
        ),
      ];

      final bytes = service.exportSquadToExcel(
        clubName: 'نادي تضامن حضرموت',
        teamName: 'الفريق الأول',
        players: players,
      );

      expect(bytes, isNotEmpty);
      final excel = Excel.decodeBytes(bytes);
      final table = excel.tables['الفريق الأول']!;

      expect(table.maxRows, greaterThanOrEqualTo(4));
      final allValues = table.rows
          .expand((r) => r.map((c) => c?.value?.toString() ?? ''))
          .toList();

      expect(allValues, contains('محمد سالم باحاج'));
      expect(allValues, contains('عمر خالد بن محفوظ'));
      expect(allValues, contains('10'));
      expect(allValues, contains('4'));
    });
  });

  group('ExcelPlayersService - Parsing & Validation', () {
    test('parses generated template rows accurately', () {
      final templateBytes = service.generateTemplate(
        clubName: 'نادي تضامن حضرموت',
        teamName: 'الفريق الأول',
      );

      final result = service.parsePlayersFromExcel(
        templateBytes,
        defaultTeamId: 'team-first',
      );

      expect(result.players.length, equals(4)); // 4 sample players
      expect(result.players[0].name, equals('محمد سالم باحاج'));
      expect(result.players[0].jerseyNumber, equals(1));
      expect(result.players[0].position, equals('حارس مرمى'));
      expect(result.players[0].teamId, equals('team-first'));
    });

    test('flags warnings when file contains duplicate jersey numbers', () {
      final excel = Excel.createExcel();
      const sheetName = 'اللاعبين';
      excel.rename('Sheet1', sheetName);
      final sheet = excel[sheetName];

      sheet.appendRow([TextCellValue('رقم القميص'), TextCellValue('اسم اللاعب')]);
      sheet.appendRow([IntCellValue(10), TextCellValue('سالم أحمد العمودي')]);
      sheet.appendRow([IntCellValue(10), TextCellValue('عبدالله علي باوزير')]);

      final bytes = excel.encode()!;
      final result = service.parsePlayersFromExcel(bytes, defaultTeamId: 'team-first');

      expect(result.players.length, equals(2));
      expect(result.warnings, isNotEmpty);
      expect(result.warnings.first, contains('مكرر'));
    });

    test('throws FormatException on empty tables', () {
      final excel = Excel.createExcel();
      final bytes = excel.encode()!;

      expect(
        () => service.parsePlayersFromExcel(bytes, defaultTeamId: 'team-first'),
        throwsFormatException,
      );
    });
  });
}

