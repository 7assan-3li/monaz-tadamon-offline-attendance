import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/features/backup/domain/entities/backup_manifest.dart';
import 'package:tadamon_attendance_app/features/backup/domain/entities/backup_package.dart';

class BackupLocalDataSource {
  BackupLocalDataSource(this._database);

  final AppDatabase _database;
  final Sha256 _sha256 = Sha256();

  static const String packageFormatHeader = 'MONAZ_TADAMON_BACKUP_V1';

  Future<BackupPackage> createBackupPackage() async {
    final settings = await (_database.select(_database.clubSettings)..limit(1)).getSingleOrNull();
    final teams = await _database.select(_database.teams).get();
    final players = await _database.select(_database.players).get();
    final sessions = await _database.select(_database.sessions).get();
    final attendanceRecords = await _database.select(_database.attendanceRecords).get();
    final auditLogs = await _database.select(_database.auditLogs).get();

    final dataPayload = {
      'club_settings': settings == null
          ? null
          : {
              'club_name': settings.clubName,
              'season': settings.season,
              'admin_name': settings.adminName,
              'manager_name': settings.managerName,
              'pin_code_hash': settings.pinCodeHash,
              'entitlement_sport_enabled': settings.entitlementSportEnabled,
              'entitlement_counts_excused': settings.entitlementCountsExcused,
            },
      'teams': teams
          .map((t) => {
                'id': t.id,
                'name': t.name,
                'category': t.category,
                'created_at': t.createdAt.toIso8601String(),
                'updated_at': t.updatedAt.toIso8601String(),
              })
          .toList(),
      'players': players
          .map((p) => {
                'id': p.id,
                'name': p.name,
                'team_id': p.teamId,
                'jersey_number': p.jerseyNumber,
                'position': p.position,
                'join_date': p.joinDate.toIso8601String(),
                'is_archived': p.isArchived,
                'notes': p.notes,
                'updated_at': p.updatedAt.toIso8601String(),
              })
          .toList(),
      'sessions': sessions
          .map((s) => {
                'session_uuid': s.sessionUuid,
                'team_id': s.teamId,
                'date': s.sessionDate.toIso8601String(),
                'type': s.type,
                'period': s.period,
                'location': s.location,
                'is_cancelled': s.isCancelled,
                'counts_in_attendance': s.countsInAttendance,
                'is_dispatched': s.isDispatched,
                'dispatched_at': s.dispatchedAt?.toIso8601String(),
                'is_locked': s.isLocked,
                'sync_status': s.syncStatus,
                'session_hash': s.sessionHash,
                'status': s.status,
                'approved_at': s.approvedAt?.toIso8601String(),
                'approved_by': s.approvedBy,
              })
          .toList(),
      'attendance_records': attendanceRecords
          .map((r) => {
                'id': r.id,
                'session_uuid': r.sessionUuid,
                'player_id': r.playerId,
                'status': r.status,
                'late_minutes': r.lateMinutes,
                'reason': r.reason,
                'notes': r.notes,
              })
          .toList(),
      'audit_logs': auditLogs
          .map((a) => {
                'id': a.id,
                'session_uuid': a.sessionUuid,
                'action': a.action,
                'modified_by': a.modifiedBy,
                'reason': a.reason,
                'timestamp': a.timestamp.toIso8601String(),
                'diff': a.diff,
              })
          .toList(),
    };

    final rawDataJson = jsonEncode(dataPayload);
    final dataBytes = utf8.encode(rawDataJson);
    final hashResult = await _sha256.hash(dataBytes);
    final checksumHex = hashResult.bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    final now = DateTime.now().toUtc();
    final manifest = BackupManifest(
      backupId: 'TD_BAK_${now.millisecondsSinceEpoch}',
      createdAt: now,
      appVersion: '1.0.0+1',
      clubName: settings?.clubName ?? 'نادي تضامن حضرموت',
      sha256Checksum: checksumHex,
      tableCounts: {
        'teams': teams.length,
        'players': players.length,
        'sessions': sessions.length,
        'attendance_records': attendanceRecords.length,
        'audit_logs': auditLogs.length,
      },
    );

    final packageContainer = {
      'format': packageFormatHeader,
      'manifest': manifest.toJson(),
      'data': rawDataJson,
    };

    return BackupPackage(
      manifest: manifest,
      rawContent: jsonEncode(packageContainer),
    );
  }

