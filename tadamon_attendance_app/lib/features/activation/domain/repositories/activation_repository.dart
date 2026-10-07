import 'package:tadamon_attendance_app/features/activation/domain/entities/activated_license.dart';

abstract interface class ActivationRepository {
  Future<ActivatedLicense> activate({
    required String activationCode,
    required String currentDeviceId,
  });

  Future<ActivatedLicense?> readActivatedLicense();
}
