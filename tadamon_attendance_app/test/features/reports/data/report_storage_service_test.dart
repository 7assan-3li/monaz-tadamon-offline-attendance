import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/report_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late ReportStorageService storageService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('tadamon_reports_test_');
    storageService = const ReportStorageService();
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ReportStorageService Unit Tests', () {
    test('resolves custom export directory successfully', () async {
      final customPath = '${tempDir.path}${Platform.pathSeparator}Custom_Club_Reports';
      final dir = await storageService.resolveExportDirectory(customPath: customPath);
      expect(dir.existsSync(), isTrue);
      expect(dir.path, customPath);
    });

    test('saves report bytes to disk and sanitizes file name', () async {
      final customPath = '${tempDir.path}${Platform.pathSeparator}Export_Folder';
      const rawFileName = 'كشف:حضور/الفريق*الأول?.pdf';
      final dummyBytes = [1, 2, 3, 4, 5];

      final file = await storageService.saveReportFile(
        fileName: rawFileName,
        bytes: dummyBytes,
        customDirectory: customPath,
      );

      expect(file.existsSync(), isTrue);
      expect(await file.readAsBytes(), equals(dummyBytes));
      final fileName = file.uri.pathSegments.last;
      expect(fileName.contains(':'), isFalse);
      expect(fileName.contains('*'), isFalse);
      expect(fileName.contains('?'), isFalse);
    });

    test('retrieves directory presets map with non-empty paths', () async {
      final presets = await storageService.getDirectoryPresets();
      expect(presets, isA<Map<String, String>>());
    });
  });
}
