import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/core/di/service_locator.dart';
import 'package:tadamon_attendance_app/features/teams/presentation/bloc/active_team_cubit.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/attendance/data/datasources/attendance_dao.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:tadamon_attendance_app/features/sync/domain/repositories/cloud_sync_repository.dart';

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
                const SizedBox(height: 12),
                _buildFieldSyncBar(context),
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

  Widget _buildFieldSyncBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(LucideIcons.cloudDownload, size: 16, color: Color(0xFF1D4ED8)),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تحديث بيانات النادي السحابية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                Text(
                  'اسحب أحدث كشوفات وهوية النادي قبل بدء الحصة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4ED8),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('جاري جلب وتحديث بيانات النادي من السحابة...', style: TextStyle(fontFamily: 'Cairo')),
                  duration: Duration(seconds: 2),
                ),
              );
              try {
                final repo = serviceLocator<CloudSyncRepository>();
                final result = await repo.pullMasterData();
                if (!context.mounted) return;
                if (result != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم تحديث البيانات بنجاح (${result.players.length} لاعب • ${result.teams.length} فرق) ✅',
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      backgroundColor: AppColors.present,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تعذر الاتصال بالسحابة؛ تأكد من اتصال الإنترنت.', style: TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: Color(0xFFD97706),
                    ),
                  );
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('حدث خطأ: $e', style: const TextStyle(fontFamily: 'Cairo')),
                    backgroundColor: AppColors.unexcused,
                  ),
                );
              }
            },
            child: const Text('سحب ⬇️', style: TextStyle(fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
    ActiveTeamCubit? activeCubit;
    try {
      activeCubit = context.read<ActiveTeamCubit>();
    } catch (_) {
      if (serviceLocator.isRegistered<ActiveTeamCubit>()) {
        activeCubit = serviceLocator<ActiveTeamCubit>();
      }
    }
    String selectedTeam = activeCubit?.state.teamId ?? 'team-first';
    String selectedPeriod = 'مسائي';
    final locationController = TextEditingController(text: 'ملعب بارادم');
    final timeController = TextEditingController(text: '08:30 مساءً (ليلي)');

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
                'فترة وتصنيف التمرين:',
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
                    '⭐ تمرين استثنائي',
                    'استثنائي',
                    selectedPeriod,
                    (p) {
                      setModalState(() {
                        selectedPeriod = p;
                        if (locationController.text == 'ملعب بارادم') {
                          locationController.text = 'الصالة الرياضية بالمكلا';
                        }
                      });
                    },
                  ),
                ],
              ),
              if (selectedPeriod == 'استثنائي') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.zap, size: 16, color: Color(0xFFD97706)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'تمرين استثنائي إضافي (ليلي أو تكتيكي خاص) مع تحديد موعده ومكانه المحدد.',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'الوقت المحدد للحصة الاستثنائية',
                    labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    prefixIcon: const Icon(LucideIcons.clock, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                decoration: InputDecoration(
                  labelText: selectedPeriod == 'استثنائي'
                      ? 'موقع الحصة الاستثنائية / المنشأة'
                      : 'موقع التمرين / المنشأة',
                  labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  prefixIcon: const Icon(LucideIcons.mapPin, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: selectedPeriod == 'استثنائي'
                    ? '⚡ بدء تمرين استثنائي'
                    : '🚀 بدء التحضير الميداني',
                leadingIcon: selectedPeriod == 'استثنائي'
                    ? LucideIcons.zap
                    : LucideIcons.play,
                onPressed: () async {
                  if (selectedPeriod != 'استثنائي') {
                    // Check if already exists today
                    final dao = serviceLocator<AttendanceDao>();
                    final today = await dao.getTodaySessions(teamId: selectedTeam);
                    AttendanceSession? duplicate;
                    for (final s in today) {
                      if (s.period == selectedPeriod ||
                          (selectedPeriod == 'مسائي' && s.period.contains('مساء')) ||
                          (selectedPeriod == 'صباحي' && s.period.contains('صباح'))) {
                        duplicate = s;
                        break;
                      }
                    }
                    if (duplicate != null) {
                      if (!ctx.mounted) return;
                      showDialog<void>(
                        context: ctx,
                        builder: (dCtx) => AlertDialog(
                          title: const Row(
                            children: [
                              Icon(LucideIcons.alertTriangle, color: AppColors.unexcused, size: 22),
                              SizedBox(width: 8),
                              Text('حصة مسجلة مسبقاً', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                          content: Text(
                            'يوجد بالفعل تمرين ($selectedPeriod) مسجل لهذا الفريق اليوم.\n'
                            'وفقاً للائحة النادي، لا يمكن تكرار نفس الفترة لنفس الفريق في نفس اليوم.\n\n'
                            'إذا كانت هناك حصة تدريبية إضافية أو مران ليلي، يمكنك اختيار "تمرين استثنائي" وتحديد وقته ومكانه.',
                            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12.5),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(dCtx).pop(),
                              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.royalBlue, foregroundColor: Colors.white),
                              icon: const Icon(LucideIcons.zap, size: 16),
                              label: const Text('بدء تمرين استثنائي', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.of(dCtx).pop();
                                setModalState(() {
                                  selectedPeriod = 'استثنائي';
                                  if (locationController.text == 'ملعب بارادم') {
                                    locationController.text = 'الصالة الرياضية بالمكلا';
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      );
                      return;
                    }
                  }

                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop();
                  if (!context.mounted) return;
                  activeCubit?.selectById(selectedTeam);
                  
                  final loc = locationController.text.trim().isEmpty
                      ? (selectedPeriod == 'استثنائي' ? 'الصالة الرياضية بالمكلا' : 'ملعب بارادم')
                      : locationController.text.trim();
                  final finalLocation = selectedPeriod == 'استثنائي' && timeController.text.trim().isNotEmpty
                      ? '$loc - ${timeController.text.trim()}'
                      : loc;

                  context.read<AttendanceBloc>().add(
                        CreateNewSessionEvent(
                          teamId: selectedTeam,
                          period: selectedPeriod,
                          location: finalLocation,
                          sessionTitle: selectedPeriod == 'استثنائي' ? 'تمرين استثنائي إضافي' : null,
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
