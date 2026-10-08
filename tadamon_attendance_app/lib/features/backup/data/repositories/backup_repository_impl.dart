import 'package:tadamon_attendance_app/features/backup/data/datasources/backup_local_datasource.dart';
import 'package:tadamon_attendance_app/features/backup/domain/entities/backup_package.dart';
import 'package:tadamon_attendance_app/features/backup/domain/repositories/backup_repository.dart';

class BackupRepositoryImpl implements BackupRepository {
  const BackupRepositoryImpl(this._dataSource);

  final BackupLocalDataSource _dataSource;

  @override
  Future<BackupPackage> createBackup() {
    return _dataSource.createBackupPackage();
  }

  @override
  Future<BackupVerificationResult> verifyBackup(String packageContent) {
    return _dataSource.verifyPackage(packageContent);
  }

  @override
  Future<void> restoreBackup(String packageContent) {
    return _dataSource.restorePackage(packageContent);
  }
}
