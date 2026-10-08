import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/sync/domain/repositories/sync_repository.dart';

final class GenerateQrPayloadUseCase {
  const GenerateQrPayloadUseCase(this._repository);

  final SyncRepository _repository;

  Future<String> call(AttendanceSession session) =>
      _repository.exportSessionToQr(session);
}
