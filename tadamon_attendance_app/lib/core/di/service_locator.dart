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
import 'package:tadamon_attendance_app/features/teams/presentation/bloc/active_team_cubit.dart';
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
import 'package:tadamon_attendance_app/features/sync/data/datasources/cloud_sync_api_client.dart';
import 'package:tadamon_attendance_app/features/sync/data/repositories/cloud_sync_repository_impl.dart';
import 'package:tadamon_attendance_app/features/sync/domain/repositories/cloud_sync_repository.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/cloud_sync_bloc.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/audit_log_dao.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/excel_report_engine.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/pdf_report_engine.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/report_storage_service.dart';
import 'package:tadamon_attendance_app/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:tadamon_attendance_app/features/reports/domain/repositories/reports_repository.dart';
import 'package:tadamon_attendance_app/features/reports/domain/usecases/calculate_entitlement_use_case.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:tadamon_attendance_app/features/backup/data/datasources/backup_local_datasource.dart';
import 'package:tadamon_attendance_app/features/backup/data/repositories/backup_repository_impl.dart';
import 'package:tadamon_attendance_app/features/backup/domain/repositories/backup_repository.dart';
import 'package:tadamon_attendance_app/features/backup/domain/usecases/create_backup_use_case.dart';
import 'package:tadamon_attendance_app/features/backup/domain/usecases/restore_backup_use_case.dart';
import 'package:tadamon_attendance_app/features/backup/presentation/bloc/backup_bloc.dart';

final GetIt serviceLocator = GetIt.instance;

void configureCoreDependencies({AppDatabase? database}) {
  if (!serviceLocator.isRegistered<ActiveTeamCubit>()) {
    serviceLocator.registerLazySingleton<ActiveTeamCubit>(
      () => ActiveTeamCubit(),
    );
  }

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
  await database
      .into(database.teams)
      .insertOnConflictUpdate(
        TeamsCompanion.insert(
          id: 'team-youth',
          name: 'فريق الشباب',
          category: 'تحت 19 سنة',
          createdAt: now,
          updatedAt: now,
        ),
      );
  await database
      .into(database.teams)
      .insertOnConflictUpdate(
        TeamsCompanion.insert(
          id: 'team-junior',
          name: 'فريق الناشئين',
          category: 'تحت 17 سنة',
          createdAt: now,
          updatedAt: now,
        ),
      );

  // Clean out any legacy sample/placeholder players so the app starts completely fresh
  const legacySeedIds = [
    'player-1', 'player-2', 'player-3', 'player-4', 'player-5',
    'player-6', 'player-7', 'player-8', 'player-9', 'player-10',
    'player-11', 'player-12', 'player-13', 'player-14', 'player-15',
    'player-16', 'player-17', 'player-18', 'player-19', 'player-20',
    'player-21', 'player-22', 'player-23', 'player-24', 'player-25',
    'player-26', 'player-27',
  ];
  await (database.delete(database.attendanceRecords)
        ..where((tbl) => tbl.playerId.isIn(legacySeedIds)))
      .go();
  await (database.delete(database.players)
        ..where((tbl) => tbl.id.isIn(legacySeedIds)))
      .go();
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
    ..registerLazySingleton<CreateSessionUseCase>(
      () => CreateSessionUseCase(serviceLocator<AttendanceRepository>()),
    )
    ..registerLazySingleton<GetActiveDraftsUseCase>(
      () => GetActiveDraftsUseCase(serviceLocator<AttendanceRepository>()),
    )
    ..registerLazySingleton<GetTodaySessionsUseCase>(
      () => GetTodaySessionsUseCase(serviceLocator<AttendanceRepository>()),
    )
    ..registerLazySingleton<ReadSessionUseCase>(
      () => ReadSessionUseCase(serviceLocator<AttendanceRepository>()),
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
        createSession: serviceLocator<CreateSessionUseCase>(),
        getActiveDrafts: serviceLocator<GetActiveDraftsUseCase>(),
        readSession: serviceLocator<ReadSessionUseCase>(),
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
    )
    ..registerLazySingleton<CloudSyncApiClient>(CloudSyncApiClient.new)
    ..registerLazySingleton<CloudSyncRepository>(
      () => CloudSyncRepositoryImpl(
        apiClient: serviceLocator<CloudSyncApiClient>(),
        settingsRepository: serviceLocator<SettingsRepository>(),
      ),
    )
    ..registerFactory<CloudSyncBloc>(
      () => CloudSyncBloc(repository: serviceLocator<CloudSyncRepository>()),
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
      () => SettingsRepositoryImpl(
        database,
        serviceLocator<PinSecurity>(),
        serviceLocator.isRegistered<SecureValueStore>()
            ? serviceLocator<SecureValueStore>()
            : null,
      ),
    )
    ..registerFactory<SettingsBloc>(
      () => SettingsBloc(serviceLocator<SettingsRepository>()),
    )
    ..registerLazySingleton<TeamsRepository>(
      () => TeamsRepositoryImpl(database),
    )
    ..registerLazySingleton<TeamsBloc>(
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
    ..registerLazySingleton<PlayersBloc>(
      () => PlayersBloc(
        serviceLocator<GetPlayersUseCase>(),
        serviceLocator<AddPlayerUseCase>(),
        serviceLocator<ArchivePlayerUseCase>(),
        serviceLocator<PlayersRepository>(),
      ),
    )
    ..registerLazySingleton<AuditLogDao>(() => AuditLogDao(database))
    ..registerLazySingleton<PdfReportEngine>(PdfReportEngine.new)
    ..registerLazySingleton<ExcelReportEngine>(ExcelReportEngine.new)
    ..registerLazySingleton<ReportStorageService>(ReportStorageService.new)
    ..registerLazySingleton<CalculateEntitlementUseCase>(CalculateEntitlementUseCase.new)
    ..registerLazySingleton<ReportsRepository>(
      () => ReportsRepositoryImpl(
        database: database,
        auditLogDao: serviceLocator<AuditLogDao>(),
        pdfEngine: serviceLocator<PdfReportEngine>(),
        excelEngine: serviceLocator<ExcelReportEngine>(),
        entitlementUseCase: serviceLocator<CalculateEntitlementUseCase>(),
      ),
    )
    ..registerFactory<ReportsBloc>(
      () => ReportsBloc(
        serviceLocator<ReportsRepository>(),
        storageService: serviceLocator<ReportStorageService>(),
        settingsRepository: serviceLocator<SettingsRepository>(),
      ),
    )
    ..registerLazySingleton<BackupLocalDataSource>(() => BackupLocalDataSource(database))
    ..registerLazySingleton<BackupRepository>(
      () => BackupRepositoryImpl(serviceLocator<BackupLocalDataSource>()),
    )
    ..registerLazySingleton<CreateBackupUseCase>(
      () => CreateBackupUseCase(serviceLocator<BackupRepository>()),
    )
    ..registerLazySingleton<RestoreBackupUseCase>(
      () => RestoreBackupUseCase(serviceLocator<BackupRepository>()),
    )
    ..registerFactory<BackupBloc>(
      () => BackupBloc(
        serviceLocator<CreateBackupUseCase>(),
        serviceLocator<RestoreBackupUseCase>(),
      ),
    );
}

Future<void> resetCoreDependencies() async {
  await serviceLocator.reset();
}
