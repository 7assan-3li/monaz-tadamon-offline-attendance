enum SyncStatus {
  success,
  duplicate,
  invalidSignature,
  error,
}

final class SyncResult {
  const SyncResult({
    required this.status,
    required this.sessionUuid,
    required this.message,
    this.importedItemsCount = 0,
  });

  final SyncStatus status;
  final String sessionUuid;
  final String message;
  final int importedItemsCount;

  bool get isSuccess => status == SyncStatus.success;
  bool get isDuplicate => status == SyncStatus.duplicate;
}
