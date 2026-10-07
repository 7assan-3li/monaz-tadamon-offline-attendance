import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/security/canonical_json.dart';
import 'package:tadamon_attendance_app/core/security/ed25519_verifier.dart';

void main() {
  test(
    'accepts a valid activation code and rejects one changed value',
    () async {
      final algorithm = Ed25519();
      final keyPair = await algorithm.newKeyPair();
      final publicKey = await keyPair.extractPublicKey();
      final payload = <String, Object?>{
        'role': 'MASTER_ADMIN',
        'device_id': 'TD-MST1-8419',
        'club_name': 'نادي تضامن حضرموت الرياضي',
      };

      Future<String> activationCode(Map<String, Object?> value) async {
        final signature = await algorithm.sign(
          utf8.encode(encodeCanonicalJson(value)),
          keyPair: keyPair,
        );
        return base64UrlEncode(
          utf8.encode(
            jsonEncode({
              'payload': value,
              'signature': base64Encode(signature.bytes),
            }),
          ),
        ).replaceAll('=', '');
      }

      final verifier = Ed25519Verifier(
        publicKey: base64Encode(publicKey.bytes),
      );
      final validCode = await activationCode(payload);
      expect(await verifier.verify(validCode), isTrue);

      final decodedEnvelope = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(validCode))),
      ) as Map<String, Object?>;
      final tamperedPayload = Map<String, Object?>.from(
        decodedEnvelope['payload']! as Map<String, Object?>,
      )..['role'] = 'FIELD_ATTENDANCE';
      final tamperedCode = base64UrlEncode(
        utf8.encode(
          jsonEncode({
            'payload': tamperedPayload,
            'signature': decodedEnvelope['signature'],
          }),
        ),
      ).replaceAll('=', '');

      expect(await verifier.verify(tamperedCode), isFalse);
    },
  );
}
