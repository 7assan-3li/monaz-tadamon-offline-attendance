import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_event.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_state.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/screens/audit_logs_screen.dart';

class ReportsHubScreen extends StatefulWidget {
  const ReportsHubScreen({super.key});

  @override
  State<ReportsHubScreen> createState() => _ReportsHubScreenState();
}

class _ReportsHubScreenState extends State<ReportsHubScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    context.read<ReportsBloc>().add(
          LoadReportsHubEvent(
            teamId: 'team-first',
            year: now.year,
            month: now.month,
          ),
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              duration: const Duration(seconds: 3),
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
        return Scaffold(
          appBar: AppBar(
            title: const Text('الكشوفات والتقارير الرسمية للنادي'),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.history),
                tooltip: 'سجل التدقيق والتعديلات',
                onPressed: () {
                  final logs = state is ReportsLoaded ? state.auditLogs : [];
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          AuditLogsScreen(auditLogs: logs.cast()),
                    ),
                  );
                },
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  icon: Icon(LucideIcons.fileSpreadsheet),
                  text: 'خلاصة الإداري والاستحقاق',
                ),
                Tab(
                  icon: Icon(LucideIcons.calendarCheck),
                  text: 'حافظة التحضير المفتوحة',
                ),
              ],
            ),
          ),
          body: state is ReportsLoading
              ? const Center(child: CircularProgressIndicator())
              : state is ReportsLoaded
                  ? TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAdminSummaryTab(context, state),
                        _buildMonthlySheetTab(context, state),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.alertCircle, size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 12),
                          const Text('تعذر تحميل بيانات الكشوفات'),
                          const SizedBox(height: 16),
                          AppButton(
                            label: 'إعادة المحاولة',
                            onPressed: () {
                              final now = DateTime.now();
                              context.read<ReportsBloc>().add(
                                    LoadReportsHubEvent(
                                      teamId: 'team-first',
                                      year: now.year,
                                      month: now.month,
                                    ),
                                  );
                            },
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildAdminSummaryTab(BuildContext context, ReportsLoaded state) {
    final summary = state.summary;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header info
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      summary.clubName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.royalBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${summary.teamName} - ${summary.season}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'الحصص: ${summary.totalSessions}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Player rows
          Expanded(
            child: ListView.separated(
              itemCount: summary.rows.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final row = summary.rows[index];
                return AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.canvas,
                                child: Text(
                                  '${row.jerseyNumber}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.royalBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                row.playerName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.presentBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'الاستحقاق: ${row.athleticEntitlementDays} يوم',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.present,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'حضور: ${row.presentCount} | غياب: ${row.unexcusedAbsenceCount} | عذر: ${row.excusedAbsenceCount}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            row.athleticDisciplineStatus,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: row.unexcusedAbsenceCount >= 3
                                  ? AppColors.unexcused
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Export buttons
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'تصدير خلاصة الإداري (PDF)',
                  leadingIcon: LucideIcons.fileText,
                  variant: AppButtonVariant.primary,
                  onPressed: () {
                    context
                        .read<ReportsBloc>()
                        .add(const ExportAdminSummaryPdfEvent());
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'تصدير إكسل (XLSX)',
                  leadingIcon: LucideIcons.fileSpreadsheet,
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    context
                        .read<ReportsBloc>()
                        .add(const ExportAdminSummaryExcelEvent());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySheetTab(BuildContext context, ReportsLoaded state) {
    final sheet = state.sheet;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'حافظة التحضير الشهرية - ${sheet.teamName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.royalBlue,
                  ),
                ),
                Text(
                  'شهر ${sheet.month.month} / ${sheet.month.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: sheet.records.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final r = sheet.records[index];
                return AppCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: AppColors.canvas,
                            child: Text(
                              '${r.jerseyNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.royalBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            r.playerName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Text(
                        'حاضر: ${r.presentCount} | استحقاق: ${r.athleticEntitlementDays} حصة',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'تصدير حافظة التحضير المفتوحة (PDF)',
            leadingIcon: LucideIcons.fileText,
            variant: AppButtonVariant.primary,
            onPressed: () {
              context.read<ReportsBloc>().add(const ExportMonthlyPdfEvent());
            },
          ),
        ],
      ),
    );
  }
}
