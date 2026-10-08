import 'package:tadamon_attendance_app/features/backup/domain/entities/backup_manifest.dart';

final class BackupPackage {
  const BackupPackage({
    required this.manifest,
    required this.rawContent,
  });

  final BackupManifest manifest;
  final String rawContent; // JSON serialized backup container
}

final class BackupVerificationResult {
  const BackupVerificationResult({
    required this.isValid,
    required this.manifest,
    this.errorMessage,
  });

  final bool isValid;
  final BackupManifest? manifest;
  final String? errorMessage;
}
