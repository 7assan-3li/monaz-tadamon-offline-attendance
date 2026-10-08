import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/sync/domain/entities/sync_result.dart';
import 'package:tadamon_attendance_app/features/sync/domain/repositories/sync_repository.dart';
import 'package:tadamon_attendance_app/features/sync/domain/usecases/generate_qr_payload_usecase.dart';
import 'package:tadamon_attendance_app/features/sync/domain/usecases/import_qr_payload_usecase.dart';
import 'package:tadamon_attendance_app/features/sync/domain/usecases/start_local_sync_server_usecase.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_event.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_state.dart';

final class _MockSyncRepository implements SyncRepository {
  _MockSyncRepository();

  final String exportQrResult = '{"mock":"qr"}';
  final SyncResult importResult = const SyncResult(
    status: SyncStatus.success,
    sessionUuid: 'mock-session-uuid',
    message: 'تم الاستيراد بنجاح',
    importedItemsCount: 25,
  );

  @override
  Future<String> exportSessionToQr(AttendanceSession session) async => exportQrResult;

  @override
  Future<SyncResult> importSessionFromQr(String qrData) async => importResult;

  @override
  Future<void> startP2pServer({int port = 8089}) async {}

  @override
  Future<void> stopP2pServer() async {}

  @override
  Future<SyncResult> syncWithP2pMaster(String host, {int port = 8089}) async => importResult;
}

void main() {
  final testSession = AttendanceSession(
    sessionUuid: 'session-test-01',
    teamId: 'team-first',
    date: DateTime.parse('2026-10-08T10:00:00Z'),
    items: const [],
    isLocked: true,
    isDispatched: true,
  );

  group('SyncBloc Tests (Stage 5)', () {
    late _MockSyncRepository repository;
    late GenerateQrPayloadUseCase generateQr;
    late ImportQrPayloadUseCase importQr;
    late StartLocalSyncServerUseCase startP2p;

    setUp(() {
      repository = _MockSyncRepository();
      generateQr = GenerateQrPayloadUseCase(repository);
      importQr = ImportQrPayloadUseCase(repository);
      startP2p = StartLocalSyncServerUseCase(repository);
    });

    blocTest<SyncBloc, SyncState>(
      'emits [SyncLoading, QrGeneratedState] when GenerateQrRequested is added',
      build: () => SyncBloc(
        generateQrPayload: generateQr,
        importQrPayload: importQr,
        startLocalSyncServer: startP2p,
      ),
      act: (bloc) => bloc.add(GenerateQrRequested(testSession)),
      expect: () => [
        isA<SyncLoading>(),
        isA<QrGeneratedState>()
            .having((s) => s.qrData, 'qrData', '{"mock":"qr"}')
            .having((s) => s.session.sessionUuid, 'sessionUuid', 'session-test-01'),
      ],
    );

    blocTest<SyncBloc, SyncState>(
      'emits [SyncLoading, SyncSuccessState] when ImportQrRequested is added',
      build: () => SyncBloc(
        generateQrPayload: generateQr,
        importQrPayload: importQr,
        startLocalSyncServer: startP2p,
      ),
      act: (bloc) => bloc.add(const ImportQrRequested('valid-qr-data')),
      expect: () => [
        isA<SyncLoading>(),
        isA<SyncSuccessState>()
            .having((s) => s.result.status, 'status', SyncStatus.success)
            .having((s) => s.result.sessionUuid, 'sessionUuid', 'mock-session-uuid'),
      ],
    );
  });
}
