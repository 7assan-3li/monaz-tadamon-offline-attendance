import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tadamon_attendance_app/features/backup/domain/entities/backup_package.dart';

class BackupFileInfo {
  final String path;
  final String fileName;
  final int byteSize;
  final DateTime modifiedAt;

  const BackupFileInfo({
    required this.path,
    required this.fileName,
    required this.byteSize,
    required this.modifiedAt,
  });
}

class BackupFileService {
  static const String backupExtension = 'monaz';

  static Future<File> exportToFile(BackupPackage package) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final backupsDir = Directory(path.join(docsDir.path, 'backups'));
    if (!await backupsDir.exists()) {
      await backupsDir.create(recursive: true);
    }

    final now = DateTime.now();
    final dateStr =
        '${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final safeClubName = package.manifest.clubName
        .replaceAll(RegExp(r'[^\w\u0600-\u06FF]+'), '_')
        .replaceAll(RegExp(r'_+'), '_');

    final fileName = 'نسخة_احتياطية_${safeClubName}_$dateStr.$backupExtension';
    final file = File(path.join(backupsDir.path, fileName));
    await file.writeAsString(package.rawContent, flush: true);

    // On Android, also write directly into the public Downloads directory so the user sees it in My Files / Downloads
    if (Platform.isAndroid) {
      try {
        final publicDownloadDir = Directory('/storage/emulated/0/Download');
        if (publicDownloadDir.existsSync()) {
          final publicBackupDir = Directory(path.join(publicDownloadDir.path, 'Tadamon_Backups'));
          if (!publicBackupDir.existsSync()) {
            await publicBackupDir.create(recursive: true);
          }
          final publicFile = File(path.join(publicBackupDir.path, fileName));
          await publicFile.writeAsString(package.rawContent, flush: true);

          final rootDownloadFile = File(path.join(publicDownloadDir.path, fileName));
          await rootDownloadFile.writeAsString(package.rawContent, flush: true);
        }
      } catch (_) {}
    }

    return file;
  }

  static Future<void> shareBackupFile(File file, {String? clubName}) async {
    final fileName = path.basename(file.path);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, name: fileName, mimeType: 'application/octet-stream')],
        subject: 'نسخة احتياطية لنظام ${clubName ?? 'النادي'}',
        text:
            'مرفق ملف النسخة الاحتياطية الشاملة لنظام التحضير الميداني ($fileName). يمكنك حفظه على جهازك أو نقله عبر البلوتوث / فلاش ميموري / واتساب لاستيراده في التطبيق على أي جهاز آخر.',
      ),
    );
  }

  static Future<String?> pickAndReadBackupFile() async {
    try {
      final picked = await FilePicker.pickFile(
        type: FileType.any,
      );
      if (picked == null) {
        return null;
      }
      if (picked.path != null) {
        final file = File(picked.path!);
        if (await file.exists()) {
          return await file.readAsString();
        }
      }
      try {
        return await picked.xFile.readAsString();
      } catch (_) {
        final bytes = await picked.readAsBytes();
        return utf8.decode(bytes);
      }
    } catch (_) {
      return null;
    }
  }

  static Future<List<BackupFileInfo>> listLocalBackups() async {
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final backupsDir = Directory(path.join(docsDir.path, 'backups'));
      if (!await backupsDir.exists()) {
        return [];
      }
      final entities = await backupsDir.list().toList();
      final files = <BackupFileInfo>[];
      for (final entity in entities) {
        if (entity is File &&
            (entity.path.endsWith('.$backupExtension') ||
                entity.path.endsWith('.json'))) {
          final stat = await entity.stat();
          files.add(
            BackupFileInfo(
              path: entity.path,
              fileName: path.basename(entity.path),
              byteSize: stat.size,
              modifiedAt: stat.modified,
            ),
          );
        }
      }
      files.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
      return files;
    } catch (_) {
      return [];
    }
  }
}
