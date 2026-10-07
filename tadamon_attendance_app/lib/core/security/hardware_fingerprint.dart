import 'dart:convert';

import 'package:cryptography/cryptography.dart';

const embeddedHardwareFingerprintSalt = String.fromEnvironment(
  'MONAZ_HARDWARE_FINGERPRINT_SALT',
);

final class HardwareFingerprintComponents {
  const HardwareFingerprintComponents({
    required this.processorId,
    required this.motherboardId,
    required this.storageSerial,
    required this.networkAdapterId,
  });

  final String processorId;
  final String motherboardId;
  final String storageSerial;
  final String networkAdapterId;

  List<String> get values => [
    processorId,
    motherboardId,
    storageSerial,
    networkAdapterId,
  ];
}

final class CompositeHardwareFingerprint {
  CompositeHardwareFingerprint({String salt = embeddedHardwareFingerprintSalt})
    : _salt = utf8.encode(salt) {
    if (_salt.isEmpty) {
      throw const FormatException('مفتاح اشتقاق بصمة الجهاز غير مضبوط.');
    }
  }

  final List<int> _salt;
  final Hmac _hmac = Hmac.sha256();

  Future<String> derive(HardwareFingerprintComponents components) async {
    if (components.values.any((value) => value.trim().isEmpty)) {
      throw const FormatException('مكونات بصمة الجهاز غير مكتملة.');
    }

    final canonicalComponents = components.values
        .map((value) => value.trim().toUpperCase())
        .map((value) => '${value.length}:$value')
        .join('|');
    final mac = await _hmac.calculateMac(
      utf8.encode(canonicalComponents),
      secretKey: SecretKey(_salt),
    );
    final identifier = mac.bytes
        .take(4)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();

    return 'TD-${identifier.substring(0, 4)}-${identifier.substring(4)}';
  }
}
