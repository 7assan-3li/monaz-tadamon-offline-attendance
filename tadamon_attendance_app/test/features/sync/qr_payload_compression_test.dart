import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/sync/data/datasources/qr_codec.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/dispatch_payload.dart';

void main() {
  const codec = QrCodec();
  const pairingSecret = 'tadamon-secure-pairing-secret-key-32b';

  group('QrCodec Compression & HMAC Tests (Stage 5)', () {
    test('payload with 10 absentees is strictly under 300 bytes', () async {
      final absentees = List.generate(
        10,
        (i) => AbsenteePayloadItem(
          playerId: 'p$i',
          status: i.isEven
              ? PlayerAttendanceStatus.excused
              : PlayerAttendanceStatus.unexcused,
        ),
      );

      final payload = DispatchPayload(
        sessionUuid: 'session-first-20261008',
        teamId: 'team-first',
        sessionDate: DateTime.parse('2026-10-08T15:00:00Z'),
        sourceDeviceId: 'TD-FLD1-3302',
        absentees: absentees,
        signature: '',
      );

      final encoded = await codec.encode(
        payload: payload,
        pairingSecret: pairingSecret,
      );

      final byteLength = utf8.encode(encoded).length;
      expect(
        byteLength,
        lessThan(300),
        reason: 'حجم الحزمة يجب ألا يتجاوز 300 بايت لضمان سرعة مسح الـ QR في الملعب',
      );
    });

    test('validates authentic HMAC-SHA256 signature and decodes fields accurately', () async {
      final absentees = [
        const AbsenteePayloadItem(
          playerId: 'player-10',
          status: PlayerAttendanceStatus.excused,
        ),
        const AbsenteePayloadItem(
          playerId: 'player-22',
          status: PlayerAttendanceStatus.unexcused,
        ),
      ];

      final payload = DispatchPayload(
        sessionUuid: 'session-20261008-01',
        teamId: 'team-first',
        sessionDate: DateTime.parse('2026-10-08T18:00:00Z'),
        sourceDeviceId: 'TD-FLD1-3302',
        absentees: absentees,
        signature: '',
      );

      final encoded = await codec.encode(
        payload: payload,
        pairingSecret: pairingSecret,
      );

      final decoded = await codec.decode(
        rawData: encoded,
        pairingSecret: pairingSecret,
      );

      expect(decoded.sessionUuid, equals('session-20261008-01'));
      expect(decoded.teamId, equals('team-first'));
      expect(decoded.sourceDeviceId, equals('TD-FLD1-3302'));
      expect(decoded.absentees.length, equals(2));
      expect(decoded.absentees[0].playerId, equals('player-10'));
      expect(decoded.absentees[0].status, equals(PlayerAttendanceStatus.excused));
      expect(decoded.absentees[1].playerId, equals('player-22'));
      expect(decoded.absentees[1].status, equals(PlayerAttendanceStatus.unexcused));
    });

    test('rejects tampered payload content or incorrect pairing secret', () async {
      final payload = DispatchPayload(
        sessionUuid: 'session-valid',
        teamId: 'team-first',
        sessionDate: DateTime.parse('2026-10-08T12:00:00Z'),
        sourceDeviceId: 'TD-FLD1-3302',
        absentees: const [
          AbsenteePayloadItem(
            playerId: 'player-1',
            status: PlayerAttendanceStatus.unexcused,
          ),
        ],
        signature: '',
      );

      final encoded = await codec.encode(
        payload: payload,
        pairingSecret: pairingSecret,
      );

      // Wrong secret
      expect(
        () => codec.decode(
          rawData: encoded,
          pairingSecret: 'wrong-pairing-secret-key-32b',
        ),
        throwsA(isA<TamperedPayloadException>()),
      );

      // Tampered JSON payload content
      final jsonMap = jsonDecode(encoded) as Map<String, dynamic>;
      final payloadMap = jsonMap['p'] as Map<String, dynamic>;
      payloadMap['u'] = 'session-tampered';
      final tamperedString = jsonEncode(jsonMap);

      expect(
        () => codec.decode(
          rawData: tamperedString,
          pairingSecret: pairingSecret,
        ),
        throwsA(isA<TamperedPayloadException>()),
      );
    });
  });
}
