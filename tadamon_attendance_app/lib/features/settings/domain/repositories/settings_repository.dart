import 'package:tadamon_attendance_app/features/settings/domain/entities/club_profile_settings.dart';

abstract interface class SettingsRepository {
  Future<ClubProfileSettings> read();
  Future<void> save(ClubProfileSettings settings);
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
}
