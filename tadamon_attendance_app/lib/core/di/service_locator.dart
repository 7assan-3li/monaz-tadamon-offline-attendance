import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/security/ed25519_verifier.dart';
import 'package:tadamon_attendance_app/core/security/high_watermark_guard.dart';
import 'package:tadamon_attendance_app/core/security/license_parser.dart';
import 'package:tadamon_attendance_app/features/activation/data/datasources/license_local_data_source.dart';
import 'package:tadamon_attendance_app/features/activation/data/repositories/activation_repository_impl.dart';
import 'package:tadamon_attendance_app/features/activation/domain/repositories/activation_repository.dart';
import 'package:tadamon_attendance_app/features/activation/domain/usecases/activate_device_use_case.dart';
import 'package:tadamon_attendance_app/features/activation/presentation/bloc/activation_bloc.dart';
import 'package:tadamon_attendance_app/core/routing/device_role_guard.dart';
import 'package:tadamon_attendance_app/features/players/data/datasources/players_dao.dart';
import 'package:tadamon_attendance_app/features/players/data/repositories/players_repository_impl.dart';
import 'package:tadamon_attendance_app/features/players/domain/repositories/players_repository.dart';
import 'package:tadamon_attendance_app/features/players/domain/usecases/add_player_use_case.dart';
import 'package:tadamon_attendance_app/features/players/domain/usecases/archive_player_use_case.dart';
import 'package:tadamon_attendance_app/features/players/domain/usecases/get_players_use_case.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_bloc.dart';
import 'package:tadamon_attendance_app/core/security/pin_security.dart';
import 'package:tadamon_attendance_app/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:tadamon_attendance_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:tadamon_attendance_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:tadamon_attendance_app/features/teams/data/repositories/teams_repository_impl.dart';
import 'package:tadamon_attendance_app/features/teams/domain/repositories/teams_repository.dart';
import 'package:tadamon_attendance_app/features/teams/presentation/bloc/teams_bloc.dart';
import 'package:tadamon_attendance_app/features/attendance/data/datasources/attendance_dao.dart';
import 'package:tadamon_attendance_app/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/usecases/attendance_use_cases.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:tadamon_attendance_app/features/sync/data/datasources/qr_codec.dart';
import 'package:tadamon_attendance_app/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:tadamon_attendance_app/features/sync/domain/repositories/sync_repository.dart';
import 'package:tadamon_attendance_app/features/sync/domain/usecases/generate_qr_payload_usecase.dart';
import 'package:tadamon_attendance_app/features/sync/domain/usecases/import_qr_payload_usecase.dart';
import 'package:tadamon_attendance_app/features/sync/domain/usecases/start_local_sync_server_usecase.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_bloc.dart';

final GetIt serviceLocator = GetIt.instance;

void configureCoreDependencies({AppDatabase? database}) {
  if (serviceLocator.isRegistered<AppDatabase>()) {
    return;
  }

  serviceLocator.registerLazySingleton<AppDatabase>(
    () => database ?? AppDatabase(),
    dispose: (database) => database.close(),
  );
}

Future<void> seedDefaultRosterIfEmpty(AppDatabase database) async {
  final now = DateTime.now().toUtc();
  await database
      .into(database.teams)
      .insertOnConflictUpdate(
        TeamsCompanion.insert(
          id: 'team-first',
          name: 'الفريق الأول',
          category: 'الفريق الأول',
          createdAt: now,
          updatedAt: now,
        ),
      );

  final existingPlayers = await (database.select(database.players)
        ..where((tbl) => tbl.teamId.equals('team-first')))
      .get();
  if (existingPlayers.isEmpty) {
    const seedPlayers = [
      ('player-1', 'محمد باعباد', 1, 'حارس مرمى'),
      ('player-2', 'علي بن الشيخ أبوبكر', 7, 'وسط'),
      ('player-3', 'سالم بلعلا', 10, 'صانع ألعاب'),
      ('player-4', 'أحمد باحاج', 4, 'مدافع'),
      ('player-5', 'عمر باوزير', 8, 'مدافع'),
      ('player-6', 'عبدالله الكثيري', 9, 'مهاجم'),
    ];
    for (final p in seedPlayers) {
      await database.into(database.players).insertOnConflictUpdate(
        PlayersCompanion.insert(
          id: p.$1,
          name: p.$2,
          teamId: 'team-first',
          jerseyNumber: Value(p.$3),
          position: Value(p.$4),
          joinDate: now,
          updatedAt: now,
        ),
      );
    }
  }
}

