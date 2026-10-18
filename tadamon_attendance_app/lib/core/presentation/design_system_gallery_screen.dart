import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/core/di/service_locator.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/core/widgets/squircle_icon_container.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/screens/field_attendance_flow.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/screens/master_scan_qr_screen.dart';

import 'package:tadamon_attendance_app/features/teams/presentation/bloc/active_team_cubit.dart';

class DesignSystemGalleryScreen extends StatefulWidget {
  const DesignSystemGalleryScreen({this.onNavigateTab, super.key});

  final ValueChanged<int>? onNavigateTab;

  @override
  State<DesignSystemGalleryScreen> createState() =>
      _DesignSystemGalleryScreenState();
}

class _DesignSystemGalleryScreenState extends State<DesignSystemGalleryScreen> {
  // Editable State Data
  String _selectedSquad = 'الفريق الأول';
  String _stadiumName = 'منشأة الفقيد بارادم';
  String _sessionTime = '04:15 عصراً';
  String _sessionPeriod = 'الفترة المسائية';
  int _totalPlayers = 0;

  ActiveTeamCubit? _tryGetActiveTeamCubit(BuildContext context) {
    try {
      return context.read<ActiveTeamCubit>();
    } catch (_) {
      if (serviceLocator.isRegistered<ActiveTeamCubit>()) {
        return serviceLocator<ActiveTeamCubit>();
      }
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    final activeCubit = _tryGetActiveTeamCubit(context);
    if (activeCubit != null) {
      _selectedSquad = activeCubit.state.teamName;
      _refreshSquadPlayerCount(activeCubit.state.teamId);
    } else {
      _refreshSquadPlayerCount();
    }
  }

  Future<void> _refreshSquadPlayerCount([String? targetTeamId]) async {
    try {
      final db = serviceLocator<AppDatabase>();
      final teamId = targetTeamId ?? switch (_selectedSquad) {
        'الفريق الأول' => 'team-first',
        'فريق الشباب' => 'team-youth',
        'فريق الشباب (تحت 19)' => 'team-youth',
        'فريق الناشئين' => 'team-junior',
        'فريق الناشئين (تحت 17)' => 'team-junior',
        _ => 'team-first',
      };
      final players = await (db.select(db.players)
            ..where((tbl) => tbl.teamId.equals(teamId)))
          .get();
      if (mounted) {
        setState(() {
          _totalPlayers = players.length;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        children: [
          // 1. Squad & Subscription Bar
          _buildSquadBar(),
          const SizedBox(height: 12),

          // 2. Hero Today's Session Card (Fully interactive & editable)
          _buildHeroSessionCard(context),
          const SizedBox(height: 12),


          // 3. Quick Actions Grid
          _buildQuickActions(context),
          const SizedBox(height: 24),
        ],
      ),
    );

    final activeCubit = _tryGetActiveTeamCubit(context);
    if (activeCubit != null) {
      content = BlocListener<ActiveTeamCubit, ActiveTeamState>(
        bloc: activeCubit,
        listener: (context, state) {
          if (_selectedSquad != state.teamName) {
            setState(() {
              _selectedSquad = state.teamName;
            });
            _refreshSquadPlayerCount(state.teamId);
          }
        },
        child: content,
      );
    }
    return content;
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
                        'الرسمي',
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

  Widget _buildSquadBar() {
    final activeCubit = _tryGetActiveTeamCubit(context);
    final currentTeamId = activeCubit?.state.teamId ?? switch (_selectedSquad) {
      'الفريق الأول' => 'team-first',
      'فريق الشباب' => 'team-youth',
      'فريق الشباب (تحت 19)' => 'team-youth',
      'فريق الناشئين' => 'team-junior',
      'فريق الناشئين (تحت 17)' => 'team-junior',
      _ => 'team-first',
    };

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.royalBlue),
                  SizedBox(width: 6),
                  Text(
                    'الفئة الرياضية النشطة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.sessionBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$_totalPlayers لاعباً',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.royalBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => _showSquadSelectorSheet(context),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        children: [
                          Text(
                            'المزيد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.royalBlue,
                            ),
                          ),
                          Icon(LucideIcons.chevronDown, size: 12, color: AppColors.royalBlue),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSquadTabButton(
                  id: 'team-first',
                  title: 'الفريق الأول',
                  isSelected: currentTeamId == 'team-first',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSquadTabButton(
                  id: 'team-youth',
                  title: 'فريق الشباب',
                  isSelected: currentTeamId == 'team-youth',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSquadTabButton(
                  id: 'team-junior',
                  title: 'فريق الناشئين',
                  isSelected: currentTeamId == 'team-junior',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSquadTabButton({
    required String id,
    required String title,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        final cubit = _tryGetActiveTeamCubit(context);
        if (cubit != null) {
          cubit.selectById(id);
        }
        setState(() {
          _selectedSquad = title;
        });
        _refreshSquadPlayerCount(id);
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.royalBlue : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.royalBlue : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.royalBlue.withValues(alpha: 0.25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _showSquadSelectorSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
            _buildSquadOption(
              ctx,
              id: 'team-first',
              title: 'الفريق الأول',
              subtitle: 'الفئة الأساسية المعتمدة للموسم',
            ),
            _buildSquadOption(
              ctx,
              id: 'team-youth',
              title: 'فريق الشباب',
              subtitle: 'فئة الشباب لدوري المحافظة',
            ),
            _buildSquadOption(
              ctx,
              id: 'team-junior',
              title: 'فريق الناشئين',
              subtitle: 'الفئة العمرية الصغرى',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquadOption(
    BuildContext ctx, {
    required String id,
    required String title,
    required String subtitle,
  }) {
    final activeCubit = _tryGetActiveTeamCubit(context);
    final currentTeamId = activeCubit?.state.teamId ?? switch (_selectedSquad) {
      'الفريق الأول' => 'team-first',
      'فريق الشباب' => 'team-youth',
      'فريق الشباب (تحت 19)' => 'team-youth',
      'فريق الناشئين' => 'team-junior',
      'فريق الناشئين (تحت 17)' => 'team-junior',
      _ => 'team-first',
    };
    final isSelected = currentTeamId == id;
    return InkWell(
      onTap: () {
        final cubit = _tryGetActiveTeamCubit(context);
        if (cubit != null) {
          cubit.selectById(id);
        }
        setState(() {
          _selectedSquad = title;
        });
        _refreshSquadPlayerCount(id);
        Navigator.of(ctx).pop();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.royalBlue.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.royalBlue : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.shield,
              color: isSelected ? AppColors.royalBlue : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.royalBlue
                          : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.royalBlue
                    : AppColors.sessionBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isSelected ? 'الفئة النشطة' : 'اختيار',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.royalBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSessionCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Container(width: 5, color: AppColors.royalBlue),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.sessionBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.activity,
                              size: 13,
                              color: AppColors.session,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'حصة تمرين اليوم',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.session,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _showEditSessionSheet(context),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _sessionPeriod,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(
                                LucideIcons.pencil,
                                size: 10,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        LucideIcons.calendarCheck,
                        size: 24,
                        color: AppColors.royalBlue.withValues(alpha: 0.25),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _todayArabicDate(),
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Interactive Pitch & Time Row
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _showEditSessionSheet(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.mapPin,
                                  size: 16,
                                  color: AppColors.royalBlue,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Text(
                                            'الميدان التدريبي',
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 9,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          SizedBox(width: 3),
                                          Icon(
                                            LucideIcons.pencil,
                                            size: 9,
                                            color: AppColors.royalBlue,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _stadiumName,
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => _showEditSessionSheet(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderSubtle),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  LucideIcons.clock,
                                  size: 16,
                                  color: AppColors.royalBlue,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Text(
                                            'انطلاق التحضير',
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 9,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          SizedBox(width: 3),
                                          Icon(
                                            LucideIcons.pencil,
                                            size: 9,
                                            color: AppColors.royalBlue,
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _sessionTime,
                                        style: const TextStyle(
                                          fontFamily: 'Cairo',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppButton(
                    label: 'بدء تحضير تمرين اليوم',
                    leadingIcon: LucideIcons.play,
                    height: 52,
                    onPressed: () {
                      final currentTeamId = _tryGetActiveTeamCubit(context)?.state.teamId ?? switch (_selectedSquad) {
                        'الفريق الأول' => 'team-first',
                        'فريق الشباب' => 'team-youth',
                        'فريق الشباب (تحت 19)' => 'team-youth',
                        'فريق الناشئين' => 'team-junior',
                        'فريق الناشئين (تحت 17)' => 'team-junior',
                        _ => 'team-first',
                      };
                      if (widget.onNavigateTab != null) {
                        widget.onNavigateTab!(1);
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BlocProvider(
                              create: (_) => serviceLocator<AttendanceBloc>()
                                ..add(
                                  StartTodaySessionEvent(currentTeamId),
                                ),
                              child: const FieldAttendanceFlow(initialPage: 1),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => _showEditSessionSheet(context),
                        borderRadius: BorderRadius.circular(6),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.pencil,
                                size: 14,
                                color: AppColors.royalBlue,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'تعديل بيانات الحصة (اختياري)',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.royalBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        '$_totalPlayers لاعباً مدرجاً',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الإجراءات السريعة',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showExtraSessionModal(context),
                child: const AppCard(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SquircleIconContainer(
                        icon: LucideIcons.plusCircle,
                        color: AppColors.royalBlue,
                        semanticLabel: 'تمرين استثنائي',
                      ),
                      SizedBox(height: 10),
                      Text(
                        'تمرين استثنائي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'جدولة فترة صباحية أو صالة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => widget.onNavigateTab?.call(3),
                child: const AppCard(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SquircleIconContainer(
                        icon: LucideIcons.history,
                        color: AppColors.royalBlue,
                        semanticLabel: 'سجل الكشوفات',
                      ),
                      SizedBox(height: 10),
                      Text(
                        'سجل الكشوفات',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'استعراض الحصص السابقة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider<SyncBloc>(
                        create: (_) => serviceLocator<SyncBloc>(),
                        child: const MasterScanQrScreen(),
                      ),
                    ),
                  );
                },
                child: const AppCard(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SquircleIconContainer(
                        icon: LucideIcons.qrCode,
                        color: AppColors.royalBlue,
                        semanticLabel: 'استقبال تمرين مرحّل',
                      ),
                      SizedBox(height: 10),
                      Text(
                        'استقبال تمرين مرحّل',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'مسح كود QR من الميدان',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => widget.onNavigateTab?.call(2),
                child: const AppCard(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SquircleIconContainer(
                        icon: LucideIcons.users,
                        color: AppColors.royalBlue,
                        semanticLabel: 'إدارة اللاعبين',
                      ),
                      SizedBox(height: 10),
                      Text(
                        'قائمة اللاعبين',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'إدارة التشكيلة والكشف',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  // --- DEDICATED FULL INTERFACES & MODALS ---

  // 1. Edit Session Sheet (Modify pitch, time, period)
  void _showEditSessionSheet(BuildContext context) {
    final stadiumController = TextEditingController(text: _stadiumName);
    final timeController = TextEditingController(text: _sessionTime);
    String selectedPeriod = _sessionPeriod;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                      icon: const Icon(LucideIcons.x),
                    ),
                    const Text(
                      'تعديل بيانات الحصة التدريبية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                const Text(
                  'الميدان التدريبي',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: stadiumController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      LucideIcons.mapPin,
                      color: AppColors.royalBlue,
                    ),
                    hintText: 'أدخل اسم الميدان التدريبي...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    'منشأة الفقيد بارادم',
                    'ملعب التضامن بالمكلا',
                    'الميدان الرديف',
                    'الصالة المغطاة',
                  ].map((venue) {
                    final isSel = stadiumController.text == venue;
                    return ChoiceChip(
                      label: Text(
                        venue,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: isSel ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: AppColors.royalBlue,
                      onSelected: (val) {
                        setSheetState(() => stadiumController.text = venue);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text(
                  'انطلاق التحضير',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      LucideIcons.clock,
                      color: AppColors.royalBlue,
                    ),
                    hintText: 'وقت الحصة (مثال: 04:15 عصراً)...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: [
                    '04:15 عصراً',
                    '04:30 عصراً',
                    '04:00 عصراً',
                    '06:30 صباحاً',
                  ].map((t) {
                    final isSel = timeController.text == t;
                    return ChoiceChip(
                      label: Text(
                        t,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: isSel ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: AppColors.royalBlue,
                      onSelected: (val) {
                        setSheetState(() => timeController.text = t);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                const Text(
                  'فترة الحصة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selectedPeriod == 'الفترة المسائية'
                              ? AppColors.sessionBackground
                              : Colors.transparent,
                          side: BorderSide(
                            color: selectedPeriod == 'الفترة المسائية'
                                ? AppColors.session
                                : AppColors.borderSubtle,
                          ),
                        ),
                        onPressed: () {
                          setSheetState(() => selectedPeriod = 'الفترة المسائية');
                        },
                        child: const Text(
                          'الفترة المسائية',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: selectedPeriod == 'الفترة الصباحية'
                              ? AppColors.sessionBackground
                              : Colors.transparent,
                          side: BorderSide(
                            color: selectedPeriod == 'الفترة الصباحية'
                                ? AppColors.session
                                : AppColors.borderSubtle,
                          ),
                        ),
                        onPressed: () {
                          setSheetState(() => selectedPeriod = 'الفترة الصباحية');
                        },
                        child: const Text(
                          'الفترة الصباحية',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.royalBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(LucideIcons.save, size: 18),
                    label: const Text(
                      'حفظ التعديلات في الحصة الميدانية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        if (stadiumController.text.trim().isNotEmpty) {
                          _stadiumName = stadiumController.text.trim();
                        }
                        if (timeController.text.trim().isNotEmpty) {
                          _sessionTime = timeController.text.trim();
                        }
                        _sessionPeriod = selectedPeriod;
                      });
                      Navigator.of(sheetCtx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم تحديث بيانات الحصة التدريبية بنجاح.',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                          backgroundColor: AppColors.royalBlue,
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
    );
  }

  // 2. Extra Session Modal (Full Dedicated Interface)
  void _showExtraSessionModal(BuildContext context) {
    String selectedType = 'صالة الإعداد البدني واللياقة';
    String sessionLocation = 'صالة النادي الرياضية';
    String sessionHour = '09:00 صباحاً';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(sheetCtx).pop(),
                      icon: const Icon(LucideIcons.x),
                    ),
                    const Row(
                      children: [
                        Icon(LucideIcons.plusCircle, color: AppColors.royalBlue),
                        SizedBox(width: 6),
                        Text(
                          'جدولة تمرين استثنائي',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 20),
                const Text(
                  'نوع الحصة الاستثنائية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                ...[
                  ('صالة الإعداد البدني واللياقة', LucideIcons.dumbbell, 'صالة النادي الرياضية'),
                  ('حصة صباحية مبكرة (تكتيكي)', LucideIcons.sunrise, 'ملعب التضامن بالمكلا'),
                  ('استشفاء مائي وإعادة تأهيل', LucideIcons.waves, 'المسبح الأولمبي'),
                  ('تدريب حراس المرمى التخصصي', LucideIcons.shieldAlert, 'الميدان الرديف'),
                ].map((item) {
                  final isSel = selectedType == item.$1;
                  return InkWell(
                    onTap: () {
                      setSheetState(() {
                        selectedType = item.$1;
                        sessionLocation = item.$3;
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSel
                            ? AppColors.sessionBackground
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel
                              ? AppColors.session
                              : AppColors.borderSubtle,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.$2,
                            size: 18,
                            color: isSel
                                ? AppColors.session
                                : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.$1,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12,
                                fontWeight:
                                    isSel ? FontWeight.bold : FontWeight.normal,
                                color: isSel
                                    ? AppColors.session
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isSel)
                            const Icon(
                              LucideIcons.check,
                              size: 16,
                              color: AppColors.session,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                const Text(
                  'توقيت انطلاق الحصة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: [
                    '06:30 صباحاً',
                    '08:00 صباحاً',
                    '09:00 صباحاً',
                    '10:30 صباحاً',
                  ].map((hour) {
                    final isSel = sessionHour == hour;
                    return ChoiceChip(
                      label: Text(
                        hour,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: isSel ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      selected: isSel,
                      selectedColor: AppColors.royalBlue,
                      onSelected: (val) {
                        setSheetState(() => sessionHour = hour);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.mapPin,
                        size: 16,
                        color: AppColors.royalBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'الموقع المعتمد: $sessionLocation',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.royalBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(LucideIcons.calendarCheck, size: 18),
                    label: const Text(
                      'اعتماد وتثبيت التمرين الاستثنائي',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _stadiumName = sessionLocation;
                        _sessionTime = sessionHour;
                        _sessionPeriod = 'فترة استثنائية';
                      });
                      Navigator.of(sheetCtx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم اعتماد $selectedType في $sessionLocation الساعة $sessionHour.',
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                          backgroundColor: AppColors.royalBlue,
                          duration: const Duration(seconds: 3),
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
    );
  }


  // 5. Notifications Sheet (Interactive)
  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
                const Row(
                  children: [
                    Icon(LucideIcons.bell, color: AppColors.royalBlue),
                    SizedBox(width: 6),
                    Text(
                      'التنبيهات الميدانية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
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
                  Icon(
                    LucideIcons.checkCircle2,
                    color: AppColors.present,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'جاهزية حافظة تمرين اليوم',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.present,
                          ),
                        ),
                        Text(
                          'كشف 27 لاعباً مدرجاً وجاهزاً للرصد الميداني السريع دون إنترنت.',
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
                  Icon(
                    LucideIcons.shieldCheck,
                    color: AppColors.session,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رخصة العتاد الميداني مشفرة ونشطة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.session,
                          ),
                        ),
                        Text(
                          'الجهاز معتمد عبر Ed25519 ومحصن ضد أي تلاعب في الوقت.',
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
          ],
        ),
      ),
    );
  }

  // 6. Profile Quick Sheet (Interactive)
  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
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
                  'الملف الميداني الإداري',
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
                  radius: 24,
                  backgroundColor: AppColors.royalBlue,
                  child: Icon(LucideIcons.user, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إداري الفريق',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'جهاز التحضير الميداني • نظام تضامن حضرموت المعتمد',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.presentBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'مصرح له',
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
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  widget.onNavigateTab?.call(4);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(LucideIcons.settings, size: 18),
                label: const Text(
                  'الانتقال إلى إعدادات النظام والأمان',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _todayArabicDate() {
    final now = DateTime.now();
    const weekdays = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final weekday = weekdays[(now.weekday - 1) % 7];
    final month = months[(now.month - 1) % 12];
    return '$weekday، ${now.day} $month ${now.year}';
  }
}
