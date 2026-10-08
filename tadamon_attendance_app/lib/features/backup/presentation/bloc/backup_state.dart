import 'package:tadamon_attendance_app/features/backup/domain/entities/backup_manifest.dart';
import 'package:tadamon_attendance_app/features/backup/domain/entities/backup_package.dart';

sealed class BackupState {
  const BackupState();
}

final class BackupInitial extends BackupState {
  const BackupInitial();
}

final class BackupInProgress extends BackupState {
  const BackupInProgress({required this.message});

  final String message;
}

final class BackupCreatedSuccess extends BackupState {
  const BackupCreatedSuccess(this.package);

  final BackupPackage package;
}

final class BackupVerifiedState extends BackupState {
  const BackupVerifiedState({
    required this.manifest,
    required this.packageContent,
  });

  final BackupManifest manifest;
  final String packageContent;
}

final class BackupRestoredSuccess extends BackupState {
  const BackupRestoredSuccess({required this.message});

  final String message;
}

final class BackupFailure extends BackupState {
  const BackupFailure(this.errorMessage);

  final String errorMessage;
}