Future<void> initializeCoreDependencies({AppDatabase? database}) async {
  configureCoreDependencies(database: database);
  await serviceLocator<AppDatabase>().customSelect('SELECT 1').get();
  await seedDefaultRosterIfEmpty(serviceLocator<AppDatabase>());
}

void configureActivationDependencies({
  required String currentDeviceId,
  SecureValueStore? secureStore,
}) {
  if (serviceLocator.isRegistered<ActivationRepository>()) return;

  serviceLocator
    ..registerLazySingleton<LicenseParser>(LicenseParser.new)
    ..registerLazySingleton<Ed25519Verifier>(Ed25519Verifier.new)
    ..registerLazySingleton<SecureValueStore>(
      () => secureStore ?? FlutterSecureValueStore(),
    )
    ..registerLazySingleton<LicenseLocalDataSource>(
      () => LicenseLocalDataSource(
        database: serviceLocator<AppDatabase>(),
        secureStore: serviceLocator<SecureValueStore>(),
      ),
    )
    ..registerLazySingleton<ActivationRepository>(
      () => ActivationRepositoryImpl(
        verifier: serviceLocator<Ed25519Verifier>(),
        parser: serviceLocator<LicenseParser>(),
        localDataSource: serviceLocator<LicenseLocalDataSource>(),
      ),
    )
    ..registerLazySingleton<ActivateDeviceUseCase>(
      () => ActivateDeviceUseCase(serviceLocator<ActivationRepository>()),
    )
    ..registerLazySingleton<HighWatermarkGuard>(
      () => HighWatermarkGuard(store: serviceLocator<LicenseLocalDataSource>()),
    )
    ..registerFactory<ActivationBloc>(
      () => ActivationBloc(
        activateDevice: serviceLocator<ActivateDeviceUseCase>(),
        currentDeviceId: currentDeviceId,
      ),
    );
}

void configureAttendanceDependencies() {
  if (serviceLocator.isRegistered<AttendanceRepository>()) return;
  serviceLocator
    ..registerLazySingleton<AttendanceWriteGuard>(
      () => _HighWatermarkAttendanceWriteGuard(
        serviceLocator<HighWatermarkGuard>(),
      ),
    )
    ..registerLazySingleton<AttendanceDao>(
      () => AttendanceDao(
        serviceLocator<AppDatabase>(),
        serviceLocator<AttendanceWriteGuard>(),
      ),
    )
    ..registerLazySingleton<AttendanceRepository>(
      () => AttendanceRepositoryImpl(serviceLocator<AttendanceDao>()),
    )
    ..registerLazySingleton<StartTodaySessionUseCase>(
      () => StartTodaySessionUseCase(serviceLocator<AttendanceRepository>()),
    )
    ..registerLazySingleton<MarkAllPresentUseCase>(
      () => MarkAllPresentUseCase(serviceLocator<AttendanceRepository>()),
    )
    ..registerLazySingleton<UpdatePlayerStatusUseCase>(
      () => UpdatePlayerStatusUseCase(serviceLocator<AttendanceRepository>()),
    )
    ..registerLazySingleton<DispatchSessionUseCase>(
      () => DispatchSessionUseCase(serviceLocator<AttendanceRepository>()),
    )
    ..registerFactory<AttendanceBloc>(
      () => AttendanceBloc(
        serviceLocator<StartTodaySessionUseCase>(),
        serviceLocator<MarkAllPresentUseCase>(),
        serviceLocator<UpdatePlayerStatusUseCase>(),
        serviceLocator<DispatchSessionUseCase>(),
      ),
    );
}

