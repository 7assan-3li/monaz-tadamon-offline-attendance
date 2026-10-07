import 'dart:convert';

final class LicenseEnvelope {
  const LicenseEnvelope({required this.payload, required this.signature});

  final Map<String, Object?> payload;
  final List<int> signature;
}

final class LicenseParser {
  const LicenseParser();

  LicenseEnvelope parse(String activationCode) {
    try {
      final envelopeValue = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(activationCode))),
      );
      if (envelopeValue is! Map<String, Object?>) {
        throw const FormatException('صيغة كود التفعيل غير صالحة.');
      }

      final payloadValue = envelopeValue['payload'];
      final signatureValue = envelopeValue['signature'];
      if (payloadValue is! Map<String, Object?> || signatureValue is! String) {
        throw const FormatException('بيانات كود التفعيل ناقصة.');
      }

      final signature = base64Decode(signatureValue);
      if (signature.length != 64) {
        throw const FormatException('توقيع كود التفعيل غير صالح.');
      }

      return LicenseEnvelope(payload: payloadValue, signature: signature);
    } catch (_) {
      throw const FormatException('تعذر قراءة كود التفعيل.');
    }
  }
}
