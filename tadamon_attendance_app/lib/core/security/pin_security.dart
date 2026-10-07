import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

class PinSecurity {
  PinSecurity({Pbkdf2? algorithm})
    : _algorithm =
          algorithm ??
          Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: 210000, bits: 256);

  final Pbkdf2 _algorithm;

  Future<String> hash(String pin) async {
    _validate(pin);
    final salt = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    final bytes = await _derive(pin, salt);
    return '${base64UrlEncode(salt)}:${base64UrlEncode(bytes)}';
  }

  Future<bool> verify(String pin, String encodedHash) async {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) return false;
    final parts = encodedHash.split(':');
    if (parts.length != 2) return false;
    try {
      final expected = base64Url.decode(parts[1]);
      final actual = await _derive(pin, base64Url.decode(parts[0]));
      if (actual.length != expected.length) return false;
      var difference = 0;
      for (var index = 0; index < actual.length; index++) {
        difference |= actual[index] ^ expected[index];
      }
      return difference == 0;
    } on FormatException {
      return false;
    }
  }

  Future<List<int>> _derive(String pin, List<int> salt) async {
    final key = await _algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(pin)),
      nonce: salt,
    );
    return key.extractBytes();
  }

  void _validate(String pin) {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      throw const FormatException('رمز الحماية يجب أن يتكوّن من 4 أرقام.');
    }
  }
}
