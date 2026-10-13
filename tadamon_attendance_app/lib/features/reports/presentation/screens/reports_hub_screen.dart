import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/admin_summary_report.dart';
import 'package:tadamon_attendance_app/features/reports/domain/entities/monthly_attendance_sheet.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_event.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/bloc/reports_state.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/screens/audit_logs_screen.dart';
import 'package:tadamon_attendance_app/features/reports/presentation/widgets/export_success_bottom_sheet.dart';

class ReportsHubScreen extends StatefulWidget {
  const ReportsHubScreen({
    super.key,
    this.onNavigateTab,
  });

  final void Function(int tabIndex)? onNavigateTab;

  @override
  State<ReportsHubScreen> createState() => _ReportsHubScreenState();
}

class _ReportsHubScreenState extends State<ReportsHubScreen> {
  int _selectedTab = 0; // 0: حافظة التحضير (شهري), 1: خلاصة الإداري (تجميعي)
  String _selectedTeamId = 'team-first';
  int _selectedYear = 2026;
  int _selectedMonth = 10;
  String _selectedPeriod = 'all'; // 'all', 'morning', 'evening', 'extra'

  static const List<Map<String, String>> _squads = [
    {
      'id': 'team-first',
      'name': 'الفريق الأول',
      'desc': 'تشكيلة الفريق الأول الممتاز',
    },
    {
      'id': 'team-youth',
      'name': 'فريق الشباب (U-19)',
      'desc': 'فئة الشباب دون 19 سنة',
    },
    {
      'id': 'team-junior',
      'name': 'فريق الناشئين (U-17)',
      'desc': 'فئة الناشئين دون 17 سنة',
    },
  ];

  static const List<Map<String, dynamic>> _months = [
    {'year': 2026, 'month': 10, 'label': 'أكتوبر 2026', 'isCurrent': true},
    {'year': 2026, 'month': 9, 'label': 'سبتمبر 2026', 'isCurrent': false},
    {'year': 2026, 'month': 8, 'label': 'أغسطس 2026', 'isCurrent': false},
    {'year': 2026, 'month': 7, 'label': 'يوليو 2026', 'isCurrent': false},
  ];

  String get _currentSquadName =>
      _squads.firstWhere((s) => s['id'] == _selectedTeamId, orElse: () => _squads.first)['name']!;

  String get _currentMonthName =>
      _months.firstWhere(
        (m) => m['year'] == _selectedYear && m['month'] == _selectedMonth,
        orElse: () => _months.first,
      )['label'] as String;

  @override
  void initState() {
    super.initState();
    _loadReportsData();
  }

