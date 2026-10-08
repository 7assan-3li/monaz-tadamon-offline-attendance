final class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.sessionUuid,
    required this.action,
    required this.modifiedBy,
    required this.reason,
    required this.timestamp,
    required this.diff,
  });

  final String id;
  final String sessionUuid;
  final String action;
  final String modifiedBy;
  final String reason;
  final DateTime timestamp;
  final String diff;
}
