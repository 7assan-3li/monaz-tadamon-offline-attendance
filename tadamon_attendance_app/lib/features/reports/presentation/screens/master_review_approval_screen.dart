import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
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
              content: Text(state.actionMessage!),
              backgroundColor: AppColors.royalBlue,
            ),
          );
        } else if (state is ReportsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.unexcused,
            ),
          );
        }
      },
      builder: (context, state) {
        final auditLogs = state is ReportsLoaded ? state.auditLogs : [];

        return Scaffold(
          appBar: AppBar(
            title: const Text('مراجعة واعتماد الكشف الميداني'),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.history),
                tooltip: 'سجل التدقيق',
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.royalBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'تاريخ التمرين: ${widget.sessionDate.year}/${widget.sessionDate.month}/${widget.sessionDate.day}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isApproved
                              ? AppColors.presentBackground
                              : AppColors.excusedBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isApproved
                                  ? LucideIcons.badgeCheck
                                  : LucideIcons.clock,
                              size: 16,
                              color: _isApproved
                                  ? AppColors.present
                                  : AppColors.excused,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isApproved ? 'معتمد رسمياً' : 'بانتظار الاعتماد',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _isApproved
                                    ? AppColors.present
                                    : AppColors.excused,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Player list section
                Text(
                  'قائمة اللاعبين وحالات الحضور الميدانية:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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

                            return AppCard(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.canvas,
                                    child: Text(
                                      '${record.jerseyNumber}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.royalBlue,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      record.playerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  AttendanceBadge(status: status),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(LucideIcons.pencil,
                                        size: 18, color: AppColors.royalBlue),
                                    tooltip: 'تعديل استثنائي بالسبب',
                                    onPressed: () => _onEditPlayer(
                                      context,
                                      record.playerId,
                                      record.playerName,
                                      status,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),

                const SizedBox(height: 12),

                // Primary Approval Action
                AppButton(
                  label: _isApproved
                      ? 'تم اعتماد الكشف رسمياً في سجلات النادي'
                      : 'اعتماد الكشف نهائياً',
                  leadingIcon: _isApproved
                      ? LucideIcons.badgeCheck
                      : LucideIcons.checkCheck,
                  variant: _isApproved
                      ? AppButtonVariant.secondary
                      : AppButtonVariant.primary,
                  onPressed: _isApproved ? null : () => _onApprove(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
