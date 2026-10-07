import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadamon_attendance_app/features/settings/domain/entities/club_profile_settings.dart';
import 'package:tadamon_attendance_app/features/settings/domain/repositories/settings_repository.dart';

sealed class SettingsEvent {
  const SettingsEvent();
}

class SettingsRequested extends SettingsEvent {
  const SettingsRequested();
}

class SettingsSaved extends SettingsEvent {
  const SettingsSaved(this.settings);
  final ClubProfileSettings settings;
}

class PinChanged extends SettingsEvent {
  const PinChanged(this.pin);
  final String pin;
}

sealed class SettingsState {
  const SettingsState();
}

class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

class SettingsReady extends SettingsState {
  const SettingsReady(this.settings, {this.message});
  final ClubProfileSettings settings;
  final String? message;
}

class SettingsFailure extends SettingsState {
  const SettingsFailure(this.message);
  final String message;
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(this._repository) : super(const SettingsLoading()) {
    on<SettingsRequested>((event, emit) async => _load(emit));
    on<SettingsSaved>((event, emit) async {
      await _repository.save(event.settings);
      emit(
        SettingsReady(
          await _repository.read(),
          message: 'حُفظت إعدادات النادي.',
        ),
      );
    });
    on<PinChanged>((event, emit) async {
      await _repository.setPin(event.pin);
      emit(
        SettingsReady(await _repository.read(), message: 'حُفظ رمز الحماية.'),
      );
    });
  }
  final SettingsRepository _repository;
  Future<void> _load(Emitter<SettingsState> emit) async {
    try {
      emit(SettingsReady(await _repository.read()));
    } on Object catch (error) {
      emit(SettingsFailure(error.toString()));
    }
  }
}
