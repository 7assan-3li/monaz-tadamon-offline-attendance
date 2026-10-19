import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/confirmation_dialog.dart';
import 'package:tadamon_attendance_app/core/di/service_locator.dart';
import 'package:tadamon_attendance_app/features/teams/presentation/bloc/active_team_cubit.dart';
import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_bloc.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_event.dart';
import 'package:tadamon_attendance_app/features/players/presentation/bloc/players_state.dart';
import 'package:tadamon_attendance_app/features/players/presentation/widgets/add_edit_player_modal.dart';
import 'package:tadamon_attendance_app/features/players/presentation/widgets/player_card.dart';

class PlayersListScreen extends StatefulWidget {
  const PlayersListScreen({super.key});

  @override
  State<PlayersListScreen> createState() => _PlayersListScreenState();
}

class _PlayersListScreenState extends State<PlayersListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTeamFilter = 'team-first'; // team-first, team-youth, team-junior, all
  String _selectedPositionFilter = 'all'; // all, gk, def, mid, fwd

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
      _selectedTeamFilter = activeCubit.state.teamId;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: _buildAppBar(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        backgroundColor: AppColors.royalBlue,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(LucideIcons.userPlus, size: 18),
        label: const Text(
          'إضافة لاعب',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocBuilder<PlayersBloc, PlayersState>(
        builder: (context, state) => switch (state) {
          PlayersInitial() || PlayersLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.royalBlue),
            ),
          PlayersFailure(:final message) => Center(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.unexcused,
                ),
              ),
            ),
          PlayersReady(:final players) => _buildRosterBody(context, players),
        },
      ),
    );

    final activeCubit = _tryGetActiveTeamCubit(context);
    if (activeCubit != null) {
      content = BlocListener<ActiveTeamCubit, ActiveTeamState>(
        bloc: activeCubit,
        listener: (context, state) {
          if (_selectedTeamFilter != state.teamId) {
            setState(() => _selectedTeamFilter = state.teamId);
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
      titleSpacing: 16,
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
          IconButton(
            onPressed: () => _showNotificationsSheet(context),
            icon: const Icon(
              LucideIcons.bell,
              color: Colors.white,
              size: 20,
            ),
            tooltip: 'التنبيهات الميدانية',
          ),
          GestureDetector(
            onTap: () => _showProfileSheet(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: const Icon(LucideIcons.user, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRosterBody(BuildContext context, List<ClubPlayer> allPlayers) {
    // 1. Team filtering
    final teamPlayers = _selectedTeamFilter == 'all'
        ? allPlayers
        : allPlayers.where((p) => p.teamId == _selectedTeamFilter).toList();

    // 2. Position counts for selected squad
    final gkCount =
        teamPlayers.where((p) => p.position?.contains('حارس') == true).length;
    final defCount = teamPlayers
        .where((p) =>
            p.position?.contains('دفاع') == true ||
            p.position?.contains('ظهير') == true)
        .length;
    final midCount = teamPlayers
        .where((p) =>
            p.position?.contains('وسط') == true ||
            p.position?.contains('محور') == true ||
            p.position?.contains('صانع') == true)
        .length;
    final fwdCount = teamPlayers
        .where((p) =>
            p.position?.contains('مهاجم') == true ||
            p.position?.contains('جناح') == true ||
            p.position?.contains('حربة') == true)
        .length;

    // 3. Position filtering
    final filteredPlayers = teamPlayers.where((player) {
      if (_selectedPositionFilter != 'all') {
        final pos = player.position ?? '';
        if (_selectedPositionFilter == 'gk' && !pos.contains('حارس')) {
          return false;
        }
        if (_selectedPositionFilter == 'def' &&
            !pos.contains('دفاع') &&
            !pos.contains('ظهير')) {
          return false;
        }
        if (_selectedPositionFilter == 'mid' &&
            !pos.contains('وسط') &&
            !pos.contains('محور') &&
            !pos.contains('صانع')) {
          return false;
        }
        if (_selectedPositionFilter == 'fwd' &&
            !pos.contains('مهاجم') &&
            !pos.contains('جناح') &&
            !pos.contains('حربة')) {
          return false;
        }
      }
      return true;
    }).toList();

    final currentSquadName = switch (_selectedTeamFilter) {
      'team-first' => 'الفريق الأول',
      'team-youth' => 'فريق الشباب U-19',
      'team-junior' => 'فريق الناشئين U-17',
      _ => 'جميع الفئات',
    };

    return Column(
      children: [
        // Squad selector & Readiness Header Area
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Squad Switcher Dropdown Button (Interactive)
                  InkWell(
                    onTap: () => _showSquadSelectorSheet(context, allPlayers),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
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
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.present,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            currentSquadName,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.sessionBackground,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${teamPlayers.length} لاعب',
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.royalBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            LucideIcons.chevronDown,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showDisciplineInfoSheet(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.presentBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            LucideIcons.badgeCheck,
                            size: 14,
                            color: AppColors.present,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'الانضباط: 92.4%',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.present,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Search Input
              TextField(
                controller: _searchController,
                onChanged: (query) => context
                    .read<PlayersBloc>()
                    .add(PlayersRequested(query: query)),
                decoration: InputDecoration(
                  hintText: 'ابحث عن لاعب بالاسم، الرقم، أو المركز...',
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
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(LucideIcons.x, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            context
                                .read<PlayersBloc>()
                                .add(const PlayersRequested());
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.borderSubtle),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.royalBlue),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'الكل', teamPlayers.length),
                    const SizedBox(width: 8),
                    _buildFilterChip('gk', 'حراس المرمى', gkCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('def', 'الدفاع', defCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('mid', 'الوسط', midCount),
                    const SizedBox(width: 8),
                    _buildFilterChip('fwd', 'الهجوم', fwdCount),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Players List
        Expanded(
          child: allPlayers.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.royalBlue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.users,
                            size: 36,
                            color: AppColors.royalBlue,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'كشف اللاعبين فارغ وجاهز للتسجيل',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'النظام في حالة جديدة تماماً. ابدأ بإضافة لاعبي النادي لتشكيل القوائم واعتماد التحضير الميداني.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        FilledButton.icon(
                          onPressed: () => _edit(context),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.royalBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(LucideIcons.userPlus, size: 18),
                          label: const Text(
                            'إضافة أول لاعب إلى الكشف',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : filteredPlayers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.users,
                            size: 44,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'لا يوجد لاعبون مطابقون للبحث أو الفلتر.',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedTeamFilter = 'team-first';
                                _selectedPositionFilter = 'all';
                                _searchController.clear();
                              });
                              context
                                  .read<PlayersBloc>()
                                  .add(const PlayersRequested());
                            },
                            icon: const Icon(LucideIcons.rotateCcw, size: 16),
                            label: const Text(
                              'إعادة ضبط الفلاتر',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: filteredPlayers.length,
                  itemBuilder: (_, index) {
                    final player = filteredPlayers[index];
                    return PlayerCard(
                      player: player,
                      onTap: () => _showPlayerDetailsSheet(context, player),
                      onEdit: () => _edit(context, player: player),
                      onArchive: () => _archive(context, player),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String key, String title, int count) {
    final isSelected = _selectedPositionFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedPositionFilter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.royalBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.royalBlue : AppColors.borderSubtle,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.royalBlue.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSquadSelectorSheet(
    BuildContext context,
    List<ClubPlayer> allPlayers,
  ) {
    final firstCount =
        allPlayers.where((p) => p.teamId == 'team-first').length;
    final youthCount =
        allPlayers.where((p) => p.teamId == 'team-youth').length;
    final juniorCount =
        allPlayers.where((p) => p.teamId == 'team-junior').length;

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
            _buildSquadSelectorOption(
              ctx,
              id: 'team-first',
              title: 'الفريق الأول',
              count: firstCount,
              subtitle: 'الفئة الأساسية المعتمدة للموسم',
            ),
            _buildSquadSelectorOption(
              ctx,
              id: 'team-youth',
              title: 'فريق الشباب (تحت 19)',
              count: youthCount,
              subtitle: 'فئة الشباب لدوري المحافظة',
            ),
            _buildSquadSelectorOption(
              ctx,
              id: 'team-junior',
              title: 'فريق الناشئين (تحت 17)',
              count: juniorCount,
              subtitle: 'الفئة العمرية الصغرى',
            ),
            _buildSquadSelectorOption(
              ctx,
              id: 'all',
              title: 'جميع الفئات واللاعبين',
              count: allPlayers.length,
              subtitle: 'عرض كافة كشوفات النادي الرياضية',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquadSelectorOption(
    BuildContext ctx, {
    required String id,
    required String title,
    required int count,
    required String subtitle,
  }) {
    final isSelected = _selectedTeamFilter == id;
    return InkWell(
      onTap: () {
        setState(() => _selectedTeamFilter = id);
        Navigator.of(ctx).pop();
        if (id != 'all') {
          final cubit = _tryGetActiveTeamCubit(context);
          cubit?.selectById(id);
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.royalBlue
                    : AppColors.sessionBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count لاعب',
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
                          'كشف التشكيلة الميدانية جاهز',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.present,
                          ),
                        ),
                        Text(
                          'تم تدقيق سجلات اللاعبين وتحديث جاهزيتهم للمران الميداني دون إنترنت.',
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
                color: AppColors.excusedBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(
                    LucideIcons.cross,
                    color: AppColors.excused,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'متابعة الجاهزية الطبية والاستشفاء',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.excused,
                          ),
                        ),
                        Text(
                          'يخضع اللاعبون المصابون لبرامج تأهيل معتمدة من الجهاز الطبي بالنادي.',
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
                          'حماية بيانات الكشوفات',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.session,
                          ),
                        ),
                        Text(
                          'تشفير Ed25519 نشط لمنع أي تعديل خارجي على السجلات التاريخية.',
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

  void _showDisciplineInfoSheet(BuildContext context) {
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
                  'مؤشر الانضباط الرياضي',
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
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.presentBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    LucideIcons.badgeCheck,
                    size: 28,
                    color: AppColors.present,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'معدل الحضور العام: 92.4%',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.present,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'مؤشر رياضي وانضباطي بحت يقيس التزام اللاعبين بتمارين النادي دون أي احتساب مالي أو غرامات وفق ميثاق تضامن حضرموت.',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.4,
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
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.royalBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'تم والعودة للكشف',
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

  void _showPlayerDetailsSheet(BuildContext context, ClubPlayer player) {
    final jerseyNumber = player.jerseyNumber?.toString() ?? '—';
    final teamName = switch (player.teamId) {
      'team-first' => 'الفريق الأول',
      'team-youth' => 'فريق الشباب (U-19)',
      'team-junior' => 'فريق الناشئين (U-17)',
      _ => 'الفريق الأول',
    };
    final isMedical = player.notes?.contains('إصابة') == true ||
        player.notes?.contains('استشفاء') == true ||
        player.notes?.contains('إجهاد') == true;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
                  'بطاقة اللاعب الميدانية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Header Info
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.royalBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'رقم',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFBACBF5),
                          height: 1,
                        ),
                      ),
                      Text(
                        jerseyNumber,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.royalBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              teamName,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.royalBlue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            player.position ?? 'لاعب ميداني',
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
            const SizedBox(height: 16),
            // Details Rows
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: LucideIcons.calendar,
                    label: 'تاريخ الانضمام للكشف',
                    value:
                        '${player.joinDate.day}/${player.joinDate.month}/${player.joinDate.year}',
                  ),
                  const Divider(height: 16),
                  _buildDetailRow(
                    icon: isMedical
                        ? LucideIcons.circleAlert
                        : LucideIcons.checkCircle,
                    label: 'الحالة البدنية والطبية',
                    value: player.notes?.isNotEmpty == true
                        ? player.notes!
                        : 'جاهز بالعتاد للمران',
                    valueColor:
                        isMedical ? AppColors.excused : AppColors.present,
                  ),
                  const Divider(height: 16),
                  _buildDetailRow(
                    icon: LucideIcons.trophy,
                    label: 'الاستحقاق الرياضي',
                    value: 'مؤهل للمشاركة الرسمية (حضور 95%)',
                    valueColor: AppColors.present,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _edit(context, player: player);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.royalBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(LucideIcons.pencil, size: 16),
                    label: const Text(
                      'تعديل البيانات',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _archive(context, player);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.unexcused,
                      side: const BorderSide(color: AppColors.unexcused),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(LucideIcons.archive, size: 16),
                    label: const Text(
                      'أرشفة السجل',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _archive(BuildContext context, ClubPlayer player) async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'أرشفة اللاعب؟',
      message: 'لن يُحذف سجل اللاعب التاريخي وستبقى بيانات حضوره محفوظة.',
      confirmLabel: 'أرشفة',
    );
    if (confirmed && context.mounted) {
      context.read<PlayersBloc>().add(PlayerArchived(player.id));
    }
  }

  Future<void> _edit(BuildContext context, {ClubPlayer? player}) async {
    final defaultTeam =
        _selectedTeamFilter != 'all' ? _selectedTeamFilter : 'team-first';
    final state = context.read<PlayersBloc>().state;
    final allPlayers = state is PlayersReady ? state.players : <ClubPlayer>[];
    final result = await showAddEditPlayerModal(
      context,
      player: player,
      defaultTeamId: defaultTeam,
      existingPlayers: allPlayers,
    );
    if (result == null || !context.mounted) return;
    context.read<PlayersBloc>().add(
          player == null ? PlayerAdded(result) : PlayerUpdated(result),
        );
  }
}
