import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/bloc/attendance_bloc.dart';

class FieldDashboardScreen extends StatefulWidget {
  const FieldDashboardScreen({required this.onSessionStarted, super.key});
  final VoidCallback onSessionStarted;

  @override
  State<FieldDashboardScreen> createState() => _FieldDashboardScreenState();
}

class _FieldDashboardScreenState extends State<FieldDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AttendanceBloc>().add(const LoadActiveDraftsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      BlocListener<AttendanceBloc, AttendanceState>(
        listenWhen: (previous, current) =>
            current is AttendanceReady &&
            (previous is AttendanceLoading || previous is AttendanceInitial),
        listener: (_, _) => widget.onSessionStarted(),
        child: Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: AppBar(
            title: const Text(
              'منظومة التحضير الميداني',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Club Header Card
                _buildHeaderCard(context),
                const SizedBox(height: 16),

                // Active Drafts Section
                BlocBuilder<AttendanceBloc, AttendanceState>(
                  builder: (context, state) {
                    final drafts = state is AttendanceReady
                        ? state.activeDrafts
                        : <AttendanceSession>[];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.clipboardList,
                              size: 18,
                              color: AppColors.royalBlue,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'المسودات المفتوحة قيد التحضير',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            if (drafts.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.royalBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${drafts.length} مسودة',
                                  style: const TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.royalBlue,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (drafts.isEmpty)
                          AppCard(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.textSecondary
                                          .withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      LucideIcons.checkCircle2,
                                      size: 18,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Text(
                                      'لا توجد مسودات مفتوحة. اضغط بالأسفل لبدء تمرين جديد للفريق.',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...drafts.map((draft) => _buildDraftCard(context, draft)),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Start New Session Action
                BlocBuilder<AttendanceBloc, AttendanceState>(
                  builder: (context, state) => AppButton(
                    label: state is AttendanceLoading
                        ? 'جارٍ تجهيز الكشف…'
                        : '➕ بدء تحضير تمرين جديد',
                    leadingIcon: LucideIcons.play,
                    onPressed: state is AttendanceLoading
                        ? null
                        : () => _showStartSessionSheet(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildHeaderCard(BuildContext context) {
    final now = DateTime.now();
    final dateStr = '${now.day}/${now.month}/${now.year}';
    return AppCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.royalBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.calendarClock,
              size: 28,
              color: AppColors.royalBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نادي تضامن حضرموت الرياضي',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'كشوفات التحضير الميداني • $dateStr',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.presentBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'أوفلاين 100%',
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
    );
  }

  Widget _buildDraftCard(BuildContext context, AttendanceSession draft) {
    final teamName = switch (draft.teamId) {
      'team-first' => 'الفريق الأول',
      'team-youth' => 'فريق الشباب',
      'team-junior' => 'فريق الناشئين',
      _ => draft.teamId,
    };
    final periodBadge = switch (draft.period) {
      'صباحي' => '☀️ صباحي',
      'إضافي' => '⚡ إضافي',
      _ => '🌙 مسائي',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        teamName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.royalBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          periodBadge,
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
                  const SizedBox(height: 4),
                  Text(
                    '${draft.location} • حاضر: ${draft.presentCount} من ${draft.totalCount}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                context.read<AttendanceBloc>().add(
                      SwitchActiveSessionEvent(draft.sessionUuid),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(LucideIcons.pencil, size: 14),
              label: const Text(
                'متابعة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStartSessionSheet(BuildContext context) {
    String selectedTeam = 'team-first';
    String selectedPeriod = 'مسائي';
    final locationController = TextEditingController(text: 'ملعب بارادم');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'بدء تحضير تمرين جديد',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
              const Divider(height: 16),
              const Text(
                'اختيار الفريق:',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _teamChip(
                    'الفريق الأول',
                    'team-first',
                    selectedTeam,
                    (id) => setModalState(() => selectedTeam = id),
                  ),
                  const SizedBox(width: 8),
                  _teamChip(
                    'فريق الشباب',
                    'team-youth',
                    selectedTeam,
                    (id) => setModalState(() => selectedTeam = id),
                  ),
                  const SizedBox(width: 8),
                  _teamChip(
                    'الناشئين',
                    'team-junior',
                    selectedTeam,
                    (id) => setModalState(() => selectedTeam = id),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'فترة التمرين:',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _periodChip(
                    '🌙 تمرين مسائي',
                    'مسائي',
                    selectedPeriod,
                    (p) => setModalState(() => selectedPeriod = p),
                  ),
                  const SizedBox(width: 8),
                  _periodChip(
                    '☀️ تمرين صباحي',
                    'صباحي',
                    selectedPeriod,
                    (p) => setModalState(() => selectedPeriod = p),
                  ),
                  const SizedBox(width: 8),
                  _periodChip(
                    '⚡ حصة إضافية',
                    'إضافي',
                    selectedPeriod,
                    (p) => setModalState(() => selectedPeriod = p),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: 'موقع التمرين / المنشأة',
                  labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  prefixIcon: const Icon(LucideIcons.mapPin, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: '🚀 بدء التحضير الميداني',
                leadingIcon: LucideIcons.play,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.read<AttendanceBloc>().add(
                        CreateNewSessionEvent(
                          teamId: selectedTeam,
                          period: selectedPeriod,
                          location: locationController.text.trim().isEmpty
                              ? 'ملعب بارادم'
                              : locationController.text.trim(),
                        ),
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamChip(
    String label,
    String id,
    String selectedId,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = id == selectedId;
    return Expanded(
      child: InkWell(
        onTap: () => onSelected(id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.royalBlue
                : AppColors.canvas,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.royalBlue : AppColors.borderSubtle,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _periodChip(
    String label,
    String period,
    String selectedPeriod,
    ValueChanged<String> onSelected,
  ) {
    final isSelected = period == selectedPeriod;
    return Expanded(
      child: InkWell(
        onTap: () => onSelected(period),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.royalBlue
                : AppColors.canvas,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.royalBlue : AppColors.borderSubtle,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
