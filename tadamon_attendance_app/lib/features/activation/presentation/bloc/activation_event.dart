sealed class ActivationEvent {
  const ActivationEvent();
}

final class ActivationSubmitted extends ActivationEvent {
  const ActivationSubmitted({required this.activationCode});

  final String activationCode;
}
