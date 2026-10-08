import 'package:tadamon_attendance_app/features/backup/domain/entities/backup_package.dart';

abstract interface class BackupRepository {
  Future<BackupPackage> createBackup();

  Future<BackupVerificationResult> verifyBackup(String packageContent);

  Future<void> restoreBackup(String packageContent);
}
