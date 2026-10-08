import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:tadamon_attendance_app/core/security/canonical_json.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/dispatch_payload.dart';

final class TamperedPayloadException implements Exception {
  const TamperedPayloadException([this.message = 'تم رصد تلاعب في كود الترحيل أو توقيع غير مطابق.']);
  final String message;
  @override
  String toString() => message;
}

final class QrCodec {
  const QrCodec();

  static final Hmac _hmac = Hmac.sha256();

  Future<String> encode({
    required DispatchPayload payload,
    required String pairingSecret,
  }) async {
    final contentMap = payload.toContentMap();
    final canonicalJson = encodeCanonicalJson(contentMap);
    final secretKey = SecretKey(utf8.encode(pairingSecret));
    final mac = await _hmac.calculateMac(
      utf8.encode(canonicalJson),
      secretKey: secretKey,
    );
    final signature = base64UrlEncode(mac.bytes).replaceAll('=', '');

    final envelope = <String, Object?>{
      'p': contentMap,
      's': signature,
    };

    return jsonEncode(envelope);
  }

  Future<DispatchPayload> decode({
    required String rawData,
    required String pairingSecret,
  }) async {
    try {
      final decodedJson = jsonDecode(rawData.trim());
      if (decodedJson is! Map<String, Object?>) {
        throw const FormatException('بنية كود الترحيل غير صالحة.');
      }

      final payloadMap = decodedJson['p'];
      final signature = decodedJson['s'];
      if (payloadMap is! Map<String, Object?> || signature is! String) {
        throw const FormatException('بيانات كود الترحيل ناقصة.');
      }

      // Verify HMAC signature
      final canonicalJson = encodeCanonicalJson(payloadMap);
      final secretKey = SecretKey(utf8.encode(pairingSecret));
      final computedMac = await _hmac.calculateMac(
        utf8.encode(canonicalJson),
        secretKey: secretKey,
      );
      final expectedSignature = base64UrlEncode(computedMac.bytes).replaceAll('=', '');

      if (!_constantTimeStringEquals(signature, expectedSignature)) {
        throw const TamperedPayloadException();
      }

      final absenteesRaw = payloadMap['a'] as List<Object?>? ?? [];
      final absentees = absenteesRaw
          .map((item) => AbsenteePayloadItem.fromJson(item))
          .toList(growable: false);

      final rawDate = payloadMap['d'];
      final sessionDate = (rawDate is int)
          ? DateTime.fromMillisecondsSinceEpoch(rawDate * 1000, isUtc: true)
          : DateTime.parse(rawDate as String).toUtc();

      return DispatchPayload(
        sessionUuid: payloadMap['u'] as String? ?? '',
        teamId: payloadMap['t'] as String? ?? '',
        sessionDate: sessionDate,
        sourceDeviceId: payloadMap['s'] as String? ?? '',
        absentees: absentees,
        signature: signature,
      );
    } on TamperedPayloadException {
      rethrow;
    } catch (e) {
      throw FormatException('تعذر قراءة كود الترحيل: $e');
    }
  }

  static bool _constantTimeStringEquals(String a, String b) {
    final bytesA = utf8.encode(a);
    final bytesB = utf8.encode(b);
    if (bytesA.length != bytesB.length) return false;
    var result = 0;
    for (var i = 0; i < bytesA.length; i++) {
      result |= bytesA[i] ^ bytesB[i];
    }
    return result == 0;
  }
}
