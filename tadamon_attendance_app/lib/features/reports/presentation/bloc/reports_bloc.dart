import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadamon_attendance_app/features/reports/domain/repositories/reports_repository.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_event.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  ReportsBloc(this._repository) : super(const ReportsInitial()) {
    on<LoadReportsHubEvent>(_onLoadReportsHub);
    on<ApproveSessionEvent>(_onApproveSession);
    on<SubmitExceptionalEditEvent>(_onSubmitExceptionalEdit);
    on<ExportMonthlyPdfEvent>(_onExportMonthlyPdf);
    on<ExportAdminSummaryPdfEvent>(_onExportAdminSummaryPdf);
    on<ExportAdminSummaryExcelEvent>(_onExportAdminSummaryExcel);
    on<LoadAuditLogsEvent>(_onLoadAuditLogs);
  }

  final ReportsRepository _repository;

  Future<void> _onLoadReportsHub(
    LoadReportsHubEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());
    try {
      final sheet = await _repository.getMonthlyAttendanceSheet(
        teamId: event.teamId,
        year: event.year,
        month: event.month,
      );
      final summary = await _repository.getAdminSummaryReport(
        teamId: event.teamId,
        year: event.year,
        month: event.month,
      );
      final auditLogs = await _repository.getAuditLogs();

      emit(
        ReportsLoaded(
          sheet: sheet,
          summary: summary,
          auditLogs: auditLogs,
        ),
      );
    } catch (e) {
      emit(ReportsError('تعذر تحميل بيانات الكشوفات: $e'));
    }
  }

  Future<void> _onApproveSession(
    ApproveSessionEvent event,
    Emitter<ReportsState> emit,
  ) async {
    final current = state;
    try {
      await _repository.approveSession(
        sessionUuid: event.sessionUuid,
        approvedBy: event.approvedBy,
      );

      if (current is ReportsLoaded) {
        final updatedLogs = await _repository.getAuditLogs();
        emit(
          current.copyWith(
            auditLogs: updatedLogs,
            actionMessage: 'تم اعتماد التمرين نهائياً وإغلاق الكشف بنجاح.',
          ),
        );
      }
    } catch (e) {
      emit(ReportsError('فشل اعتماد التمرين: $e'));
    }
  }

  Future<void> _onSubmitExceptionalEdit(
    SubmitExceptionalEditEvent event,
    Emitter<ReportsState> emit,
  ) async {
    final current = state;
    if (event.reason.trim().isEmpty) {
      emit(const ReportsError('سبب التعديل الاستثنائي إجباري ولا يمكن حفظ التعديل بدونه.'));
      return;
    }

    try {
      await _repository.recordExceptionalEdit(
        sessionUuid: event.sessionUuid,
        playerId: event.playerId,
        newStatus: event.newStatus,
        modifiedBy: event.modifiedBy,
        reason: event.reason,
      );

      if (current is ReportsLoaded) {
        final updatedSheet = await _repository.getMonthlyAttendanceSheet(
          teamId: current.sheet.teamId,
          year: current.sheet.month.year,
          month: current.sheet.month.month,
        );
        final updatedSummary = await _repository.getAdminSummaryReport(
          teamId: current.sheet.teamId,
          year: current.sheet.month.year,
          month: current.sheet.month.month,
        );
        final updatedLogs = await _repository.getAuditLogs();

        emit(
          current.copyWith(
            sheet: updatedSheet,
            summary: updatedSummary,
            auditLogs: updatedLogs,
            actionMessage: 'تم تدوين التعديل الاستثنائي في سجل التدقيق بنجاح.',
          ),
        );
      }
    } catch (e) {
      emit(ReportsError('فشل تسجيل التعديل الاستثنائي: $e'));
    }
  }

  Future<void> _onExportMonthlyPdf(
    ExportMonthlyPdfEvent event,
    Emitter<ReportsState> emit,
  ) async {
    final current = state;
    if (current is! ReportsLoaded) return;

    try {
      final pdfBytes = await _repository.generateMonthlySheetPdf(current.sheet);
      emit(
        current.copyWith(
          exportedPdfBytes: pdfBytes,
          actionMessage: 'تم تجهيز ملف حافظة التحضير (PDF) بنجاح.',
        ),
      );
    } catch (e) {
      emit(ReportsError('تعذر تصدير حافظة التحضير PDF: $e'));
    }
  }

  Future<void> _onExportAdminSummaryPdf(
    ExportAdminSummaryPdfEvent event,
    Emitter<ReportsState> emit,
  ) async {
    final current = state;
    if (current is! ReportsLoaded) return;

    try {
      final pdfBytes = await _repository.generateAdminSummaryPdf(current.summary);
      emit(
        current.copyWith(
          exportedPdfBytes: pdfBytes,
          actionMessage: 'تم تجهيز كشف التحضير وخلاصة الإداري (PDF) بنجاح.',
        ),
      );
    } catch (e) {
      emit(ReportsError('تعذر تصدير خلاصة الإداري PDF: $e'));
    }
  }

  Future<void> _onExportAdminSummaryExcel(
    ExportAdminSummaryExcelEvent event,
    Emitter<ReportsState> emit,
  ) async {
    final current = state;
    if (current is! ReportsLoaded) return;

    try {
      final excelBytes = await _repository.generateAdminSummaryExcel(current.summary);
      emit(
        current.copyWith(
          exportedExcelBytes: excelBytes,
          actionMessage: 'تم تجهيز ملف Excel الميداني (XLSX) بنجاح.',
        ),
      );
    } catch (e) {
      emit(ReportsError('تعذر تصدير تقرير Excel: $e'));
    }
  }

  Future<void> _onLoadAuditLogs(
    LoadAuditLogsEvent event,
    Emitter<ReportsState> emit,
  ) async {
    final current = state;
    if (current is! ReportsLoaded) return;

    try {
      final logs = await _repository.getAuditLogs(sessionUuid: event.sessionUuid);
      emit(current.copyWith(auditLogs: logs));
    } catch (e) {
      emit(ReportsError('تعذر تحميل سجل التدقيق: $e'));
    }
  }
}