void configureSyncDependencies({String? explicitPairingSecret}) {
  if (serviceLocator.isRegistered<SyncRepository>()) return;
  serviceLocator
    ..registerLazySingleton<QrCodec>(QrCodec.new)
    ..registerLazySingleton<SyncRepository>(
      () => SyncRepositoryImpl(
        database: serviceLocator<AppDatabase>(),
        codec: serviceLocator<QrCodec>(),
        parser: serviceLocator<LicenseParser>(),
        explicitPairingSecret: explicitPairingSecret,
      ),
    )
    ..registerLazySingleton<GenerateQrPayloadUseCase>(
      () => GenerateQrPayloadUseCase(serviceLocator<SyncRepository>()),
    )
    ..registerLazySingleton<ImportQrPayloadUseCase>(
      () => ImportQrPayloadUseCase(serviceLocator<SyncRepository>()),
    )
    ..registerLazySingleton<StartLocalSyncServerUseCase>(
      () => StartLocalSyncServerUseCase(serviceLocator<SyncRepository>()),
    )
    ..registerFactory<SyncBloc>(
      () => SyncBloc(
        generateQrPayload: serviceLocator<GenerateQrPayloadUseCase>(),
        importQrPayload: serviceLocator<ImportQrPayloadUseCase>(),
        startLocalSyncServer: serviceLocator<StartLocalSyncServerUseCase>(),
      ),
    );
}

class _HighWatermarkAttendanceWriteGuard implements AttendanceWriteGuard {
  const _HighWatermarkAttendanceWriteGuard(this._guard);
  final HighWatermarkGuard _guard;
  @override
  Future<void> verify() async {
    await _guard.verifyAndAdvance();
  }
}

Future<void> configureMasterDependencies() async {
  if (serviceLocator.isRegistered<PlayersRepository>()) return;
  final database = serviceLocator<AppDatabase>();
  await seedDefaultRosterIfEmpty(database);
  serviceLocator
    ..registerLazySingleton<PinSecurity>(PinSecurity.new)
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(database, serviceLocator<PinSecurity>()),
    )
    ..registerFactory<SettingsBloc>(
      () => SettingsBloc(serviceLocator<SettingsRepository>()),
    )
    ..registerLazySingleton<TeamsRepository>(
      () => TeamsRepositoryImpl(database),
    )
    ..registerFactory<TeamsBloc>(
      () => TeamsBloc(serviceLocator<TeamsRepository>()),
    )
    ..registerLazySingleton<PlayersDao>(() => PlayersDao(database))
    ..registerLazySingleton<PlayersRepository>(
      () => PlayersRepositoryImpl(
        serviceLocator<PlayersDao>(),
        DeviceRole.masterAdmin,
      ),
    )
    ..registerLazySingleton<GetPlayersUseCase>(
      () => GetPlayersUseCase(serviceLocator<PlayersRepository>()),
    )
    ..registerLazySingleton<AddPlayerUseCase>(
      () => AddPlayerUseCase(serviceLocator<PlayersRepository>()),
    )
    ..registerLazySingleton<ArchivePlayerUseCase>(
      () => ArchivePlayerUseCase(serviceLocator<PlayersRepository>()),
    )
    ..registerFactory<PlayersBloc>(
      () => PlayersBloc(
        serviceLocator<GetPlayersUseCase>(),
        serviceLocator<AddPlayerUseCase>(),
        serviceLocator<ArchivePlayerUseCase>(),
        serviceLocator<PlayersRepository>(),
      ),
    );
}

Future<void> resetCoreDependencies() async {
  await serviceLocator.reset();
}
