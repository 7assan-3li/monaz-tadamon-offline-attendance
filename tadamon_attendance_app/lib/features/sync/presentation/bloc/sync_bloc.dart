import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadamon_attendance_app/features/sync/domain/usecases/generate_qr_payload_usecase.dart';
import 'package:tadamon_attendance_app/features/sync/domain/usecases/import_qr_payload_usecase.dart';
import 'package:tadamon_attendance_app/features/sync/domain/usecases/start_local_sync_server_usecase.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_event.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_state.dart';

final class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc({
    required this.generateQrPayload,
    required this.importQrPayload,
    required this.startLocalSyncServer,
  }) : super(const SyncInitial()) {
    on<GenerateQrRequested>(_onGenerateQr);
    on<ImportQrRequested>(_onImportQr);
    on<StartP2pServerRequested>(_onStartP2pServer);
    on<StopP2pServerRequested>(_onStopP2pServer);
  }

  final GenerateQrPayloadUseCase generateQrPayload;
  final ImportQrPayloadUseCase importQrPayload;
  final StartLocalSyncServerUseCase startLocalSyncServer;

  Future<void> _onGenerateQr(
    GenerateQrRequested event,
    Emitter<SyncState> emit,
  ) async {
    emit(const SyncLoading());
    try {
      final qrData = await generateQrPayload(event.session);
      emit(QrGeneratedState(qrData: qrData, session: event.session));
    } catch (e) {
      emit(SyncFailureState('فشل توليد كود الترحيل: $e'));
    }
  }

  Future<void> _onImportQr(
    ImportQrRequested event,
    Emitter<SyncState> emit,
  ) async {
    emit(const SyncLoading());
    try {
      final result = await importQrPayload(event.qrData);
      emit(SyncSuccessState(result));
    } catch (e) {
      emit(SyncFailureState('فشل استيراد التمرين: $e'));
    }
  }

  Future<void> _onStartP2pServer(
    StartP2pServerRequested event,
    Emitter<SyncState> emit,
  ) async {
    try {
      await startLocalSyncServer.start(port: event.port);
    } catch (e) {
      emit(SyncFailureState('فشل بدء خادم المزامنة المحلي: $e'));
    }
  }

  Future<void> _onStopP2pServer(
    StopP2pServerRequested event,
    Emitter<SyncState> emit,
  ) async {
    try {
      await startLocalSyncServer.stop();
    } catch (_) {}
  }
}
