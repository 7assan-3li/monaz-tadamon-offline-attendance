import 'package:tadamon_attendance_app/features/activation/domain/entities/activated_license.dart';

sealed class ActivationState {
  const ActivationState();
}

final class ActivationIdle extends ActivationState {
  const ActivationIdle();
}

final class ActivationInProgress extends ActivationState {
  const ActivationInProgress();
}

final class ActivationSucceeded extends ActivationState {
  const ActivationSucceeded(this.license);

  final ActivatedLicense license;
}

final class ActivationFailed extends ActivationState {
  const ActivationFailed(this.message);

  final String message;
}
