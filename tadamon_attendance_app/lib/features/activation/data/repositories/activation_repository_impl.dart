import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/security/ed25519_verifier.dart';
import 'package:tadamon_attendance_app/core/security/license_parser.dart';
import 'package:tadamon_attendance_app/features/activation/data/datasources/license_local_data_source.dart';
import 'package:tadamon_attendance_app/features/activation/domain/entities/activated_license.dart';
import 'package:tadamon_attendance_app/features/activation/domain/repositories/activation_repository.dart';

final class ActivationException implements Exception {
  const ActivationException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class ActivationRepositoryImpl implements ActivationRepository {
  ActivationRepositoryImpl({
    required this.verifier,
    required this.parser,
    required this.localDataSource,
    DateTime Function()? currentTime,
  }) : _currentTime = currentTime ?? DateTime.now;

  final Ed25519Verifier verifier;
  final LicenseParser parser;
  final LicenseLocalDataSource localDataSource;
  final DateTime Function() _currentTime;

  @override
  Future<ActivatedLicense> activate({
    required String activationCode,
    required String currentDeviceId,
  }) async {
    if (!await verifier.verify(activationCode)) {
      throw const ActivationException(
        'كود التفعيل غير معتمد. راجع الكود وحاول مرة أخرى.',
      );
    }

    final envelope = parser.parse(activationCode);
    final payload = envelope.payload;
    final deviceId = _requiredString(payload, 'device_id');
    if (deviceId != currentDeviceId) {
      throw const ActivationException('كود التفعيل صادر لجهاز آخر.');
    }

    final activatedAt = DateTime.parse(_requiredString(payload, 'activated_at'))
        .toUtc();
    final expiresAt = DateTime.parse(_requiredString(payload, 'expires_at'))
        .toUtc();
    final now = _currentTime().toUtc();
    if (now.isBefore(activatedAt) || now.isAfter(expiresAt)) {
      throw const ActivationException(
        'صلاحية الباقة غير سارية في تاريخ الجهاز الحالي.',
      );
    }

    final role = _parseRole(_requiredString(payload, 'role'));
    final license = ActivatedLicense(
      deviceId: deviceId,
      role: role,
      clubName: _requiredString(payload, 'club_name'),
      teamName: payload['team_name'] as String?,
      expiresAt: expiresAt,
    );

    await localDataSource.saveLicense(
      LicenseSecurityStoreCompanion.insert(
        deviceId: deviceId,
        deviceMode: _databaseRole(role),
        pairedDeviceId: Value(_requiredString(payload, 'paired_device_id')),
        licenseKey: activationCode,
        clubName: license.clubName,
        teamName: Value(license.teamName),
        packageType: _requiredString(payload, 'package_type'),
        activatedAt: activatedAt,
        expiresAt: expiresAt,
        highWatermarkTimestamp: now,
        signatureProof: base64Encode(envelope.signature),
      ),
    );

    return license;
  }

  @override
  Future<ActivatedLicense?> readActivatedLicense() async {
    final stored = await localDataSource.readLicense();
    if (stored == null) return null;
    return ActivatedLicense(
      deviceId: stored.deviceId,
      role: _parseRole(stored.deviceMode.toUpperCase()),
      clubName: stored.clubName,
      teamName: stored.teamName,
      expiresAt: stored.expiresAt,
    );
  }

  String _requiredString(Map<String, Object?> payload, String key) {
    final value = payload[key];
    if (value is! String || value.isEmpty) {
      throw const ActivationException('بيانات كود التفعيل ناقصة أو غير صالحة.');
    }
    return value;
  }

  ActivatedDeviceRole _parseRole(String role) => switch (role) {
    'MASTER_ADMIN' => ActivatedDeviceRole.masterAdmin,
    'FIELD_ATTENDANCE' => ActivatedDeviceRole.fieldAttendance,
    _ => throw const ActivationException(
      'نوع الجهاز في كود التفعيل غير معتمد.',
    ),
  };

  String _databaseRole(ActivatedDeviceRole role) => switch (role) {
    ActivatedDeviceRole.masterAdmin => 'master_admin',
    ActivatedDeviceRole.fieldAttendance => 'field_attendance',
  };
}
