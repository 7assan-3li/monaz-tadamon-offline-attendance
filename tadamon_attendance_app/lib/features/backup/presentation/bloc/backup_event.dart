sealed class BackupEvent {
  const BackupEvent();
}

final class CreateBackupRequestedEvent extends BackupEvent {
  const CreateBackupRequestedEvent();
}

final class VerifyBackupRequestedEvent extends BackupEvent {
  const VerifyBackupRequestedEvent(this.packageContent);

  final String packageContent;
}

final class RestoreBackupConfirmedEvent extends BackupEvent {
  const RestoreBackupConfirmedEvent(this.packageContent);

  final String packageContent;
}

final class ResetBackupStateEvent extends BackupEvent {
  const ResetBackupStateEvent();
}
