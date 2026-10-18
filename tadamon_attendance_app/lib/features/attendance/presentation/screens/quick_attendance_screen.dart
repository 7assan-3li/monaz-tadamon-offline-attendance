import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/attendance_session.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/widgets/attendance_player_card.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/widgets/locked_session_banner.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/widgets/one_touch_present_button.dart';
import 'package:tadamon_attendance_app/core/di/service_locator.dart';
import 'package:tadamon_attendance_app/core/presentation/app_role_scope.dart';
import 'package:tadamon_attendance_app/features/teams/presentation/bloc/active_team_cubit.dart';

class QuickAttendanceScreen extends StatefulWidget {
  const QuickAttendanceScreen({
    required this.onReview,
    this.onBack,
    this.showBottomNav = true,
    super.key,
  });

  final VoidCallback onReview;
  final VoidCallback? onBack;
  final bool showBottomNav;

  @override
  State<QuickAttendanceScreen> createState() => _QuickAttendanceScreenState();
}

class _QuickAttendanceScreenState extends State<QuickAttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'present', 'absent', 'excused'

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        if (state case AttendanceFailure(:final message)) {
          return Scaffold(
            backgroundColor: AppColors.canvas,
            body: Center(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.unexcused,
                ),
              ),
            ),
          );
        }

        if (state is! AttendanceReady) {
          return const Scaffold(
            backgroundColor: AppColors.canvas,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = state.session;
        final filteredItems = _filterPlayers(session.items);
        final isMaster = AppRoleScope.isMaster(context);

        final scaffold = Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: _buildAppBar(context),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 10),
                    if (session.isLocked) ...[
                      if (isMaster)
                        _buildAdminEditBanner()
                      else
                        const LockedSessionBanner(),
                      const SizedBox(height: 12),
                    ],

                    // الشريط الميداني لاختيار الفئة وحالة الحافظة (Interactive Squad Bar)
                    _buildSquadBar(session, isMaster),
                    const SizedBox(height: 12),

                    // حقل البحث السريع
                    _buildSearchBar(),
                    const SizedBox(height: 12),

                    // فلاتر التصفية السريعة
                    _buildFilterPills(session),
                    const SizedBox(height: 12),

                    // زر التسريع الميداني بلمسة واحدة
                    OneTouchPresentButton(
                      playerCount: session.items.length,
                      onPressed: (!session.isLocked || isMaster)
                          ? () => context.read<AttendanceBloc>().add(
                              MarkAllPresentEvent(allowAdminOverride: isMaster),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // إحصائيات التعداد اللحظي
                    _buildRealtimeStatsBar(session),
                    const SizedBox(height: 14),

                    // قائمة كشف اللاعبين
                    if (filteredItems.isEmpty)
                      _buildEmptyState()
                    else
                      ...filteredItems.map(
                        (item) => AttendancePlayerCard(
                          item: item,
                          enabled: !session.isLocked || isMaster,
                          onTap: () => context.read<AttendanceBloc>().add(
                            UpdatePlayerStatusEvent(
                              item.playerId,
                              allowAdminOverride: isMaster,
                            ),
                          ),
                          onStatusSelected: (status) =>
                              context.read<AttendanceBloc>().add(
                                SetPlayerAttendanceStatusEvent(
                                  playerId: item.playerId,
                                  status: status,
                                  allowAdminOverride: isMaster,
                                ),
                              ),
                        ),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
              // الشريط السفلي العريض للإنهاء والحفظ التلقائي
              _buildStickyActionBar(session),
            ],
          ),
          bottomNavigationBar: widget.showBottomNav
              ? _buildBottomNavigationBar(context)
              : null,
        );

        final activeCubit = _tryGetActiveTeamCubit(context);
        if (activeCubit != null) {
          return BlocListener<ActiveTeamCubit, ActiveTeamState>(
            bloc: activeCubit,
            listener: (context, activeState) {
              if (session.teamId != activeState.teamId && !session.isLocked) {
                context.read<AttendanceBloc>().add(
                      StartTodaySessionEvent(activeState.teamId),
                    );
              }
            },
            child: scaffold,
          );
        }
        return scaffold;
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.royalBlue,
      titleSpacing: 12,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          if (widget.onBack != null || Navigator.of(context).canPop()) ...[
            IconButton(
              icon: const Icon(
                LucideIcons.arrowRight,
                color: Colors.white,
              ),
              tooltip: 'الرجوع',
              onPressed: widget.onBack ?? () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 4),
          ],
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
                  'تحضير تمرين اليوم',
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
            color: Colors.white,
            size: 20,
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
            child: const Icon(
              LucideIcons.user,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminEditBanner() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
        width: 1.2,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x18000000),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
            ),
          ),
          child: const Icon(LucideIcons.crown, size: 18, color: Color(0xFFFBBF24)),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'كشف مرحّل - صلاحية التعديل الإداري (الإدارة العامة)',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(LucideIcons.badgeCheck, size: 14, color: Color(0xFF38BDF8)),
                ],
              ),
              SizedBox(height: 1),
              Text(
                'بصفتك إدارة النادي، يمكنك تعديل حالات الحضور الميدانية واعتمادها رسمياً.',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.5,
                  color: Color(0xFFBFDBFE),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF34D399), width: 0.8),
          ),
          child: const Text(
            'تعديل متاح',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFFA7F3D0),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildSquadBar(AttendanceSession session, bool isMaster) {
    final currentSquadName = switch (session.teamId) {
      'team-first' => 'الفريق الأول',
      'team-youth' => 'فريق الشباب U-19',
      'team-junior' => 'فريق الناشئين U-17',
      _ => 'الفريق الأول',
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Squad Switcher Dropdown (Interactive)
        Flexible(
          child: InkWell(
            onTap: (session.isLocked && !isMaster)
                ? null
                : () => _showSquadSelectorSheet(context, session),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: session.isLocked && !isMaster
                          ? AppColors.session
                          : AppColors.present,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      currentSquadName,
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.sessionBackground,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${session.totalCount} لاعب',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.royalBlue,
                      ),
                    ),
                  ),
                  if (!session.isLocked || isMaster) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.chevronDown,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Session Status Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: session.isLocked
                ? (isMaster
                    ? const Color(0xFFEFF6FF)
                    : AppColors.sessionBackground)
                : AppColors.presentBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: session.isLocked
                  ? (isMaster ? const Color(0xFF93C5FD) : Colors.transparent)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                session.isLocked
                    ? (isMaster ? LucideIcons.shieldCheck : LucideIcons.lock)
                    : LucideIcons.radio,
                size: 14,
                color: session.isLocked
                    ? (isMaster ? const Color(0xFF1D4ED8) : AppColors.session)
                    : AppColors.present,
              ),
              const SizedBox(width: 6),
              Text(
                session.isLocked
                    ? (isMaster
                        ? 'مرحّل (متاح التعديل الإداري)'
                        : 'مقفل إدارياً')
                    : 'حافظة مفتوحة للرصد',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: session.isLocked
                      ? (isMaster ? const Color(0xFF1E40AF) : AppColors.session)
                      : AppColors.present,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
        onChanged: (val) => setState(() => _searchQuery = val.trim()),
        decoration: InputDecoration(
          hintText: 'ابحث باسم اللاعب أو رقمه...',
          hintStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            LucideIcons.search,
            size: 18,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(LucideIcons.x, size: 16),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildFilterPills(AttendanceSession session) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            title: 'الكل (${session.items.length})',
            filterKey: 'all',
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            title: 'الحاضرون (${session.presentCount})',
            filterKey: 'present',
            dotColor: AppColors.present,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            title: 'الغائبون (${session.unexcusedCount})',
            filterKey: 'absent',
            dotColor: AppColors.unexcused,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            title: 'المعذورون (${session.excusedCount})',
            filterKey: 'excused',
            dotColor: AppColors.excused,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String title,
    required String filterKey,
    Color? dotColor,
  }) {
    final isSelected = _selectedFilter == filterKey;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = filterKey);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.royalBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.royalBlue : AppColors.borderSubtle,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x1A0E4B94),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (dotColor != null) ...[
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.white : dotColor,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealtimeStatsBar(AttendanceSession session) {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            count: session.presentCount,
            label: 'حاضر للمران',
            color: AppColors.present,
            bgColor: AppColors.presentBackground,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatBox(
            count: session.excusedCount,
            label: 'بعذر معتمد',
            color: AppColors.excused,
            bgColor: AppColors.excusedBackground,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatBox(
            count: session.unexcusedCount,
            label: 'غياب بدون عذر',
            color: AppColors.unexcused,
            bgColor: AppColors.unexcusedBackground,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required int count,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyActionBar(AttendanceSession session) {
    final isMaster = AppRoleScope.isMaster(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
        boxShadow: [
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'تم رصد ${session.recordedCount} من ${session.totalCount} لاعب',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      LucideIcons.check,
                      size: 15,
                      color: AppColors.present,
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      'حفظ تلقائي للميدان',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      LucideIcons.cloud,
                      size: 14,
                      color: AppColors.present,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.royalBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (!session.isLocked && session.unmarkedCount > 0) {
                    _showUnmarkedPlayersWarning(context, session);
                    return;
                  }
                  widget.onReview();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      session.isLocked
                          ? (isMaster
                              ? 'مراجعة واعتماد التعديلات الإدارية'
                              : 'مراجعة كشف التمرين المقفل إدارياً')
                          : 'إنهاء ومراجعة الكشف',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      session.isLocked
                          ? LucideIcons.fileSearch
                          : LucideIcons.arrowLeft,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnmarkedPlayersWarning(
    BuildContext context,
    AttendanceSession session,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(LucideIcons.alertTriangle, color: Color(0xFFD97706), size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'الرصد الميداني غير مكتمل',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'لا يمكن إنهاء أو ترحيل الكشف قبل رصد جميع اللاعبين.\n\nتبقّى لديك ${session.unmarkedCount} من أصل ${session.totalCount} لاعباً لم يتم تحديد حالتهم (حاضر، غائب، أو بعذر).',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            height: 1.5,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.royalBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'إكمال رصد الحضور',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSquadSelectorSheet(
    BuildContext context,
    AttendanceSession session,
  ) {
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
                  'اختيار كشف الفئة للتحضير',
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
              currentTeamId: session.teamId,
              title: 'الفريق الأول',
              subtitle: 'الفئة الأساسية المعتمدة للموسم',
            ),
            _buildSquadOption(
              ctx,
              id: 'team-youth',
              currentTeamId: session.teamId,
              title: 'فريق الشباب (تحت 19)',
              subtitle: 'فئة الشباب لدوري المحافظة',
            ),
            _buildSquadOption(
              ctx,
              id: 'team-junior',
              currentTeamId: session.teamId,
              title: 'فريق الناشئين (تحت 17)',
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
    required String currentTeamId,
    required String title,
    required String subtitle,
  }) {
    final isSelected = currentTeamId == id;
    return InkWell(
      onTap: () {
        Navigator.of(ctx).pop();
        if (id != currentTeamId) {
          final cubit = _tryGetActiveTeamCubit(context);
          cubit?.selectById(id);
          context.read<AttendanceBloc>().add(StartTodaySessionEvent(id));
        }
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
            if (isSelected)
              const Icon(
                LucideIcons.check,
                color: AppColors.royalBlue,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

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
                const Text(
                  'التنبيهات الميدانية للتحضير',
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
                          'الحفظ الميداني التلقائي نشط',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.present,
                          ),
                        ),
                        Text(
                          'تُحفظ كافة حالات الحضور والغياب لحظياً في قاعدة بيانات الجهاز دون حاجة لشبكة.',
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
                    LucideIcons.lock,
                    color: AppColors.session,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ثابت القفل الصارم غير القابل للرجعة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.session,
                          ),
                        ),
                        Text(
                          'بمجرد ترحيل التمرين يتحول لوضع القراءة فقط لمنع أي تعديل لاحق وفق ميثاق النادي.',
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
                onPressed: () => Navigator.of(ctx).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(LucideIcons.check, size: 18),
                label: const Text(
                  'إغلاق الملف الإداري',
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

  Widget _buildBottomNavigationBar(BuildContext context) {
    return NavigationBar(
      selectedIndex: 1, // 'التحضير'
      onDestinationSelected: (index) {
        if (index == 0) {
          if (widget.onBack != null) {
            widget.onBack!();
          } else {
            Navigator.of(context).maybePop();
          }
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(LucideIcons.home, size: 22),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.clipboardCheck, size: 22),
          label: 'التحضير',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.users, size: 22),
          label: 'اللاعبون',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.clipboardList, size: 22),
          label: 'التقارير',
        ),
        NavigationDestination(
          icon: Icon(LucideIcons.settings, size: 22),
          label: 'الإعدادات',
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      alignment: Alignment.center,
      child: const Column(
        children: [
          Icon(LucideIcons.searchX, size: 40, color: AppColors.textSecondary),
          SizedBox(height: 8),
          Text(
            'لا يوجد لاعبون مطابقون للبحث أو الفلتر',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<PlayerAttendanceItem> _filterPlayers(List<PlayerAttendanceItem> items) {
    return items.where((item) {
      // 1. Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesName = item.playerName.contains(_searchQuery);
        final matchesNum = item.jerseyNumber != null &&
            item.jerseyNumber.toString().contains(_searchQuery);
        if (!matchesName && !matchesNum) return false;
      }
      // 2. Chip filter
      return switch (_selectedFilter) {
        'present' => item.status == PlayerAttendanceStatus.present,
        'absent' => item.status == PlayerAttendanceStatus.unexcused,
        'excused' => item.status == PlayerAttendanceStatus.excused,
        _ => true,
      };
    }).toList();
  }
}