  Future<BackupVerificationResult> verifyPackage(String packageContent) async {
    try {
      final decoded = jsonDecode(packageContent) as Map<String, dynamic>;
      if (decoded['format'] != packageFormatHeader) {
        return const BackupVerificationResult(
          isValid: false,
          manifest: null,
          errorMessage: 'صيغة الملف غير متوافقة مع نظام نادي التضامن.',
        );
      }

      final manifestJson = decoded['manifest'] as Map<String, dynamic>;
      final manifest = BackupManifest.fromJson(manifestJson);
      final rawData = decoded['data'] as String;

      final dataBytes = utf8.encode(rawData);
      final hashResult = await _sha256.hash(dataBytes);
      final computedChecksum = hashResult.bytes
          .map((b) => b.toRadixString(16).padLeft(2, '0'))
          .join();

      if (computedChecksum.toLowerCase() != manifest.sha256Checksum.toLowerCase()) {
        return const BackupVerificationResult(
          isValid: false,
          manifest: null,
          errorMessage: 'فشل التحقق من ختم الحماية الرقمي SHA-256 (الملف تالف أو معدل).',
        );
      }

      return BackupVerificationResult(
        isValid: true,
        manifest: manifest,
      );
    } catch (e) {
      return BackupVerificationResult(
        isValid: false,
        manifest: null,
        errorMessage: 'تعذر قراءة ملف النسخة الاحتياطية: $e',
      );
    }
  }

