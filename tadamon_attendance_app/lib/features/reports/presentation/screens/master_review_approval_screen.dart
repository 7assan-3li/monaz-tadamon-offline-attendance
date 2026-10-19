import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/presentation/app_role_scope.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_event.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_state.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/screens/audit_logs_screen.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/widgets/exceptional_edit_reason_dialog.dart';

class MasterReviewApprovalScreen extends StatefulWidget {
  const MasterReviewApprovalScreen({
    required this.sessionUuid,
    required this.sessionDate,
    required this.teamName,
    this.isInitiallyApproved = false,
    super.key,
  });

  final String sessionUuid;
  final DateTime sessionDate;
  final String teamName;
  final bool isInitiallyApproved;

  @override
  State<MasterReviewApprovalScreen> createState() =>
      _MasterReviewApprovalScreenState();
}

class _MasterReviewApprovalScreenState
    extends State<MasterReviewApprovalScreen> {
  late bool _isApproved;

  @override
  void initState() {
    super.initState();
    _isApproved = widget.isInitiallyApproved;
  }

  Future<void> _onEditPlayer(
    BuildContext ctx,
    String playerId,
    String playerName,
    AttendanceStatus currentStatus,
  ) async {
    final nextStatus = switch (currentStatus) {
      AttendanceStatus.present => AttendanceStatus.excused,
      AttendanceStatus.excused => AttendanceStatus.unexcused,
      AttendanceStatus.unexcused => AttendanceStatus.present,
    };

    final reason = await showDialog<String>(
      context: ctx,
      builder: (context) => ExceptionalEditReasonDialog(
        playerName: playerName,
        currentStatus: currentStatus,
        targetStatus: nextStatus,
      ),
    );

    if (reason != null && ctx.mounted) {
      ctx.read<ReportsBloc>().add(
            SubmitExceptionalEditEvent(
              sessionUuid: widget.sessionUuid,
              playerId: playerId,
              newStatus: nextStatus,
              reason: reason,
              modifiedBy: 'المشرف الإداري',
            ),
          );
    }
  }

  void _onApprove(BuildContext context) {
    context.read<ReportsBloc>().add(
          ApproveSessionEvent(
            sessionUuid: widget.sessionUuid,
            approvedBy: 'مدير النادي المعتمد',
          ),
        );
    setState(() {
      _isApproved = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportsLoaded && state.actionMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.actionMessage!,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.royalBlue,
            ),
          );
        } else if (state is ReportsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: AppColors.unexcused,
            ),
          );
        }
      },
      builder: (context, state) {
        final isMaster = AppRoleScope.isMaster(context);
        final auditLogs = state is ReportsLoaded ? state.auditLogs : [];

        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: AppBar(
            title: Text(
              isMaster ? 'مراجعة واعتماد الكشف الميداني' : 'استعراض كشف الحصة التدريبية',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (isMaster)
                IconButton(
                  icon: const Icon(LucideIcons.history),
                  tooltip: 'سجل التدقيق والتعديلات',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            AuditLogsScreen(auditLogs: auditLogs.cast()),
                      ),
                    );
                  },
                ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.teamName,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.royalBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'تاريخ التمرين: ${widget.sessionDate.year}/${widget.sessionDate.month}/${widget.sessionDate.day}',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _isApproved
                              ? const Color(0xFFDCFCE7)
                              : AppColors.excusedBackground,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isApproved
                                ? const Color(0xFFBBF7D0)
                                : const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isApproved
                                  ? LucideIcons.badgeCheck
                                  : LucideIcons.clock,
                              size: 15,
                              color: _isApproved
                                  ? const Color(0xFF16A34A)
                                  : AppColors.excused,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _isApproved ? 'معتمد رسمياً' : 'بانتظار الاعتماد',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: _isApproved
                                    ? const Color(0xFF15803D)
                                    : AppColors.excused,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Player list section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'قائمة اللاعبين وحالات الحضور الميدانية:',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (state is ReportsLoaded)
                      Text(
                        '${state.sheet.records.length} لاعباً',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: state is ReportsLoaded
                      ? ListView.separated(
                          itemCount: state.sheet.records.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final record = state.sheet.records[index];
                            final status = record.statusByDate[widget.sessionDate] ??
                                AttendanceStatus.present;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 17,
                                    backgroundColor: AppColors.royalBlue.withValues(alpha: 0.1),
                                    child: Text(
                                      '${record.jerseyNumber}',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.royalBlue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      record.playerName,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  AttendanceBadge(status: status),
                                  if (isMaster) ...[
                                    const SizedBox(width: 6),
                                    IconButton(
                                      icon: const Icon(
                                        LucideIcons.pencil,
                                        size: 16,
                                        color: AppColors.royalBlue,
                                      ),
                                      tooltip: 'تعديل استثنائي بمسوغ إداري',
                                      onPressed: () => _onEditPlayer(
                                        context,
                                        record.playerId,
                                        record.playerName,
                                        status,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),

                const SizedBox(height: 12),

                // Primary Approval Action or Accredited Status Banner
                if (_isApproved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.badgeCheck,
                          size: 20,
                          color: Color(0xFF16A34A),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'كشف معتمد ومقفل رسمياً في سجلات النادي',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isMaster)
                  AppButton(
                    label: 'اعتماد الكشف نهائياً',
                    leadingIcon: LucideIcons.checkCheck,
                    variant: AppButtonVariant.primary,
                    onPressed: () => _onApprove(context),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.lock,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'استعراض فقط • تعديل حروف الغياب والاعتماد خاص بإدارة النادي',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
