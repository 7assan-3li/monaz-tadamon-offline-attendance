import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/features/activation/data/repositories/activation_repository_impl.dart';
import 'package:tadamon_attendance_app/features/activation/domain/entities/activated_license.dart';
import 'package:tadamon_attendance_app/features/activation/domain/repositories/activation_repository.dart';
import 'package:tadamon_attendance_app/features/activation/domain/usecases/activate_device_use_case.dart';
import 'package:tadamon_attendance_app/features/activation/presentation/bloc/activation_bloc.dart';
import 'package:tadamon_attendance_app/features/activation/presentation/bloc/activation_event.dart';
import 'package:tadamon_attendance_app/features/activation/presentation/bloc/activation_state.dart';

void main() {
  final license = ActivatedLicense(
    deviceId: 'TD-MST1-8419',
    role: ActivatedDeviceRole.masterAdmin,
    clubName: 'نادي تضامن حضرموت الرياضي',
    teamName: 'الفريق الأول',
    expiresAt: DateTime.utc(2027, 6, 30),
  );

  blocTest<ActivationBloc, ActivationState>(
    'emits progress then success for a valid activation code',
    build: () => ActivationBloc(
      activateDevice: ActivateDeviceUseCase(_FakeActivationRepository(license)),
      currentDeviceId: 'TD-MST1-8419',
    ),
    act: (bloc) =>
        bloc.add(const ActivationSubmitted(activationCode: 'valid-code')),
    expect: () => [
      isA<ActivationInProgress>(),
      isA<ActivationSucceeded>().having(
        (state) => state.license,
        'license',
        license,
      ),
    ],
  );

  blocTest<ActivationBloc, ActivationState>(
    'shows a direct Arabic message when the code belongs to another device',
    build: () => ActivationBloc(
      activateDevice: ActivateDeviceUseCase(
        _FakeActivationRepository(
          license,
          error: const ActivationException('كود التفعيل صادر لجهاز آخر.'),
        ),
      ),
      currentDeviceId: 'TD-MST1-8419',
    ),
    act: (bloc) =>
        bloc.add(const ActivationSubmitted(activationCode: 'wrong-code')),
    expect: () => [
      isA<ActivationInProgress>(),
      isA<ActivationFailed>().having(
        (state) => state.message,
        'message',
        'كود التفعيل صادر لجهاز آخر.',
      ),
    ],
  );
}

final class _FakeActivationRepository implements ActivationRepository {
  _FakeActivationRepository(this.license, {this.error});

  final ActivatedLicense license;
  final Object? error;

  @override
  Future<ActivatedLicense> activate({
    required String activationCode,
    required String currentDeviceId,
  }) async {
    if (error case final Object error) throw error;
    return license;
  }

  @override
  Future<ActivatedLicense?> readActivatedLicense() async => null;
}
