import 'package:drift/drift.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/audit_entry.dart';

class AuditLogDao {
  AuditLogDao(this._database);

  final AppDatabase _database;

  Future<void> logExceptionalChange({
    required String sessionUuid,
    required String playerId,
    required AttendanceStatus newStatus,
    required String modifiedBy,
    required String reason,
  }) async {
    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      throw ArgumentError('سبب التعديل الاستثنائي إجباري ولا يمكن تركه فارغاً.');
    }

    await _database.transaction(() async {
      // Find existing record
      final existingRecord = await (_database.select(_database.attendanceRecords)
            ..where((tbl) =>
                tbl.sessionUuid.equals(sessionUuid) & tbl.playerId.equals(playerId)))
          .getSingleOrNull();

      final previousStatus = existingRecord?.status ?? 'unrecorded';

      // Update or insert attendance record
      final newStatusStr = newStatus.dbValue;
      if (existingRecord != null) {
        await (_database.update(_database.attendanceRecords)
              ..where((tbl) =>
                  tbl.sessionUuid.equals(sessionUuid) &
                  tbl.playerId.equals(playerId)))
            .write(
          AttendanceRecordsCompanion(
            status: Value(newStatusStr),
            reason: Value(trimmedReason),
          ),
        );
      } else {
        await _database.into(_database.attendanceRecords).insert(
              AttendanceRecordsCompanion.insert(
                id: '${sessionUuid}_$playerId',
                sessionUuid: sessionUuid,
                playerId: playerId,
                status: newStatusStr,
                reason: Value(trimmedReason),
              ),
            );
      }

      // Write immutable audit log
      final logId = 'audit_${DateTime.now().millisecondsSinceEpoch}_$playerId';
      await _database.into(_database.auditLogs).insert(
            AuditLogsCompanion.insert(
              id: logId,
              sessionUuid: sessionUuid,
              action: 'تعديل استثنائي لحالة اللاعب',
              modifiedBy: modifiedBy,
              reason: trimmedReason,
              timestamp: DateTime.now().toUtc(),
              diff: 'من: $previousStatus إلى: $newStatusStr',
            ),
          );
    });
  }

  Future<void> approveSession({
    required String sessionUuid,
    required String approvedBy,
  }) async {
    await (_database.update(_database.sessions)
          ..where((tbl) => tbl.sessionUuid.equals(sessionUuid)))
        .write(
      SessionsCompanion(
        status: const Value('approved'),
        approvedAt: Value(DateTime.now().toUtc()),
        approvedBy: Value(approvedBy),
      ),
    );
  }

  Future<List<AuditEntry>> getAuditLogs({String? sessionUuid}) async {
    final query = _database.select(_database.auditLogs)
      ..orderBy([
        (tbl) => OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.desc),
      ]);

    if (sessionUuid != null) {
      query.where((tbl) => tbl.sessionUuid.equals(sessionUuid));
    }

    final rows = await query.get();
    return rows
        .map(
          (row) => AuditEntry(
            id: row.id,
            sessionUuid: row.sessionUuid,
            action: row.action,
            modifiedBy: row.modifiedBy,
            reason: row.reason,
            timestamp: row.timestamp,
            diff: row.diff,
          ),
        )
        .toList();
  }
}
