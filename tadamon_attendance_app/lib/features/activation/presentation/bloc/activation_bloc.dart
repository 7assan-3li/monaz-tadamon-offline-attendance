import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadamon_attendance_app/features/activation/data/repositories/activation_repository_impl.dart';
import 'package:tadamon_attendance_app/features/activation/domain/usecases/activate_device_use_case.dart';
import 'package:tadamon_attendance_app/features/activation/presentation/bloc/activation_event.dart';
import 'package:tadamon_attendance_app/features/activation/presentation/bloc/activation_state.dart';

final class ActivationBloc extends Bloc<ActivationEvent, ActivationState> {
  ActivationBloc({required this.activateDevice, required this.currentDeviceId})
    : super(const ActivationIdle()) {
    on<ActivationSubmitted>(_onSubmitted);
  }

  final ActivateDeviceUseCase activateDevice;
  final String currentDeviceId;

  Future<void> _onSubmitted(
    ActivationSubmitted event,
    Emitter<ActivationState> emit,
  ) async {
    final activationCode = event.activationCode.trim();
    if (activationCode.isEmpty) {
      emit(const ActivationFailed('أدخل كود التفعيل أولاً.'));
      return;
    }

    emit(const ActivationInProgress());
    try {
      final license = await activateDevice(
        activationCode: activationCode,
        currentDeviceId: currentDeviceId,
      );
      emit(ActivationSucceeded(license));
    } on ActivationException catch (error) {
      emit(ActivationFailed(error.message));
    } on FormatException catch (error) {
      emit(ActivationFailed(error.message));
    } catch (_) {
      emit(
        const ActivationFailed('تعذر تفعيل النظام. راجع الكود وحاول مرة أخرى.'),
      );
    }
  }
}
