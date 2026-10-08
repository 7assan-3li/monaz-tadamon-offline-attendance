import 'package:tadamon_attendance_app/features/sync/domain/entities/sync_result.dart';
import 'package:tadamon_attendance_app/features/sync/domain/repositories/sync_repository.dart';

final class ImportQrPayloadUseCase {
  const ImportQrPayloadUseCase(this._repository);

  final SyncRepository _repository;

  Future<SyncResult> call(String qrData) =>
      _repository.importSessionFromQr(qrData);
}
