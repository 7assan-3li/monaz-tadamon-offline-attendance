import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/report_storage_service.dart';
import 'package:tadamon_attendance_app/features/reports/domain/repositories/reports_repository.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_event.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_state.dart';
import 'package:tadamon_attendance_app/features/settings/domain/repositories/settings_repository.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  ReportsBloc(
    this._repository, {
    this.storageService,
    this.settingsRepository,
  }) : super(const ReportsInitial()) {
    on<LoadReportsHubEvent>(_onLoadReportsHub);
    on<ApproveSessionEvent>(_onApproveSession);
    on<SubmitExceptionalEditEvent>(_onSubmitExceptionalEdit);
    on<ExportMonthlyPdfEvent>(_onExportMonthlyPdf);
    on<ExportAdminSummaryPdfEvent>(_onExportAdminSummaryPdf);
    on<ExportAdminSummaryExcelEvent>(_onExportAdminSummaryExcel);
    on<LoadAuditLogsEvent>(_onLoadAuditLogs);
  }

  final ReportsRepository _repository;
  final ReportStorageService? storageService;
  final SettingsRepository? settingsRepository;

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
        period: event.period,
        customStartDate: event.customStartDate,
        customEndDate: event.customEndDate,
      );
      final summary = await _repository.getAdminSummaryReport(
        teamId: event.teamId,
        year: event.year,
        month: event.month,
        period: event.period,
        customStartDate: event.customStartDate,
        customEndDate: event.customEndDate,
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
      String? savedFilePath;
      String? fileName;
      bool autoShareTriggered = false;

      if (storageService != null) {
        final settings = await settingsRepository?.read();
        final sanitizedTeam = current.sheet.teamName.replaceAll(' ', '_');
        fileName = 'كشف_حضور_${sanitizedTeam}_${current.sheet.month.year}_${current.sheet.month.month}.pdf';
        final file = await storageService!.saveReportFile(
          fileName: fileName,
          bytes: pdfBytes,
          customDirectory: settings?.reportsExportPath,
        );
        savedFilePath = file.path;
        if (settings?.autoShareOnExport == true) {
          autoShareTriggered = true;
          storageService!.shareReportFile(
            file.path,
            subject: 'حافظة تحضير نادي تضامن حضرموت',
            text: 'مرفق حافظة تحضير نادي تضامن حضرموت - ${current.sheet.teamName}',
          ).ignore();
        }
      }

      emit(
        current.copyWith(
          exportedPdfBytes: pdfBytes,
          exportedFilePath: savedFilePath,
          exportedFileName: fileName,
          isPdf: true,
          autoShareTriggered: autoShareTriggered,
          actionMessage: savedFilePath != null
              ? 'تم تصدير وحفظ كشف الحضور بنجاح في: $savedFilePath'
              : 'تم تجهيز ملف حافظة التحضير (PDF) بنجاح.',
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
      String? savedFilePath;
      String? fileName;
      bool autoShareTriggered = false;

      if (storageService != null) {
        final settings = await settingsRepository?.read();
        final sanitizedTeam = current.summary.teamName.replaceAll(' ', '_');
        fileName = 'خلاصة_الإداري_${sanitizedTeam}_${current.summary.month.year}_${current.summary.month.month}.pdf';
        final file = await storageService!.saveReportFile(
          fileName: fileName,
          bytes: pdfBytes,
          customDirectory: settings?.reportsExportPath,
        );
        savedFilePath = file.path;
        if (settings?.autoShareOnExport == true) {
          autoShareTriggered = true;
          storageService!.shareReportFile(
            file.path,
            subject: 'خلاصة الإداري - نادي تضامن حضرموت',
            text: 'مرفق كشف التحضير وخلاصة الإداري الرسمية - ${current.summary.teamName}',
          ).ignore();
        }
      }

      emit(
        current.copyWith(
          exportedPdfBytes: pdfBytes,
          exportedFilePath: savedFilePath,
          exportedFileName: fileName,
          isPdf: true,
          autoShareTriggered: autoShareTriggered,
          actionMessage: savedFilePath != null
              ? 'تم تصدير وحفظ خلاصة الإداري بنجاح في: $savedFilePath'
              : 'تم تجهيز كشف التحضير وخلاصة الإداري (PDF) بنجاح.',
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
      String? savedFilePath;
      String? fileName;
      bool autoShareTriggered = false;

      if (storageService != null) {
        final settings = await settingsRepository?.read();
        final sanitizedTeam = current.summary.teamName.replaceAll(' ', '_');
        fileName = 'خلاصة_الإداري_${sanitizedTeam}_${current.summary.month.year}_${current.summary.month.month}.xlsx';
        final file = await storageService!.saveReportFile(
          fileName: fileName,
          bytes: excelBytes,
          customDirectory: settings?.reportsExportPath,
        );
        savedFilePath = file.path;
        if (settings?.autoShareOnExport == true) {
          autoShareTriggered = true;
          storageService!.shareReportFile(
            file.path,
            subject: 'تقرير إكسل - نادي تضامن حضرموت',
            text: 'مرفق تقرير إكسل لخلاصة الإداري - ${current.summary.teamName}',
          ).ignore();
        }
      }

      emit(
        current.copyWith(
          exportedExcelBytes: excelBytes,
          exportedFilePath: savedFilePath,
          exportedFileName: fileName,
          isPdf: false,
          autoShareTriggered: autoShareTriggered,
          actionMessage: savedFilePath != null
              ? 'تم تصدير وحفظ تقرير Excel بنجاح في: $savedFilePath'
              : 'تم تجهيز ملف Excel الميداني (XLSX) بنجاح.',
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
