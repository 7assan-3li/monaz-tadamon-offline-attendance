import 'package:tadamon_attendance_app/features/backup/domain/entities/backup_package.dart';
import 'package:tadamon_attendance_app/features/backup/domain/repositories/backup_repository.dart';

class RestoreBackupUseCase {
  const RestoreBackupUseCase(this._repository);

  final BackupRepository _repository;

  Future<BackupVerificationResult> verify(String packageContent) {
    return _repository.verifyBackup(packageContent);
  }

  Future<void> call(String packageContent) {
    return _repository.restoreBackup(packageContent);
  }
}