  Future<void> restorePackage(String packageContent) async {
    final verification = await verifyPackage(packageContent);
    if (!verification.isValid || verification.manifest == null) {
      throw FormatException(
        verification.errorMessage ?? 'فشل التحقق من سلامة النسخة الاحتياطية.',
      );
    }

    final decoded = jsonDecode(packageContent) as Map<String, dynamic>;
    final rawData = decoded['data'] as String;
    final data = jsonDecode(rawData) as Map<String, dynamic>;

    await _database.transaction(() async {
      // 1. Wipe dependent athletic tables (CASCADE safe)
      await _database.delete(_database.auditLogs).go();
      await _database.delete(_database.attendanceRecords).go();
      await _database.delete(_database.sessions).go();
      await _database.delete(_database.players).go();
      await _database.delete(_database.teams).go();

      // 2. Restore Teams
      final teamsList = (data['teams'] as List<dynamic>?) ?? [];
      for (final t in teamsList) {
        final tm = t as Map<String, dynamic>;
        await _database.into(_database.teams).insert(
              TeamsCompanion.insert(
                id: tm['id'] as String,
                name: tm['name'] as String,
                category: tm['category'] as String,
                createdAt: DateTime.parse(tm['created_at'] as String),
                updatedAt: DateTime.parse(tm['updated_at'] as String),
              ),
            );
      }

      // 3. Restore Players
      final playersList = (data['players'] as List<dynamic>?) ?? [];
      for (final p in playersList) {
        final pm = p as Map<String, dynamic>;
        await _database.into(_database.players).insert(
              PlayersCompanion.insert(
                id: pm['id'] as String,
                name: pm['name'] as String,
                teamId: pm['team_id'] as String,
                jerseyNumber: Value(pm['jersey_number'] as int?),
                position: Value(pm['position'] as String?),
                joinDate: DateTime.parse(pm['join_date'] as String),
                isArchived: Value((pm['is_archived'] as bool?) ?? false),
                notes: Value(pm['notes'] as String?),
                updatedAt: DateTime.parse(pm['updated_at'] as String),
              ),
            );
      }

      // 4. Restore Sessions
      final sessionsList = (data['sessions'] as List<dynamic>?) ?? [];
      for (final s in sessionsList) {
        final sm = s as Map<String, dynamic>;
        await _database.into(_database.sessions).insert(
              SessionsCompanion.insert(
                sessionUuid: sm['session_uuid'] as String,
                teamId: sm['team_id'] as String,
                sessionDate: DateTime.parse(sm['date'] as String),
                type: Value((sm['type'] as String?) ?? 'تمرين'),
                period: Value((sm['period'] as String?) ?? 'مسائي'),
                location: Value(sm['location'] as String?),
                isCancelled: Value((sm['is_cancelled'] as bool?) ?? false),
                countsInAttendance: Value((sm['counts_in_attendance'] as bool?) ?? true),
                isDispatched: Value((sm['is_dispatched'] as bool?) ?? true),
                dispatchedAt: Value(sm['dispatched_at'] == null ? null : DateTime.parse(sm['dispatched_at'] as String)),
                isLocked: Value((sm['is_locked'] as bool?) ?? true),
                syncStatus: Value((sm['sync_status'] as String?) ?? 'local'),
                sessionHash: sm['session_hash'] as String,
                status: Value((sm['status'] as String?) ?? 'approved'),
                approvedAt: Value(sm['approved_at'] == null ? null : DateTime.parse(sm['approved_at'] as String)),
                approvedBy: Value(sm['approved_by'] as String?),
              ),
            );
      }

      // 5. Restore Attendance Records
      final attendanceList = (data['attendance_records'] as List<dynamic>?) ?? [];
      for (final r in attendanceList) {
        final rm = r as Map<String, dynamic>;
        await _database.into(_database.attendanceRecords).insert(
              AttendanceRecordsCompanion.insert(
                id: rm['id'] as String,
                sessionUuid: rm['session_uuid'] as String,
                playerId: rm['player_id'] as String,
                status: rm['status'] as String,
                lateMinutes: Value((rm['late_minutes'] as int?) ?? 0),
                reason: Value(rm['reason'] as String?),
                notes: Value(rm['notes'] as String?),
              ),
            );
      }

      // 6. Restore Audit Logs
      final auditList = (data['audit_logs'] as List<dynamic>?) ?? [];
      for (final a in auditList) {
        final am = a as Map<String, dynamic>;
        await _database.into(_database.auditLogs).insert(
              AuditLogsCompanion.insert(
                id: am['id'] as String,
                sessionUuid: am['session_uuid'] as String,
                action: am['action'] as String,
                modifiedBy: am['modified_by'] as String,
                reason: am['reason'] as String,
                timestamp: DateTime.parse(am['timestamp'] as String),
                diff: am['diff'] as String,
              ),
            );
      }

      // 7. Update Club Settings (Non-Security metadata only)
      final settingsData = data['club_settings'] as Map<String, dynamic>?;
      if (settingsData != null) {
        final existing = await (_database.select(_database.clubSettings)..limit(1)).getSingleOrNull();
        if (existing != null) {
          await (_database.update(_database.clubSettings)..where((tbl) => tbl.id.equals(1))).write(
            ClubSettingsCompanion(
              clubName: Value(settingsData['club_name'] as String? ?? existing.clubName),
              season: Value(settingsData['season'] as String? ?? existing.season),
              adminName: Value(settingsData['admin_name'] as String? ?? existing.adminName),
              managerName: Value(settingsData['manager_name'] as String? ?? existing.managerName),
            ),
          );
        }
      }

      // CRITICAL SECURITY INVARIANT:
      // LicenseSecurityStore is NEVER touched or overwritten during backup restore.
      // Clock High-Watermark is preserved to prevent anti-tamper rollback exploits.
    });
  }
}
