import 'package:tadamon_attendance_app/features/activation/domain/entities/activated_license.dart';
import 'package:tadamon_attendance_app/features/activation/domain/repositories/activation_repository.dart';

final class ActivateDeviceUseCase {
  const ActivateDeviceUseCase(this._repository);

  final ActivationRepository _repository;

  Future<ActivatedLicense> call({
    required String activationCode,
    required String currentDeviceId,
  }) => _repository.activate(
    activationCode: activationCode,
    currentDeviceId: currentDeviceId,
  );
}
