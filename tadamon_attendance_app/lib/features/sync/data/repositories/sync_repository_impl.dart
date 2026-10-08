import 'package:drift/drift.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/security/license_parser.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/sync/data/datasources/local_p2p_client.dart';
import 'package:tadamon_attendance_app/features/sync/data/datasources/local_p2p_server.dart';
import 'package:tadamon_attendance_app/features/sync/data/datasources/qr_codec.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/dispatch_payload.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/sync_result.dart';
import 'package:tadamon_attendance_app/features/sync/domain/repositories/sync_repository.dart';

final class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl({
    required this.database,
    QrCodec? codec,
    LicenseParser? parser,
    LocalP2pClient? p2pClient,
    this.explicitPairingSecret,
  })  : _codec = codec ?? const QrCodec(),
        _parser = parser ?? const LicenseParser(),
        _p2pClient = p2pClient ?? LocalP2pClient();

  final AppDatabase database;
  final QrCodec _codec;
  final LicenseParser _parser;
  final LocalP2pClient _p2pClient;
  final String? explicitPairingSecret;

  LocalP2pServer? _p2pServer;

  static const _defaultSecret = 'tadamon-pairing-secret-offline-v1';

  @override
  Future<String> exportSessionToQr(AttendanceSession session) async {
    final secret = await _getPairingSecret();
    final deviceId = await _getCurrentDeviceId();

    final absentees = session.items
        .where((item) =>
            item.status == PlayerAttendanceStatus.excused ||
            item.status == PlayerAttendanceStatus.unexcused)
        .map((item) => AbsenteePayloadItem(
              playerId: item.playerId,
              status: item.status,
            ))
        .toList(growable: false);

    final payload = DispatchPayload(
      sessionUuid: session.sessionUuid,
      teamId: session.teamId,
      sessionDate: session.date,
      sourceDeviceId: deviceId,
      absentees: absentees,
      signature: '',
    );

    return _codec.encode(
      payload: payload,
      pairingSecret: secret,
    );
  }

  @override
  Future<SyncResult> importSessionFromQr(String qrData) async {
    final secret = await _getPairingSecret();
    final currentDeviceId = await _getCurrentDeviceId();

    late final DispatchPayload payload;
    try {
      payload = await _codec.decode(
        rawData: qrData,
        pairingSecret: secret,
      );
    } on TamperedPayloadException {
      return const SyncResult(
        status: SyncStatus.invalidSignature,
        sessionUuid: '',
        message: 'كود الترحيل غير موثق أو تم التلاعب به.',
      );
    } catch (e) {
      return SyncResult(
        status: SyncStatus.error,
        sessionUuid: '',
        message: 'فشل قراءة كود الترحيل: $e',
      );
    }

    // 1. Idempotency Check: check if session already exists
    final existingSession = await (database.select(database.sessions)
          ..where((row) => row.sessionUuid.equals(payload.sessionUuid)))
        .getSingleOrNull();

    if (existingSession != null) {
      await _logSync(
        sessionUuid: payload.sessionUuid,
        channel: 'qr_air_gap',
        sourceDevice: payload.sourceDeviceId,
        targetDevice: currentDeviceId,
        status: 'duplicate',
      );

      return SyncResult(
        status: SyncStatus.duplicate,
        sessionUuid: payload.sessionUuid,
        message: 'هذا التمرين مستلم ومسجل مسبقاً.',
      );
    }

    // 2. Fetch team players
    final players = await (database.select(database.players)
          ..where((row) =>
              row.teamId.equals(payload.teamId) &
              row.isArchived.equals(false)))
        .get();

    final absenteeMap = <String, PlayerAttendanceStatus>{
      for (final a in payload.absentees) a.playerId: a.status,
    };

    // 3. Atomically insert session and attendance records
    await database.transaction(() async {
      await database.into(database.sessions).insert(
            SessionsCompanion.insert(
              sessionUuid: payload.sessionUuid,
              teamId: payload.teamId,
              sessionDate: payload.sessionDate,
              sessionHash: 'sync-${payload.sessionUuid}',
              isDispatched: const Value(true),
              isLocked: const Value(true),
              dispatchedAt: Value(payload.sessionDate),
              syncStatus: const Value('received'),
              status: const Value('pending_approval'),
            ),
          );

      for (final player in players) {
        final status = absenteeMap[player.id] ?? PlayerAttendanceStatus.present;
        await database.into(database.attendanceRecords).insert(
              AttendanceRecordsCompanion.insert(
                id: '${payload.sessionUuid}-${player.id}',
                sessionUuid: payload.sessionUuid,
                playerId: player.id,
                status: status.value,
              ),
            );
      }

      await _logSync(
        sessionUuid: payload.sessionUuid,
        channel: 'qr_air_gap',
        sourceDevice: payload.sourceDeviceId,
        targetDevice: currentDeviceId,
        status: 'success',
      );
    });

    return SyncResult(
      status: SyncStatus.success,
      sessionUuid: payload.sessionUuid,
      message: 'تم استيراد تمرين اليوم بنجاح ✅',
      importedItemsCount: players.length,
    );
  }

  @override
  Future<void> startP2pServer({int port = 8089}) async {
    if (_p2pServer?.isRunning == true) return;

    _p2pServer = LocalP2pServer(
      playersProvider: () async {
        final players = await (database.select(database.players)
              ..where((row) => row.isArchived.equals(false)))
            .get();
        final teams = await database.select(database.teams).get();

        return {
          'teams': teams
              .map((t) => {
                    'id': t.id,
                    'name': t.name,
                    'category': t.category,
                  })
              .toList(growable: false),
          'players': players
              .map((p) => {
                    'id': p.id,
                    'name': p.name,
                    'teamId': p.teamId,
                    'jerseyNumber': p.jerseyNumber,
                    'position': p.position,
                  })
              .toList(growable: false),
        };
      },
      dispatchHandler: (rawPayload) async {
        final result = await importSessionFromQr(rawPayload);
        return {
          'status': result.status.name,
          'message': result.message,
          'sessionUuid': result.sessionUuid,
        };
      },
    );

    await _p2pServer!.start(port: port);
  }

  @override
  Future<void> stopP2pServer() async {
    await _p2pServer?.stop();
    _p2pServer = null;
  }

  @override
  Future<SyncResult> syncWithP2pMaster(String host, {int port = 8089}) async {
    try {
      final isAlive = await _p2pClient.ping(host, port: port);
      if (!isAlive) {
        return const SyncResult(
          status: SyncStatus.error,
          sessionUuid: '',
          message: 'تعذر الاتصال بجهاز الإدارة عبر الشبكة المحلية.',
        );
      }
      return const SyncResult(
        status: SyncStatus.success,
        sessionUuid: '',
        message: 'تم الاتصال بجهاز الإدارة بنجاح.',
      );
    } catch (e) {
      return SyncResult(
        status: SyncStatus.error,
        sessionUuid: '',
        message: 'خطأ أثناء الاتصال: $e',
      );
    }
  }

  Future<void> _logSync({
    required String sessionUuid,
    required String channel,
    required String sourceDevice,
    required String targetDevice,
    required String status,
  }) async {
    await database.into(database.syncAuditLogs).insert(
          SyncAuditLogsCompanion.insert(
            id: 'sync-${DateTime.now().microsecondsSinceEpoch}',
            sessionUuid: sessionUuid,
            syncDirection: 'field_to_master',
            syncChannel: channel,
            sourceDeviceId: sourceDevice,
            targetDeviceId: targetDevice,
            syncedAt: DateTime.now().toUtc(),
            status: status,
          ),
        );
  }

  Future<String> _getPairingSecret() async {
    final explicitSecret = explicitPairingSecret;
    if (explicitSecret != null) return explicitSecret;
    final stored = await database.select(database.licenseSecurityStore).getSingleOrNull();
    if (stored != null) {
      try {
        final envelope = _parser.parse(stored.licenseKey);
        final secret = envelope.payload['local_pairing_secret'] as String?;
        if (secret != null && secret.isNotEmpty) return secret;
      } catch (_) {}
    }
    return _defaultSecret;
  }

  Future<String> _getCurrentDeviceId() async {
    final stored = await database.select(database.licenseSecurityStore).getSingleOrNull();
    return stored?.deviceId ?? 'TD-FLD1-3302';
  }
}
