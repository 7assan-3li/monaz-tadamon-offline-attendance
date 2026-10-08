import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadamon_attendance_app/features/backup/domain/usecases/create_backup_use_case.dart';
import 'package:tadamon_attendance_app/features/backup/domain/usecases/restore_backup_use_case.dart';
import 'package:tadamon_attendance_app/features/backup/presentation/bloc/backup_event.dart';
import 'package:tadamon_attendance_app/features/backup/presentation/bloc/backup_state.dart';

class BackupBloc extends Bloc<BackupEvent, BackupState> {
  BackupBloc(
    this._createBackupUseCase,
    this._restoreBackupUseCase,
  ) : super(const BackupInitial()) {
    on<CreateBackupRequestedEvent>(_onCreateBackup);
    on<VerifyBackupRequestedEvent>(_onVerifyBackup);
    on<RestoreBackupConfirmedEvent>(_onRestoreBackup);
    on<ResetBackupStateEvent>((event, emit) => emit(const BackupInitial()));
  }

  final CreateBackupUseCase _createBackupUseCase;
  final RestoreBackupUseCase _restoreBackupUseCase;

  Future<void> _onCreateBackup(
    CreateBackupRequestedEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupInProgress(message: 'جاري إنشاء حزمة النسخ الاحتياطي وحساب الختم الرقمي...'));
    try {
      final package = await _createBackupUseCase();
      emit(BackupCreatedSuccess(package));
    } catch (e) {
      emit(BackupFailure('تعذر إنشاء النسخة الاحتياطية: $e'));
    }
  }

  Future<void> _onVerifyBackup(
    VerifyBackupRequestedEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupInProgress(message: 'جاري فحص سلامة الملف والتحقق من ختم SHA-256...'));
    try {
      final result = await _restoreBackupUseCase.verify(event.packageContent);
      if (result.isValid && result.manifest != null) {
        emit(
          BackupVerifiedState(
            manifest: result.manifest!,
            packageContent: event.packageContent,
          ),
        );
      } else {
        emit(BackupFailure(result.errorMessage ?? 'الملف تالف أو غير متطابق رقمياً.'));
      }
    } catch (e) {
      emit(BackupFailure('فشل التحقق من الملف: $e'));
    }
  }

  Future<void> _onRestoreBackup(
    RestoreBackupConfirmedEvent event,
    Emitter<BackupState> emit,
  ) async {
    emit(const BackupInProgress(message: 'جاري استعادة البيانات وعزل إعدادات الأمان...'));
    try {
      await _restoreBackupUseCase(event.packageContent);
      emit(const BackupRestoredSuccess(message: 'تمت استعادة بيانات النادي بنجاح واكتمال المطابقة.'));
    } catch (e) {
      emit(BackupFailure('فشلت عملية الاستعادة: $e'));
    }
  }
}
