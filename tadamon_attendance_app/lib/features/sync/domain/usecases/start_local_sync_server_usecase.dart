import 'package:tadamon_attendance_app/features/sync/domain/repositories/sync_repository.dart';

final class StartLocalSyncServerUseCase {
  const StartLocalSyncServerUseCase(this._repository);

  final SyncRepository _repository;

  Future<void> start({int port = 8089}) =>
      _repository.startP2pServer(port: port);

  Future<void> stop() => _repository.stopP2pServer();
}
