import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:tadamon_attendance_app/core/security/canonical_json.dart';
import 'package:tadamon_attendance_app/core/security/license_parser.dart';

const embeddedEd25519PublicKey = String.fromEnvironment(
  'MONAZ_ED25519_PUBLIC_KEY',
);

final class Ed25519Verifier {
  Ed25519Verifier({
    String publicKey = embeddedEd25519PublicKey,
    this.parser = const LicenseParser(),
  }) : _publicKey = _decodePublicKey(publicKey);

  final SimplePublicKey _publicKey;
  final LicenseParser parser;
  final Ed25519 _algorithm = Ed25519();

  Future<bool> verify(String activationCode) async {
    final envelope = parser.parse(activationCode);
    return _algorithm.verify(
      utf8.encode(encodeCanonicalJson(envelope.payload)),
      signature: Signature(envelope.signature, publicKey: _publicKey),
    );
  }

  static SimplePublicKey _decodePublicKey(String encodedKey) {
    final keyBytes = base64Decode(encodedKey);
    if (keyBytes.length != 32) {
      throw const FormatException('المفتاح العام المدمج غير صالح.');
    }
    return SimplePublicKey(keyBytes, type: KeyPairType.ed25519);
  }
}