  void _loadReportsData() {
    context.read<ReportsBloc>().add(
          LoadReportsHubEvent(
            teamId: _selectedTeamId,
            year: _selectedYear,
            month: _selectedMonth,
            period: _selectedPeriod == 'all' ? null : _selectedPeriod,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportsLoaded) {
          if (state.exportedFilePath != null) {
            ExportSuccessBottomSheet.show(
              context,
              filePath: state.exportedFilePath!,
              fileName: state.exportedFileName ?? 'التقرير_الميداني',
              isPdf: state.isPdf ?? true,
            );
          } else if (state.actionMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.actionMessage!,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: AppColors.royalBlue,
                duration: const Duration(seconds: 3),
              ),
            );
          }
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
        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: _buildAppBar(context, state),
          body: state is ReportsLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.royalBlue),
                )
              : state is ReportsLoaded
                  ? _buildLoadedContent(context, state)
                  : _buildErrorState(context),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ReportsState state) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.royalBlue,
      titleSpacing: 12,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/images/main_logo.png',
              width: 30,
              height: 32,
              fit: BoxFit.contain,
              semanticLabel: 'شعار نادي تضامن حضرموت',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'تضامن حضرموت',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'المعتمد',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF38BDF8),
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'تحضير نادي تضامن حضرموت',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: Color(0xFF93C5FD),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(
            LucideIcons.bell,
            size: 20,
            color: Colors.white,
          ),
          tooltip: 'التنبيهات الميدانية',
          onPressed: () => _showNotificationsSheet(context),
        ),
        IconButton(
          icon: const Icon(
            LucideIcons.history,
            size: 20,
            color: Colors.white,
          ),
          tooltip: 'سجل التدقيق والتعديلات',
          onPressed: () {
            final logs = state is ReportsLoaded ? state.auditLogs : [];
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AuditLogsScreen(auditLogs: logs.cast()),
              ),
            );
          },
        ),
        GestureDetector(
          onTap: () => _showProfileSheet(context),
          child: Container(
            width: 32,
            height: 32,
            margin: const EdgeInsetsDirectional.only(end: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(LucideIcons.user, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadedContent(BuildContext context, ReportsLoaded state) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      children: [
        // 1. Meta & Screen Title
        _buildScreenTitle(),
        const SizedBox(height: 12),

        // System Integration Quick Links
        _buildSystemIntegrationBar(),
        const SizedBox(height: 12),

        // 2. Selectors: Period & Squad (تفاعلية لاختيار الشهر والتشكيلة)
        _buildSelectorsRow(),
        const SizedBox(height: 10),

        // 3. Training Period Filter Chips (فلترة الفترات التدريبية)
        _buildPeriodFilterChips(),
        const SizedBox(height: 12),

        // 4. Segmented Control Switcher
        _buildSegmentedControl(),
        const SizedBox(height: 14),

        // 5. Tab Content: Focused and Simple
        if (_selectedTab == 0) ...[
          // حافظة التحضير (شهري)
          _buildMonthlyStatsBanner(state),
          const SizedBox(height: 14),
          _buildMatrixCard(state.sheet),
          const SizedBox(height: 14),
          _buildPdfExportCard(context),
        ] else ...[
          // خلاصة الإداري (تجميعي)
          _buildOfficialSummaryCard(state.summary),
          const SizedBox(height: 14),
          _buildAccreditationCard(),
          const SizedBox(height: 14),
          _buildSummaryExportCard(context),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildScreenTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.royalBlue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'تقارير الحضور',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.sessionBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                LucideIcons.fileSpreadsheet,
                size: 13,
                color: AppColors.royalBlue,
              ),
              SizedBox(width: 4),
              Text(
                'التقارير الرسمية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.royalBlue,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// System Integration Bar: Direct 1-tap links connecting to Home, Attendance, and Players
  Widget _buildSystemIntegrationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickLinkPill(
              icon: LucideIcons.calendarCheck2,
              label: 'التحضير الميداني',
              color: AppColors.royalBlue,
              onTap: () => widget.onNavigateTab?.call(1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQuickLinkPill(
              icon: LucideIcons.users,
              label: 'كشف اللاعبين',
              color: AppColors.session,
              onTap: () => widget.onNavigateTab?.call(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildQuickLinkPill(
              icon: LucideIcons.layoutDashboard,
              label: 'الرئيسية',
              color: AppColors.textSecondary,
              onTap: () => widget.onNavigateTab?.call(0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinkPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorsRow() {
    return Row(
      children: [
        // Interactive Month Selector
        Expanded(
          child: InkWell(
            onTap: () => _showMonthPickerSheet(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.calendar,
                    size: 18,
                    color: AppColors.royalBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الشهر المعتمد',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _currentMonthName,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevronDown,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Interactive Squad Selector
        Expanded(
          child: InkWell(
            onTap: () => _showSquadSelectorSheet(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.shield,
                    size: 18,
                    color: AppColors.royalBlue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الفئة والتشكيلة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          _currentSquadName,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevronDown,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodFilterChips() {
    final periods = [
      {'key': 'all', 'label': 'جميع الفترات', 'icon': LucideIcons.layers},
      {'key': 'morning', 'label': '☀️ تمرين صباحي', 'icon': LucideIcons.sun},
      {'key': 'evening', 'label': '🌙 تمرين مسائي', 'icon': LucideIcons.moon},
      {'key': 'extra', 'label': '⚡ فترة خاصة', 'icon': LucideIcons.zap},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: periods.map((p) {
          final isSelected = _selectedPeriod == p['key'];
          return Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: Text(
                p['label'] as String,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.royalBlue,
              backgroundColor: AppColors.surface,
              side: BorderSide(
                color: isSelected ? AppColors.royalBlue : AppColors.borderSubtle,
              ),
              onSelected: (selected) {
                if (selected && _selectedPeriod != p['key']) {
                  setState(() {
                    _selectedPeriod = p['key'] as String;
                  });
                  _loadReportsData();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEDFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = 0),
              borderRadius: BorderRadius.circular(9),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: _selectedTab == 0
                      ? const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.calendarCheck,
                      size: 16,
                      color: _selectedTab == 0
                          ? AppColors.royalBlue
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'كشف الحضور الشهري',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: _selectedTab == 0
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: _selectedTab == 0
                            ? AppColors.royalBlue
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = 1),
              borderRadius: BorderRadius.circular(9),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: _selectedTab == 1
                      ? const [
                          BoxShadow(
                            color: Color(0x0C000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          )
                        ]
                        : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.fileText,
                      size: 16,
                      color: _selectedTab == 1
                          ? AppColors.royalBlue
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'الخلاصة الإدارية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: _selectedTab == 1
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: _selectedTab == 1
                            ? AppColors.royalBlue
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStatsBanner(ReportsLoaded state) {
    final totalSessions = state.summary.totalSessions;
    final totalPlayers = state.summary.rows.length;
    final avgAttendance = totalPlayers > 0
        ? (state.summary.rows.map((r) => r.attendanceRate).reduce((a, b) => a + b) / totalPlayers)
        : 0.0;
    final avgPctVal = avgAttendance <= 1.0 ? avgAttendance * 100 : avgAttendance;
    final avgPctString = avgPctVal.toStringAsFixed(0);
    final committedPlayers = state.summary.rows.where((r) => (r.attendanceRate <= 1.0 ? r.attendanceRate * 100 : r.attendanceRate) >= 75.0).length;

    final totalPresent = state.summary.rows.fold<int>(0, (s, r) => s + r.presentCount);
    final totalExcused = state.summary.rows.fold<int>(0, (s, r) => s + r.excusedAbsenceCount);
    final totalUnexcused = state.summary.rows.fold<int>(0, (s, r) => s + r.unexcusedAbsenceCount);
    final totalEvents = totalPresent + totalExcused + totalUnexcused;

    final presentPct = totalEvents > 0 ? ((totalPresent / totalEvents) * 100).round() : (totalSessions > 0 ? 0 : 100);
    final excusedPct = totalEvents > 0 ? ((totalExcused / totalEvents) * 100).round() : 0;
    final unexcusedPct = totalEvents > 0 ? ((totalUnexcused / totalEvents) * 100).round() : 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.sessionBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      LucideIcons.activity,
                      size: 18,
                      color: AppColors.session,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ملخص الحضور الشهري',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '$_currentSquadName • $_currentMonthName',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: totalSessions > 0
                      ? AppColors.presentBackground
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  totalSessions > 0 ? 'كشف معتمد' : 'في انتظار التمارين',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: totalSessions > 0
                        ? AppColors.present
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.royalBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.dumbbell,
                          size: 18,
                          color: AppColors.royalBlue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إجمالي الحصص',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '$totalSessions',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'حصة تدريب',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.presentBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          LucideIcons.badgeCheck,
                          size: 18,
                          color: AppColors.present,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'متوسط الحضور',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '$avgPctString%',
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.present,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'انضباط اللاعبين المستهدفين',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$committedPlayers / $totalPlayers لاعباً ملتزماً',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: presentPct > 0 ? presentPct : 1,
                    child: Container(
                      color: totalEvents > 0 ? AppColors.present : const Color(0xFFCBD5E1),
                    ),
                  ),
                  if (excusedPct > 0)
                    Expanded(
                      flex: excusedPct,
                      child: Container(color: AppColors.excused),
                    ),
                  if (unexcusedPct > 0)
                    Expanded(
                      flex: unexcusedPct,
                      child: Container(color: AppColors.unexcused),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _LegendDot(
                color: totalEvents > 0 ? AppColors.present : const Color(0xFF94A3B8),
                label: 'حاضر ($presentPct%)',
              ),
              const SizedBox(width: 12),
              _LegendDot(color: AppColors.excused, label: 'بعذر ($excusedPct%)'),
              const SizedBox(width: 12),
              _LegendDot(color: AppColors.unexcused, label: 'غياب ($unexcusedPct%)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMatrixCard(MonthlyAttendanceSheet sheet) {
    if (sheet.records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.layoutGrid,
                  size: 18,
                  color: AppColors.royalBlue,
                ),
                const SizedBox(width: 8),
                const Text(
                  'مصفوفة الحافظة المصغرة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAEDFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '0 لاعبين',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.royalBlue,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Icon(
              LucideIcons.calendarOff,
              size: 40,
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 10),
            const Text(
              'لا توجد سجلات حضور مسجلة لهذا الشهر حتى الآن',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'عند رصد واعتماد التمارين الميدانية ستظهر مصفوفة الأداء هنا تلقائياً.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    }

    final displayRecords = sheet.records;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    LucideIcons.layoutGrid,
                    size: 18,
                    color: AppColors.royalBlue,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'جدول الحضور اليومي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEDFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${displayRecords.length} لاعباً',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.royalBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(
                  LucideIcons.arrowRightLeft,
                  size: 16,
                  color: AppColors.royalBlue,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'اسحب أفقياً لعرض أيام التمرين وحالة حضور اللاعبين',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (sheet.sessionDates.isEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.calendarClock,
                    size: 28,
                    color: AppColors.royalBlue.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'لا توجد تمارين معتمدة لهذا الشهر حتى الآن',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'عند اعتماد التمارين الميدانية ستظهر مصفوفة الأيام تفصيلياً هنا.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Builder(
                builder: (context) {
                  const double playerColWidth = 120.0;
                  const double dayColWidth = 32.0;
                  const double pctColWidth = 48.0;
                  final double calculatedWidth = playerColWidth + (sheet.sessionDates.length * dayColWidth) + pctColWidth + 16;
                  final double tableWidth = calculatedWidth < 340 ? 340 : calculatedWidth;

                  return SizedBox(
                    width: tableWidth,
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAEDFF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: playerColWidth,
                                child: Text(
                                  'اللاعب / التاريخ',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              for (final date in sheet.sessionDates)
                                SizedBox(
                                  width: dayColWidth,
                                  child: _DayHeader('${date.day}'),
                                ),
                              const SizedBox(
                                width: pctColWidth,
                                child: Text(
                                  'النسبة',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.royalBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Player Matrix Rows (Tappable for details)
                        for (final record in displayRecords)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: InkWell(
                              onTap: () => _showPlayerDisciplineDetailsSheet(
                                context,
                                playerName: record.playerName,
                                jerseyNumber: record.jerseyNumber,
                                presentCount: record.presentCount,
                                excusedCount: record.excusedCount,
                                unexcusedCount: record.unexcusedCount,
                                entitlementDays: record.athleticEntitlementDays,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.canvas,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: playerColWidth,
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              color: AppColors.royalBlue,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${record.jerseyNumber}',
                                                style: const TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              record.playerName,
                                              style: const TextStyle(
                                                fontFamily: 'Cairo',
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    for (final date in sheet.sessionDates)
                                      SizedBox(
                                        width: dayColWidth,
                                        child: Center(
                                          child: _buildMatrixCell(record.statusByDate[date]),
                                        ),
                                      ),
                                    SizedBox(
                                      width: pctColWidth,
                                      child: Builder(
                                        builder: (context) {
                                          final total = sheet.totalSessions;
                                          final pct = total > 0
                                              ? ((record.presentCount / total) * 100).round()
                                              : 100;
                                          final color = pct >= 85
                                              ? AppColors.present
                                              : (pct >= 60 ? AppColors.excused : AppColors.unexcused);
                                          return Text(
                                            '$pct%',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: color,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMatrixCell(AttendanceStatus? status) {
    if (status == null) {
      return const _StatusCell('-', AppColors.textSecondary, Color(0xFFF1F5F9));
    }
    return _StatusCell(
      status.shortArabicSymbol,
      status.foregroundColor,
      status.backgroundColor,
    );
  }

  Widget _buildOfficialSummaryCard(AdminSummaryReport summary) {
    final rows = summary.rows;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    LucideIcons.fileSpreadsheet,
                    size: 18,
                    color: AppColors.royalBlue,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'خلاصة حضور وانضباط اللاعبين',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.royalBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'الاستحقاق الرياضي',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.royalBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // List of Player Summary Cards or Empty State
          if (rows.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    LucideIcons.fileQuestion,
                    size: 38,
                    color: AppColors.textSecondary.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'لا توجد سجلات لاعبين مسجلة لهذا الشهر',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'أضف اللاعبين وسجّل حضور التمارين لتوليد كشف الخلاصة الإدارية تلقائياً.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _showPlayerDisciplineDetailsSheet(
                    context,
                    playerName: row.playerName,
                    jerseyNumber: row.jerseyNumber,
                    presentCount: row.presentCount,
                    excusedCount: row.excusedAbsenceCount,
                    unexcusedCount: row.unexcusedAbsenceCount,
                    entitlementDays: row.athleticEntitlementDays,
                    position: row.position,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: AppColors.royalBlue,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${row.jerseyNumber}',
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                row.playerName,
                                                style: const TextStyle(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            _StatusBadge(
                                              row.athleticDisciplineStatus,
                                              row.unexcusedAbsenceCount > 0
                                                  ? AppColors.excusedBackground
                                                  : AppColors.presentBackground,
                                              row.unexcusedAbsenceCount > 0
                                                  ? AppColors.excused
                                                  : AppColors.present,
                                            ),
                                          ],
                                        ),
                                        Text(
                                          row.position,
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${row.athleticEntitlementDays}',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.royalBlue,
                                  ),
                                ),
                                const Text(
                                  'حصة مؤهلة',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 9,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      // Breakdown stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildMiniStat(
                              label: 'حضور',
                              value: '${row.presentCount}',
                              color: AppColors.present,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildMiniStat(
                              label: 'بعذر',
                              value: '${row.excusedAbsenceCount}',
                              color: AppColors.excused,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildMiniStat(
                              label: 'غياب',
                              value: '${row.unexcusedAbsenceCount}',
                              color: AppColors.unexcused,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildMiniStat(
                              label: 'النسبة',
                              value: '${row.attendanceRate.toStringAsFixed(0)}%',
                              color: AppColors.royalBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 9,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccreditationCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.fileSignature,
                    size: 16,
                    color: AppColors.royalBlue,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'المصادقة الإدارية الرسمية',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'توثيق معتمد',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إداري الفريق المكلف',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'إداري الفريق المعتمد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'المصادقة الميدانية الرسمية',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.presentBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              LucideIcons.check,
                              size: 12,
                              color: AppColors.present,
                            ),
                            SizedBox(width: 3),
                            Text(
                              'معتمد',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.present,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مدير عام النادي',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 9,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            'المصادقة الإدارية',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'المصادقة الرسمية للنادي',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.presentBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'معتمد رسمياً',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.present,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// PDF Export Card for Tab 0
  Widget _buildPdfExportCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.printer,
                    size: 16,
                    color: AppColors.royalBlue,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'تصدير كشف الحضور',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'ملف PDF',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.royalBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalBlue,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                context.read<ReportsBloc>().add(const ExportMonthlyPdfEvent());
              },
              icon: const Icon(LucideIcons.fileDown, size: 20, color: Colors.white),
              label: const Text(
                'تصدير كشف الحضور (PDF)',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Official Summary Export Card for Tab 1 (PDF & Excel)
  Widget _buildSummaryExportCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    LucideIcons.fileSpreadsheet,
                    size: 16,
                    color: AppColors.royalBlue,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'تصدير كشف التحضير والخلاصة الإدارية',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                'خيارات رسمية',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.royalBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Button 1: PDF
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalBlue,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                context
                    .read<ReportsBloc>()
                    .add(const ExportAdminSummaryPdfEvent());
              },
              icon: const Icon(LucideIcons.fileText, size: 18, color: Colors.white),
              label: const Text(
                'تصدير خلاصة الإداري (PDF الرسمية)',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Button 2: Excel
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.present,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                context
                    .read<ReportsBloc>()
                    .add(const ExportAdminSummaryExcelEvent());
              },
              icon: const Icon(LucideIcons.download, size: 18, color: Colors.white),
              label: const Text(
                'تصدير كشف الجداول (Excel XLSX)',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Modal Bottom Sheets ---

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(LucideIcons.x),
                  ),
                  const Text(
                    'التنبيهات الميدانية للكشوفات',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.presentBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.checkCircle2, color: AppColors.present, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'كشف الحافظة معتمد ومؤهل للتصدير',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.present,
                            ),
                          ),
                          Text(
                            'كافة بيانات الحضور والانضباط الرياضي مكتملة لشهر أكتوبر 2026 دون أي تضارب.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.sessionBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(LucideIcons.shieldCheck, color: AppColors.royalBlue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'التوثيق الرقمي ومطابقة البصمة العتادية',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.royalBlue,
                            ),
                          ),
                          Text(
                            'تم تأمين الكشف بالتوقيع الرقمي Ed25519 ومطابقة بصمة جهاز الإدارة الماستر.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.royalBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'فهمت ذلك',
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(LucideIcons.x),
                  ),
                  const Text(
                    'الملف الإداري وجهاز الماستر',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.royalBlue,
                    child: Icon(LucideIcons.userCheck, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'إداري الفريق المعتمد',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.presentBackground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'مدير النظام المعتمد (Master Admin)',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.present,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Column(
                  children: [
                    _ProfileRow(label: 'النادي الرياضي', value: 'نادي تضامن حضرموت'),
                    Divider(height: 12),
                    _ProfileRow(label: 'حالة الترخيص المكتبي', value: 'نشط ودائم أوفلاين'),
                    Divider(height: 12),
                    _ProfileRow(label: 'الصلاحيات المعتمدة', value: 'إدارة، تحضير، وتصدير التقارير'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.royalBlue,
                    side: const BorderSide(color: AppColors.royalBlue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'إغلاق',
                    style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSquadSelectorSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(LucideIcons.x),
                  ),
                  const Text(
                    'اختيار الفئة والتشكيلة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              for (final squad in _squads)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      setState(() => _selectedTeamId = squad['id']!);
                      _loadReportsData();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedTeamId == squad['id']
                            ? AppColors.sessionBackground
                            : AppColors.canvas,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedTeamId == squad['id']
                              ? AppColors.royalBlue
                              : AppColors.borderSubtle,
                          width: _selectedTeamId == squad['id'] ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.shield,
                                size: 20,
                                color: _selectedTeamId == squad['id']
                                    ? AppColors.royalBlue
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    squad['name']!,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: _selectedTeamId == squad['id']
                                          ? AppColors.royalBlue
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    squad['desc']!,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (_selectedTeamId == squad['id'])
                            const Icon(LucideIcons.checkCircle2, color: AppColors.royalBlue, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMonthPickerSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(LucideIcons.x),
                  ),
                  const Text(
                    'اختيار الشهر المعتمد',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              for (final m in _months)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      setState(() {
                        _selectedYear = m['year'] as int;
                        _selectedMonth = m['month'] as int;
                      });
                      _loadReportsData();
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedYear == m['year'] && _selectedMonth == m['month']
                            ? AppColors.sessionBackground
                            : AppColors.canvas,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedYear == m['year'] && _selectedMonth == m['month']
                              ? AppColors.royalBlue
                              : AppColors.borderSubtle,
                          width: _selectedYear == m['year'] && _selectedMonth == m['month'] ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 18,
                                color: _selectedYear == m['year'] && _selectedMonth == m['month']
                                    ? AppColors.royalBlue
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                m['label'] as String,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedYear == m['year'] && _selectedMonth == m['month']
                                      ? AppColors.royalBlue
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          if (_selectedYear == m['year'] && _selectedMonth == m['month'])
                            const Icon(LucideIcons.checkCircle2, color: AppColors.royalBlue, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlayerDisciplineDetailsSheet(
    BuildContext context, {
    required String playerName,
    required int jerseyNumber,
    required int presentCount,
    required int excusedCount,
    required int unexcusedCount,
    required int entitlementDays,
    String? position,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(LucideIcons.x),
                  ),
                  const Text(
                    'ملخص الانضباط والاستحقاق الرياضي',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.royalBlue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '$jerseyNumber',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          playerName,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          position ?? 'لاعب نادي تضامن حضرموت',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    _ProfileRow(label: 'أيام الحضور الميداني', value: '$presentCount حصص'),
                    const Divider(height: 12),
                    _ProfileRow(label: 'الغياب بعذر مقبول', value: '$excusedCount حصص'),
                    const Divider(height: 12),
                    _ProfileRow(label: 'الغياب غير المبرر', value: '$unexcusedCount حصص'),
                    const Divider(height: 12),
                    _ProfileRow(
                      label: 'الاستحقاق الرياضي الإجمالي',
                      value: '$entitlementDays يوماً مؤهلاً',
                      valueColor: AppColors.royalBlue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.royalBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        widget.onNavigateTab?.call(2); // Jump to Players tab
                      },
                      icon: const Icon(LucideIcons.users, size: 16, color: Colors.white),
                      label: const Text(
                        'فتح كشف اللاعبين',
                        style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            LucideIcons.alertCircle,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 12),
          const Text(
            'تعذر تحميل بيانات الكشوفات',
            style: TextStyle(fontFamily: 'Cairo', fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.royalBlue,
            ),
            onPressed: _loadReportsData,
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader(this.day);

  final String day;

  @override
  Widget build(BuildContext context) {
    return Text(
      day,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Cairo',
        fontSize: 10,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  const _StatusCell(this.symbol, this.color, this.background);

  final String symbol;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.label, this.background, this.color);

  final String label;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
