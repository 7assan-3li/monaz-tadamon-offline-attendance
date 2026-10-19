import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReportStorageService {
  const ReportStorageService();

  /// Resolves the directory where reports should be saved.
  /// If [customPath] is provided and accessible, it uses it.
  /// Otherwise, falls back to the system Downloads or Documents directory
  /// with a dedicated 'Tadamon_Reports' folder.
  Future<Directory> resolveExportDirectory({String? customPath}) async {
    if (customPath != null && customPath.trim().isNotEmpty) {
      try {
        final dir = Directory(customPath.trim());
        if (!dir.existsSync()) {
          await dir.create(recursive: true);
        }
        return dir;
      } catch (_) {
        // Fallback if custom path is invalid or lacks write permissions
      }
    }

    if (Platform.isAndroid) {
      try {
        final publicDownload = Directory('/storage/emulated/0/Download/Tadamon_Reports');
        if (!publicDownload.existsSync()) {
          await publicDownload.create(recursive: true);
        }
        return publicDownload;
      } catch (_) {
        try {
          final directDownload = Directory('/storage/emulated/0/Download');
          if (directDownload.existsSync()) {
            return directDownload;
          }
        } catch (_) {}
      }
    }

    try {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) {
        final reportsDir = Directory(p.join(downloads.path, 'Tadamon_Reports'));
        if (!reportsDir.existsSync()) {
          await reportsDir.create(recursive: true);
        }
        return reportsDir;
      }
    } catch (_) {
      // If downloads directory is inaccessible, fallback to documents
    }

    final docs = await getApplicationDocumentsDirectory();
    final reportsDir = Directory(p.join(docs.path, 'Tadamon_Reports'));
    if (!reportsDir.existsSync()) {
      await reportsDir.create(recursive: true);
    }
    return reportsDir;
  }

  /// Saves report bytes to disk in the resolved directory.
  Future<File> saveReportFile({
    required String fileName,
    required List<int> bytes,
    String? customDirectory,
  }) async {
    final dir = await resolveExportDirectory(customPath: customDirectory);
    final sanitizedName = _sanitizeFileName(fileName);
    final targetPath = p.join(dir.path, sanitizedName);
    final file = File(targetPath);
    await file.writeAsBytes(bytes, flush: true);

    // On Android, ensure a copy is also in the public Download directory
    if (Platform.isAndroid && !dir.path.startsWith('/storage/emulated/0/Download')) {
      try {
        final publicDir = Directory('/storage/emulated/0/Download/Tadamon_Reports');
        if (!publicDir.existsSync()) {
          await publicDir.create(recursive: true);
        }
        final publicFile = File(p.join(publicDir.path, sanitizedName));
        await publicFile.writeAsBytes(bytes, flush: true);
      } catch (_) {}
    }

    return file;
  }

  /// Triggers the native offline share sheet (OS intent).
  Future<ShareResult> shareReportFile(
    String filePath, {
    String? subject,
    String? text,
  }) async {
    final xFile = XFile(filePath);
    return SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        subject: subject,
        text: text,
      ),
    );
  }

  /// Opens the report file directly in the system's registered application.
  Future<OpenResult> openReportFile(String filePath) async {
    return OpenFilex.open(filePath);
  }

  /// Returns common system directory presets for the settings UI.
  Future<Map<String, String>> getDirectoryPresets() async {
    final presets = <String, String>{};
    if (Platform.isAndroid) {
      presets['downloads'] = '/storage/emulated/0/Download/Tadamon_Reports';
    } else {
      try {
        final downloads = await getDownloadsDirectory();
        if (downloads != null) {
          presets['downloads'] = p.join(downloads.path, 'Tadamon_Reports');
        }
      } catch (_) {}
    }

    try {
      final docs = await getApplicationDocumentsDirectory();
      presets['documents'] = p.join(docs.path, 'Tadamon_Reports');
    } catch (_) {}

    try {
      final appSupport = await getApplicationSupportDirectory();
      presets['app_storage'] = p.join(appSupport.path, 'Tadamon_Reports');
    } catch (_) {}

    return presets;
  }

  String _sanitizeFileName(String rawName) {
    // Replace characters that are invalid across Android, Windows, Linux, and iOS
    final sanitized = rawName.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return sanitized.isEmpty ? 'report_${DateTime.now().millisecondsSinceEpoch}' : sanitized;
  }
}
