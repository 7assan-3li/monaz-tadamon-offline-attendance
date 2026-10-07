import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/security/canonical_json.dart';
import 'package:tadamon_attendance_app/core/security/ed25519_verifier.dart';
import 'package:tadamon_attendance_app/core/security/license_parser.dart';
import 'package:tadamon_attendance_app/features/activation/data/datasources/license_local_data_source.dart';
import 'package:tadamon_attendance_app/features/activation/data/repositories/activation_repository_impl.dart';
import 'package:tadamon_attendance_app/features/activation/domain/entities/activated_license.dart';

void main() {
  late AppDatabase database;
  late _MemorySecureValueStore secureStore;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    secureStore = _MemorySecureValueStore();
  });

  tearDown(() => database.close());

  test('verifies, binds, and stores an offline activation license', () async {
    final algorithm = Ed25519();
    final keyPair = await algorithm.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final code = await _activationCode(algorithm, keyPair);
    final dataSource = LicenseLocalDataSource(
      database: database,
      secureStore: secureStore,
    );
    final repository = ActivationRepositoryImpl(
      verifier: Ed25519Verifier(publicKey: base64Encode(publicKey.bytes)),
      parser: const LicenseParser(),
      localDataSource: dataSource,
      currentTime: () => DateTime.utc(2026, 10, 7, 12),
    );

    final license = await repository.activate(
      activationCode: code,
      currentDeviceId: 'TD-MST1-8419',
    );

    expect(license.role, ActivatedDeviceRole.masterAdmin);
    expect((await dataSource.readLicense())?.deviceId, 'TD-MST1-8419');
    expect(
      await dataSource.readSecureWatermark(),
      DateTime.utc(2026, 10, 7, 12),
    );

    await expectLater(
      repository.activate(
        activationCode: code,
        currentDeviceId: 'TD-DIFF-0001',
      ),
      throwsA(
        isA<ActivationException>().having(
          (error) => error.message,
          'message',
          'كود التفعيل صادر لجهاز آخر.',
        ),
      ),
    );
  });
}

Future<String> _activationCode(Ed25519 algorithm, KeyPair keyPair) async {
  final payload = <String, Object?>{
    'activated_at': '2026-10-07T00:00:00Z',
    'club_name': 'نادي تضامن حضرموت الرياضي',
    'device_id': 'TD-MST1-8419',
    'expires_at': '2027-06-30T23:59:59Z',
    'local_pairing_secret': 'pairing-secret',
    'package_type': 'SEASON',
    'paired_device_id': 'TD-FLD1-3302',
    'role': 'MASTER_ADMIN',
    'team_name': 'الفريق الأول',
  };
  final signature = await algorithm.sign(
    utf8.encode(encodeCanonicalJson(payload)),
    keyPair: keyPair,
  );
  return base64UrlEncode(
    utf8.encode(
      jsonEncode({
        'payload': payload,
        'signature': base64Encode(signature.bytes),
      }),
    ),
  ).replaceAll('=', '');
}

final class _MemorySecureValueStore implements SecureValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
