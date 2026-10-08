import 'package:tadamon_attendance_app/features/backup/domain/entities/backup_package.dart';
import 'package:tadamon_attendance_app/features/backup/domain/repositories/backup_repository.dart';

class CreateBackupUseCase {
  const CreateBackupUseCase(this._repository);

  final BackupRepository _repository;

  Future<BackupPackage> call() {
    return _repository.createBackup();
  }
}
