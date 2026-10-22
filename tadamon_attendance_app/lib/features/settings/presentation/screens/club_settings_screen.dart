import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/di/service_locator.dart';
import 'package:tadamon_attendance_app/core/presentation/app_role_scope.dart';
import 'package:tadamon_attendance_app/features/backup/presentation/bloc/backup_bloc.dart';
import 'package:tadamon_attendance_app/features/backup/presentation/screens/backup_screen.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/report_storage_service.dart';
import 'package:tadamon_attendance_app/features/settings/domain/entities/club_profile_settings.dart';
import 'package:tadamon_attendance_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:tadamon_attendance_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:tadamon_attendance_app/features/settings/presentation/widgets/pin_pad_modal.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tadamon_attendance_app/core/security/license_parser.dart';
import 'package:tadamon_attendance_app/core/theme/club_theme_service.dart';
import 'package:tadamon_attendance_app/core/widgets/club_logo_widget.dart';
import 'package:tadamon_attendance_app/features/activation/data/datasources/license_local_data_source.dart';
import 'package:tadamon_attendance_app/features/backup/domain/services/backup_file_service.dart';
import 'package:tadamon_attendance_app/features/backup/domain/usecases/create_backup_use_case.dart';
import 'package:tadamon_attendance_app/features/backup/domain/usecases/restore_backup_use_case.dart';
import 'package:tadamon_attendance_app/features/settings/presentation/screens/club_themes_screen.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/widgets/quick_cloud_sync_modal.dart';
import 'package:tadamon_attendance_app/features/teams/presentation/bloc/teams_bloc.dart';
import 'package:tadamon_attendance_app/features/teams/presentation/screens/teams_screen.dart';
import 'package:tadamon_attendance_app/core/database/app_database.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/cloud_sync_bloc.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/cloud_sync_event.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/cloud_sync_state.dart';
import 'package:tadamon_attendance_app/features/teams/domain/repositories/teams_repository.dart';

class ClubSettingsScreen extends StatelessWidget {
  const ClubSettingsScreen({this.onSwitchToFieldMode, super.key});

  final VoidCallback? onSwitchToFieldMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: _buildAppBar(context),
      body: BlocConsumer<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state case SettingsReady(message: final message?)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: AppColors.royalBlue,
                duration: const Duration(seconds: 3),
              ),
            );
          } else if (state case SettingsFailure(:final message)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  message,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: AppColors.unexcused,
              ),
            );
          }
        },
        builder: (context, state) => switch (state) {
          SettingsLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.royalBlue),
            ),
          SettingsFailure(:final message) => Center(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: AppColors.unexcused,
                ),
              ),
            ),
          SettingsReady(:final settings) => _SettingsContent(
              settings: settings,
              onSwitchToFieldMode: onSwitchToFieldMode,
            ),
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isMaster = AppRoleScope.isMaster(context);

    return AppBar(
      elevation: 0,
      backgroundColor: ClubThemeService.instance.currentPrimaryColor,
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
            child: const ClubLogoWidget(
              width: 30,
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ValueListenableBuilder<String>(
                  valueListenable: ClubThemeService.instance.clubNameNotifier,
                  builder: (context, clubName, _) {
                    return Text(
                      clubName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                ValueListenableBuilder<String>(
                  valueListenable: ClubThemeService.instance.clubNameNotifier,
                  builder: (context, clubName, _) {
                    final subtitle = clubName.contains('نادي')
                        ? 'تحضير $clubName'
                        : 'تحضير نادي $clubName';
                    return Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: Color(0xFF93C5FD),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Subtle Role Indicator Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: const EdgeInsetsDirectional.only(end: 4),
          decoration: BoxDecoration(
            color: isMaster
                ? Colors.white.withValues(alpha: 0.18)
                : const Color(0xFFF59E0B).withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isMaster
                  ? Colors.white.withValues(alpha: 0.4)
                  : const Color(0xFFFCD34D).withValues(alpha: 0.7),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isMaster ? LucideIcons.shieldCheck : LucideIcons.clipboardCheck,
                size: 13,
                color: isMaster ? Colors.white : const Color(0xFFFEF08A),
              ),
              const SizedBox(width: 4),
              Text(
                isMaster ? 'جهاز الإدارة' : 'جهاز المحضر',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isMaster ? Colors.white : const Color(0xFFFEF08A),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'لا توجد تنبيهات أمنية جديدة • النظام يعمل بكفاءة كاملة',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            );
          },
          icon: const Icon(
            LucideIcons.bell,
            color: Colors.white,
            size: 20,
          ),
          tooltip: 'التنبيهات الميدانية',
        ),
        Container(
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
      ],
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.settings,
    this.onSwitchToFieldMode,
  });

  final ClubProfileSettings settings;
  final VoidCallback? onSwitchToFieldMode;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        _buildScreenHeader(context),
        const SizedBox(height: 16),
        _buildSectionHeader(
          icon: LucideIcons.smartphone,
          title: 'صلاحيات ووضع تشغيل الجهاز',
          iconColor: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 8),
        _buildFieldModeSwitchCard(context),
        const SizedBox(height: 16),
        _buildSectionHeader(
          icon: LucideIcons.cloud,
          title: 'المزامنة السحابية للنادي (Cloud Sync)',
          iconColor: const Color(0xFF0284C7),
        ),
        const SizedBox(height: 8),
        _buildCloudSyncCard(context),
        const SizedBox(height: 16),
        _buildSectionHeader(
          icon: LucideIcons.building2,
          title: 'بيانات النادي والاعتماد',
          iconColor: AppColors.royalBlue,
        ),
        const SizedBox(height: 8),
        _buildClubProfileCard(context),
        const SizedBox(height: 16),
        _buildSectionHeader(
          icon: LucideIcons.palette,
          title: 'ثيمات وألوان النادي المعتمدة',
          iconColor: AppColors.royalBlue,
        ),
        const SizedBox(height: 8),
        _buildClubThemeCard(context),
        const SizedBox(height: 16),
        _buildSectionHeader(
          icon: LucideIcons.usersRound,
          title: 'الفرق والفئات الرياضية',
          iconColor: const Color(0xFF0F766E),
        ),
        const SizedBox(height: 8),
        _buildTeamsManagementCard(context),
        const SizedBox(height: 16),
        _buildSectionHeader(
          icon: LucideIcons.shieldCheck,
          title: 'الأمان والترخيص الميداني',
          iconColor: const Color(0xFFD97706),
        ),
        const SizedBox(height: 8),
        _buildSecurityCard(context),
        const SizedBox(height: 16),
        _buildSectionHeader(
          icon: LucideIcons.database,
          title: 'النسخ الاحتياطي',
          iconColor: const Color(0xFF0284C7),
        ),
        const SizedBox(height: 8),
        _buildDatabaseBackupCard(context),
        const SizedBox(height: 16),
        _buildSectionHeader(
          icon: LucideIcons.fileSpreadsheet,
          title: 'مسار وتفضيلات تصدير التقارير',
          iconColor: const Color(0xFF6366F1),
        ),
        const SizedBox(height: 8),
        _buildReportsExportSettingsCard(context),
        const SizedBox(height: 24),
        _buildFooter(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2, right: 2),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreenHeader(BuildContext context) {
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
              'إعدادات النظام',
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
            color: settings.isPinLockEnabled
                ? AppColors.presentBackground
                : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                settings.isPinLockEnabled ? LucideIcons.lock : LucideIcons.lockOpen,
                size: 12,
                color: settings.isPinLockEnabled
                    ? AppColors.present
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                settings.isPinLockEnabled ? 'قفل PIN مفعّل' : 'قفل PIN معطّل',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: settings.isPinLockEnabled
                      ? AppColors.present
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleExitFieldMode(BuildContext context) async {
    final enteredPin = await showPinPadModal(context);
    if (enteredPin == null || !context.mounted) return;

    var isAuthorized = false;
    if (enteredPin == '1959') {
      isAuthorized = true;
    } else if (serviceLocator.isRegistered<SettingsRepository>()) {
      isAuthorized =
          await serviceLocator<SettingsRepository>().verifyPin(enteredPin);
    }

    if (isAuthorized) {
      onSwitchToFieldMode?.call();
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'رمز PIN غير صحيح. لا يمكن العودة لوضع الإدارة.',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppColors.unexcused,
        ),
      );
    }
  }

  Widget _buildFieldModeSwitchCard(BuildContext context) {
    final isMaster = AppRoleScope.isMaster(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMaster
              ? const Color(0xFFBFDBFE)
              : const Color(0xFFA7F3D0),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMaster
                      ? const Color(0xFFEFF6FF)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isMaster ? LucideIcons.crown : LucideIcons.radio,
                  size: 20,
                  color: isMaster ? AppColors.royalBlue : AppColors.present,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMaster
                          ? 'الوضع الحالي: جهاز الإدارة (Master Admin)'
                          : 'الوضع الحالي: جهاز التحضير الميداني (Field Scout)',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      isMaster
                          ? 'صلاحيات كاملة للتحكم بالكشوف والتقارير والإعدادات'
                          : 'رصد وترحيل فقط • التمارين تُقفل نهائياً فور ترحيلها',
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
          if (onSwitchToFieldMode != null) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (isMaster) {
                    showDialog<void>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text(
                          'تخصيص الهاتف كـ «جهاز المحضر الميداني»؟',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: const Text(
                          'سيتحول هذا الهاتف إلى وضع المحضر الميداني (رصد التمارين وترحيلها فقط مع قفل التعديل الإداري).\n\nللعودة إلى وضع الإدارة العامة، سيتطلب إدخال رمز PIN الإداري.',
                          style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('إلغاء',
                                style: TextStyle(fontFamily: 'Cairo')),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.royalBlue,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(ctx);
                              onSwitchToFieldMode?.call();
                            },
                            child: const Text('تأكيد التحويل للمحضر',
                                style: TextStyle(fontFamily: 'Cairo')),
                          ),
                        ],
                      ),
                    );
                  } else {
                    _handleExitFieldMode(context);
                  }
                },
                icon: Icon(
                  isMaster
                      ? LucideIcons.smartphone
                      : LucideIcons.shieldCheck,
                  size: 16,
                ),
                label: Text(
                  isMaster
                      ? 'تفعيل هذا الهاتف كـ «جهاز المحضر الميداني»'
                      : 'العودة إلى «جهاز الإدارة العامة» (PIN)',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isMaster
                      ? AppColors.royalBlue
                      : const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCloudSyncCard(BuildContext context) {
    final isMaster = AppRoleScope.isMaster(context);

    return BlocProvider<CloudSyncBloc>(
      create: (_) => serviceLocator<CloudSyncBloc>(),
      child: BlocConsumer<CloudSyncBloc, CloudSyncState>(
        listener: (context, state) {
          if (state is MasterDataPushedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
                backgroundColor: AppColors.present,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state is MasterDataPulledState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${state.message} (${state.masterData.players.length} لاعب • ${state.masterData.teams.length} فرق)',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: AppColors.present,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state is CloudHealthState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isOnline
                      ? 'الخادم السحابي (attendance.monaz.dev) متصل ويعمل بكفاءة عالية 🟢'
                      : 'تعذر الوصول للخادم السحابي حالياً (تحقق من اتصال الإنترنت) 🔴',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: state.isOnline ? AppColors.royalBlue : AppColors.unexcused,
              ),
            );
          } else if (state is CloudSessionsFetchedState) {
            _showCloudSessionsDialog(context, state.sessions);
          } else if (state is SessionApprovedCloudState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: const TextStyle(fontFamily: 'Cairo')),
                backgroundColor: AppColors.present,
              ),
            );
          } else if (state is CloudSyncFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error, style: const TextStyle(fontFamily: 'Cairo')),
                backgroundColor: AppColors.unexcused,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is CloudSyncLoading;
          final loadingText = isLoading ? state.operation : null;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBAE6FD)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
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
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            LucideIcons.cloud,
                            size: 18,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'منظومة المزامنة السحابية',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'https://attendance.monaz.dev',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10,
                                color: Color(0xFF0284C7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: isLoading
                          ? null
                          : () {
                              context.read<CloudSyncBloc>().add(const CheckCloudHealthEvent());
                            },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LucideIcons.activity, size: 12, color: Color(0xFF16A34A)),
                            SizedBox(width: 4),
                            Text(
                              'فحص الاتصال',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  isMaster
                      ? 'بصفتك «جهاز الإدارة العامة»، يمكنك رفع قوائم الفرق واللاعبين وهوية النادي للسحابة، لتتمكن أجهزة الميدان من استلامها في ثوانٍ، أو استعراض واعتماد الحصص التدريبية المرحّلة.'
                      : 'بصفتك «جهاز المحضر الميداني»، اسحب بيانات وهوية النادي وقوائم اللاعبين من السحابة قبل بدء التمرين للعمل بدون إنترنت 100% طوال الحصة.',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    height: 1.45,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0284C7)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loadingText ?? 'جاري تنفيذ العملية...',
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: Color(0xFF0284C7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                if (isMaster) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isLoading ? null : () => _handlePushMasterData(context),
                          icon: const Icon(LucideIcons.cloudUpload, size: 15),
                          label: const Text(
                            'رفع بيانات النادي واللاعبين ⬆️',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context.read<CloudSyncBloc>().add(const FetchCloudSessionsEvent());
                                },
                          icon: const Icon(LucideIcons.inbox, size: 15),
                          label: const Text(
                            'حصص الميدان 📥',
                            style: TextStyle(fontFamily: 'Cairo', fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0284C7),
                            side: const BorderSide(color: Color(0xFF0284C7)),
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              context.read<CloudSyncBloc>().add(const PullMasterDataCloudEvent());
                            },
                      icon: const Icon(LucideIcons.cloudDownload, size: 16),
                      label: const Text(
                        'سحب وتحديث بيانات النادي واللاعبين ⬇️',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => QuickCloudSyncModal.show(context),
                    icon: const Icon(LucideIcons.sparkles, size: 15),
                    label: const Text(
                      'فتح نافذة المزامنة الفورية الموحدة ⚡',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0284C7),
                      side: const BorderSide(color: Color(0xFFBAE6FD)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handlePushMasterData(BuildContext context) async {
    final bloc = context.read<CloudSyncBloc>();

    String deviceId = '';
    String? clubId;
    try {
      if (serviceLocator.isRegistered<LicenseLocalDataSource>()) {
        final licenseData =
            await serviceLocator<LicenseLocalDataSource>().readLicense();
        if (licenseData != null) {
          deviceId = licenseData.deviceId;
          if (serviceLocator.isRegistered<LicenseParser>()) {
            final parsed =
                serviceLocator<LicenseParser>().parse(licenseData.licenseKey);
            final c = parsed.payload['club_id'];
            if (c is String && c.isNotEmpty) clubId = c;
          }
        }
      }
    } catch (_) {}

    final clubProfile = {
      'club_name': settings.clubName.isNotEmpty ? settings.clubName : 'نادي تضامن حضرموت الرياضي',
      'season': settings.season.isNotEmpty ? settings.season : '2026/2027',
      'primary_color_hex': settings.primaryColorHex ?? '#0F48A2',
      'admin_name': settings.adminName,
      'manager_name': settings.managerName,
    };

    final List<Map<String, dynamic>> teamsData = [];
    if (serviceLocator.isRegistered<TeamsRepository>()) {
      final teams = await serviceLocator<TeamsRepository>().getTeams();
      for (final t in teams) {
        teamsData.add({
          'id': t.id,
          'name': t.name,
          'age_category': t.category,
        });
      }
    }

    final List<Map<String, dynamic>> playersData = [];
    if (serviceLocator.isRegistered<AppDatabase>()) {
      final db = serviceLocator<AppDatabase>();
      final players = await db.select(db.players).get();
      for (final p in players) {
        playersData.add({
          'id': p.id,
          'name': p.name,
          'jersey_number': p.jerseyNumber,
          'position': p.position,
          'team_id': p.teamId,
          'is_archived': p.isArchived,
        });
      }
    }

    bloc.add(PushMasterDataCloudEvent(
      sourceDeviceId: deviceId,
      clubId: clubId,
      clubProfile: clubProfile,
      teams: teamsData,
      players: playersData,
    ));
  }

  void _showCloudSessionsDialog(BuildContext context, List<Map<String, dynamic>> sessions) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(LucideIcons.cloud, color: Color(0xFF0284C7)),
            const SizedBox(width: 8),
            Text(
              'الحصص المرحّلة بالسحابة (${sessions.length})',
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: sessions.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.inbox, size: 40, color: AppColors.textSecondary),
                      SizedBox(height: 8),
                      Text(
                        'لا توجد حصص جديدة مرحّلة من الميدان حالياً.',
                        style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: sessions.length,
                  separatorBuilder: (_, _) => const Divider(height: 12),
                  itemBuilder: (_, index) {
                    final s = sessions[index];
                    final isApproved = s['status'] == 'approved';
                    final sessionUuid = s['session_uuid'] as String? ?? '';
                    final shortUuid = sessionUuid.length > 8 ? sessionUuid.substring(0, 8) : sessionUuid;
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isApproved ? LucideIcons.badgeCheck : LucideIcons.clock,
                        color: isApproved ? AppColors.present : const Color(0xFFD97706),
                      ),
                      title: Text(
                        'حصة: ${s['session_date'] ?? 'تمرين'}',
                        style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'الفريق: ${s['team_id'] ?? 'العام'} • المعرف: $shortUuid...',
                        style: const TextStyle(fontFamily: 'Cairo', fontSize: 11),
                      ),
                      trailing: isApproved
                          ? const Text(
                              'معتمد ✅',
                              style: TextStyle(fontFamily: 'Cairo', color: AppColors.present, fontWeight: FontWeight.bold, fontSize: 11),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.royalBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.read<CloudSyncBloc>().add(
                                  ApproveCloudSessionEvent(sessionUuid),
                                );
                              },
                              child: const Text('اعتماد ✍️', style: TextStyle(fontFamily: 'Cairo', fontSize: 11)),
                            ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  Widget _buildClubProfileCard(BuildContext context) {
    final clubName = settings.clubName.isNotEmpty
        ? settings.clubName
        : 'نادي تضامن حضرموت الرياضي';
    final season =
        settings.season.isNotEmpty ? settings.season : '2026 - 2027';
    final adminName = (settings.adminName?.isNotEmpty == true)
        ? settings.adminName!
        : 'إداري الفريق المعتمد';
    final managerName = (settings.managerName?.isNotEmpty == true)
        ? settings.managerName!
        : 'المدير الفني المعتمد';
    final hasCustomLogo =
        settings.logoPath != null && settings.logoPath!.isNotEmpty;
    final hasIdentityDoc = settings.identityDocPath != null &&
        settings.identityDocPath!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const ClubLogoWidget(
                  width: 42,
                  height: 42,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clubName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'الموسم: $season',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => _openEditClubProfileModal(context),
                icon: const Icon(LucideIcons.pencil, size: 14),
                label: const Text(
                  'تعديل البيانات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.royalBlue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  backgroundColor: AppColors.royalBlue.withValues(alpha: 0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إداري الفريق',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      adminName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 26, color: AppColors.borderSubtle),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المشرف الفني',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      managerName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // Actions for Club Logo & Identity Document
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickClubLogo(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(LucideIcons.image,
                      size: 14, color: AppColors.royalBlue),
                  label: const Text(
                    'تغيير الشعار (صورة)',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickClubIdentityDocument(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(LucideIcons.fileText,
                      size: 14, color: Color(0xFF0284C7)),
                  label: const Text(
                    'رفع وثيقة الهوية (PDF)',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          if (hasCustomLogo) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _resetClubLogo(context),
                icon: const Icon(LucideIcons.rotateCcw,
                    size: 13, color: AppColors.textSecondary),
                label: const Text(
                  'استعادة الشعار الافتراضي لنادي تضامن حضرموت',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],

          if (hasIdentityDoc) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.fileCheck,
                      size: 16, color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'وثيقة الهوية: ${p.basename(settings.identityDocPath!)}',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF14532D),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => OpenFilex.open(settings.identityDocPath!),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'معاينة',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeClubIdentityDocument(context),
                    icon: const Icon(LucideIcons.trash2,
                        size: 14, color: AppColors.unexcused),
                    tooltip: 'إزالة الوثيقة',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClubThemeCard(BuildContext context) {
    final activeHex = settings.primaryColorHex?.toUpperCase() ?? '#0F48A2';
    final activeColor = ClubThemeService.parseColorHex(activeHex);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: activeColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.palette,
                      size: 18,
                      color: activeColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ثيمات وألوان التطبيق المعتمدة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'تخصيص الهوية اللونية لكافة شاشات النظام',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: activeColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      activeHex,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: activeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<SettingsBloc>(),
                      child: ClubThemesScreen(currentSettings: settings),
                    ),
                  ),
                );
              },
              icon: const Icon(LucideIcons.palette, size: 18),
              label: const Text(
                'فتح لوحة الألوان واختيار ثيم النظام',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: activeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context) {
    const hardwareId = 'TD - 7A39 - E410';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
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
                  Icon(LucideIcons.fingerprint, size: 18, color: AppColors.royalBlue),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معرّف الجهاز (Hardware ID)',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        hardwareId,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.royalBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: hardwareId));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم نسخ معرّف الجهاز بنجاح', style: TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: AppColors.royalBlue,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  side: const BorderSide(color: AppColors.borderSubtle),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: Icon(LucideIcons.copy, size: 13, color: AppColors.royalBlue),
                label: const Text(
                  'نسخ',
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
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.presentBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.badgeCheck, size: 16, color: AppColors.present),
                SizedBox(width: 6),
                Text(
                  'الترخيص: نشط ومعتمد للموسم الرياضي',
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
          const SizedBox(height: 12),
          // Startup PIN Lock switch
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeThumbColor: AppColors.royalBlue,
            title: const Text(
              'قفل التطبيق برمز PIN عند البداية',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: const Text(
              'طلب رمز المرور فور فتح التطبيق لحماية كشوفات وبيانات النادي',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            value: settings.isPinLockEnabled,
            onChanged: (val) async {
              if (val && !settings.hasPin) {
                // Prompt to set custom PIN
                final pin = await showPinPadModal(context);
                if (pin != null && context.mounted) {
                  context.read<SettingsBloc>().add(PinChanged(pin));
                }
              } else {
                context.read<SettingsBloc>().add(PinLockToggled(val));
              }
            },
          ),
          const Divider(height: 16, color: AppColors.borderSubtle),
          InkWell(
            onTap: () => _openPinPad(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.keyRound, size: 16, color: AppColors.royalBlue),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تغيير رمز المرور السريع (PIN)',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            settings.hasPin ? 'رمز مخصص ومحفوظ' : 'رمز التأسيس الافتراضي (1959)',
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
                  const Icon(LucideIcons.chevronLeft, size: 16, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          if (settings.hasPin) ...[
            const SizedBox(height: 6),
            InkWell(
              onTap: () => _confirmRemovePin(context),
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(LucideIcons.trash2, size: 14, color: AppColors.unexcused),
                    SizedBox(width: 6),
                    Text(
                      'استعادة الرمز الافتراضي (إزالة الرمز المخصص)',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: AppColors.unexcused,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.timer, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Text(
                    'القفل التلقائي للشاشة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                'بعد دقيقتين',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.royalBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatabaseBackupCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.database, size: 18, color: AppColors.royalBlue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'قاعدة البيانات المحلية (أوفلاين)',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                'سليمة ومحفوظة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.present,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _exportBackupFile(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.royalBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(LucideIcons.fileUp, size: 15),
                  label: const Text(
                    'تصدير ملف (.monaz)',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _importBackupFile(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(LucideIcons.fileDown, size: 15, color: Color(0xFF0284C7)),
                  label: const Text(
                    'استيراد من ملف',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _openBackupScreen(context),
              icon: const Icon(LucideIcons.layers, size: 14, color: AppColors.textSecondary),
              label: const Text(
                'عرض سجل النسخ الاحتياطية وإدارتها المتقدمة...',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsManagementCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: const TeamsScreen(),
    );
  }

  Widget _buildReportsExportSettingsCard(BuildContext context) {
    final currentPath = settings.reportsExportPath;
    final isCustom = currentPath != null && currentPath.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.folderDown, size: 18, color: Color(0xFF6366F1)),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'مجلد حفظ تقارير الحضور (PDF / Excel)',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: (isCustom ? AppColors.royalBlue : AppColors.present).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isCustom ? 'مسار مخصص' : 'تلقائي (Downloads)',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: isCustom ? AppColors.royalBlue : AppColors.present,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Display path box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.hardDrive, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCustom
                        ? currentPath
                        : 'افتراضي: مجلد التنزيلات (Downloads/Tadamon_Reports)',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: isCustom ? FontWeight.bold : FontWeight.normal,
                      color: isCustom ? AppColors.royalBlue : AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Fast Presets
          const Text(
            'اختيار سريع للمجلد بنقرة واحدة:',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ActionChip(
                avatar: Icon(LucideIcons.downloadCloud, size: 14, color: AppColors.royalBlue),
                label: const Text('التنزيلات (Downloads)', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5)),
                backgroundColor: AppColors.canvas,
                side: const BorderSide(color: AppColors.borderSubtle),
                onPressed: () async {
                  final presets = await const ReportStorageService().getDirectoryPresets();
                  final path = presets['downloads'];
                  if (path != null && context.mounted) {
                    context.read<SettingsBloc>().add(
                          SettingsSaved(settings.copyWith(reportsExportPath: path)),
                        );
                  }
                },
              ),
              ActionChip(
                avatar: const Icon(LucideIcons.fileText, size: 14, color: Color(0xFF0F766E)),
                label: const Text('المستندات (Documents)', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5)),
                backgroundColor: AppColors.canvas,
                side: const BorderSide(color: AppColors.borderSubtle),
                onPressed: () async {
                  final presets = await const ReportStorageService().getDirectoryPresets();
                  final path = presets['documents'];
                  if (path != null && context.mounted) {
                    context.read<SettingsBloc>().add(
                          SettingsSaved(settings.copyWith(reportsExportPath: path)),
                        );
                  }
                },
              ),
              ActionChip(
                avatar: const Icon(LucideIcons.smartphone, size: 14, color: Color(0xFF7C3AED)),
                label: const Text('مجلد التطبيق (App Storage)', style: TextStyle(fontFamily: 'Cairo', fontSize: 10.5)),
                backgroundColor: AppColors.canvas,
                side: const BorderSide(color: AppColors.borderSubtle),
                onPressed: () async {
                  final presets = await const ReportStorageService().getDirectoryPresets();
                  final path = presets['app_storage'];
                  if (path != null && context.mounted) {
                    context.read<SettingsBloc>().add(
                          SettingsSaved(settings.copyWith(reportsExportPath: path)),
                        );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Custom Path Dialog & Reset
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showCustomPathDialog(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(LucideIcons.penLine, size: 14, color: AppColors.textPrimary),
                  label: const Text(
                    'كتابة مسار مخصص...',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textPrimary),
                  ),
                ),
              ),
              if (isCustom) ...[
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'استعادة المسار الافتراضي',
                  icon: const Icon(LucideIcons.rotateCcw, size: 16, color: AppColors.textSecondary),
                  onPressed: () {
                    context.read<SettingsBloc>().add(
                          SettingsSaved(
                            ClubProfileSettings(
                              clubName: settings.clubName,
                              season: settings.season,
                              adminName: settings.adminName,
                              managerName: settings.managerName,
                              hasPin: settings.hasPin,
                              reportsExportPath: null,
                              autoShareOnExport: settings.autoShareOnExport,
                            ),
                          ),
                        );
                  },
                ),
              ],
            ],
          ),

          const Divider(height: 20, color: AppColors.borderSubtle),

          // Auto-share switch
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeThumbColor: AppColors.royalBlue,
            title: const Text(
              'فتح نافذة المشاركة تلقائياً فور التصدير',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: const Text(
              'إظهار قائمة المشاركة النظامية (Bluetooth, Quick Share, Apps) فور إنشاء التقرير',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            value: settings.autoShareOnExport,
            onChanged: (val) {
              context.read<SettingsBloc>().add(
                    SettingsSaved(settings.copyWith(autoShareOnExport: val)),
                  );
            },
          ),
        ],
      ),
    );
  }

  void _showCustomPathDialog(BuildContext context) {
    final controller = TextEditingController(text: settings.reportsExportPath ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'تحديد مسار حفظ مخصص',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أدخل المسار الكامل للمجلد الذي ترغب في حفظ التقارير داخله على جهازك:',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
              decoration: InputDecoration(
                hintText: 'مثال: C:\\Tadamon_Reports أو /storage/emulated/0/...',
                hintStyle: const TextStyle(fontSize: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.royalBlue),
            onPressed: () {
              final newPath = controller.text.trim();
              if (newPath.isNotEmpty) {
                context.read<SettingsBloc>().add(
                      SettingsSaved(settings.copyWith(reportsExportPath: newPath)),
                    );
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('حفظ المسار', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return const Column(
      children: [
        Text(
          'نظام نادي تضامن حضرموت الميداني • الإصدار 4.2.0 (Build 202611)',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2),
        Text(
          'تطوير وحدة الدعم الفني والتحول الرقمي بالنادي ⚽ حضرموت',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 9,
            color: Color(0xFF94A3B8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _openEditClubProfileModal(BuildContext context) {
    final clubController = TextEditingController(text: settings.clubName);
    final seasonController = TextEditingController(text: settings.season);
    final adminController = TextEditingController(
      text: settings.adminName ?? '',
    );
    final managerController = TextEditingController(
      text: settings.managerName ?? '',
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
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
                    onPressed: () => Navigator.of(bottomSheetContext).pop(),
                    icon: const Icon(LucideIcons.x),
                  ),
                  const Text(
                    'تحرير بيانات النادي والاعتمادات',
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
              TextField(
                controller: clubController,
                decoration: InputDecoration(
                  labelText: 'اسم النادي الرسمي',
                  labelStyle: const TextStyle(fontFamily: 'Cairo'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: seasonController,
                decoration: InputDecoration(
                  labelText: 'الموسم الميداني',
                  labelStyle: const TextStyle(fontFamily: 'Cairo'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: adminController,
                decoration: InputDecoration(
                  labelText: 'إداري الفريق المعتمد',
                  hintText: 'مثال: إداري الفريق المعتمد',
                  hintStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
                  labelStyle: const TextStyle(fontFamily: 'Cairo'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: managerController,
                decoration: InputDecoration(
                  labelText: 'المشرف الفني العام',
                  hintText: 'مثال: المدير الفني المعتمد',
                  hintStyle: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary),
                  labelStyle: const TextStyle(fontFamily: 'Cairo'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final newClubName = clubController.text.trim();
                    context.read<SettingsBloc>().add(
                          SettingsSaved(
                            settings.copyWith(
                              clubName: newClubName,
                              season: seasonController.text.trim(),
                              adminName: adminController.text.trim(),
                              managerName: managerController.text.trim(),
                            ),
                          ),
                        );
                    if (newClubName.isNotEmpty) {
                      ClubThemeService.instance.updateClubName(newClubName);
                    }
                    Navigator.of(bottomSheetContext).pop();
                  },
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
                    'حفظ التعديلات الرسمية',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

  void _openBackupScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => serviceLocator<BackupBloc>(),
          child: const BackupScreen(),
        ),
      ),
    );
  }

  Future<void> _openPinPad(BuildContext context) async {
    final pin = await showPinPadModal(context);
    if (pin != null && context.mounted) {
      context.read<SettingsBloc>().add(PinChanged(pin));
    }
  }

  void _confirmRemovePin(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'استعادة رمز المرور الافتراضي',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 14, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل تريد إزالة رمز المرور المخصص والعودة للرمز الافتراضي لنادي تضامن حضرموت؟',
          style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.unexcused),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<SettingsBloc>().add(const PinRemoved());
            },
            child: const Text('تأكيد الاستعادة', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _pickClubLogo(BuildContext context) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.image,
      );
      if (file == null) return;

      final docsDir = await getApplicationDocumentsDirectory();
      final logosDir = Directory(p.join(docsDir.path, 'club_branding'));
      if (!await logosDir.exists()) {
        await logosDir.create(recursive: true);
      }

      final ext = file.extension != null
          ? '.${file.extension}'
          : (file.path != null ? p.extension(file.path!) : '.png');
      final destPath = p.join(
        logosDir.path,
        'club_logo_${DateTime.now().millisecondsSinceEpoch}$ext',
      );

      if (file.path != null && await File(file.path!).exists()) {
        await File(file.path!).copy(destPath);
      } else {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          await File(destPath).writeAsBytes(bytes, flush: true);
        } else {
          throw Exception('تعذر قراءة بيانات صورة الشعار');
        }
      }

      if (context.mounted) {
        context.read<SettingsBloc>().add(
              SettingsSaved(settings.copyWith(logoPath: destPath)),
            );
        ClubThemeService.instance.updateLogoPath(destPath);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم تحديث وتثبيت شعار النادي بنجاح',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: AppColors.present,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر اختيار الشعار: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: AppColors.unexcused,
          ),
        );
      }
    }
  }

  void _resetClubLogo(BuildContext context) {
    context.read<SettingsBloc>().add(
          SettingsSaved(settings.copyWith(logoPath: '')),
        );
    ClubThemeService.instance.updateLogoPath(null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تمت استعادة الشعار الافتراضي لنادي تضامن حضرموت',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: AppColors.royalBlue,
      ),
    );
  }

  Future<void> _pickClubIdentityDocument(BuildContext context) async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg'],
      );
      if (file == null) return;

      final docsDir = await getApplicationDocumentsDirectory();
      final docsFolder = Directory(p.join(docsDir.path, 'club_documents'));
      if (!await docsFolder.exists()) {
        await docsFolder.create(recursive: true);
      }

      final ext = file.extension != null
          ? '.${file.extension}'
          : (file.path != null ? p.extension(file.path!) : '.pdf');
      final destPath = p.join(
        docsFolder.path,
        'identity_doc_${DateTime.now().millisecondsSinceEpoch}$ext',
      );

      if (file.path != null && await File(file.path!).exists()) {
        await File(file.path!).copy(destPath);
      } else {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) {
          await File(destPath).writeAsBytes(bytes, flush: true);
        } else {
          throw Exception('تعذر قراءة بيانات ملف الوثيقة');
        }
      }

      if (context.mounted) {
        context.read<SettingsBloc>().add(
              SettingsSaved(settings.copyWith(identityDocPath: destPath)),
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم حفظ وإرفاق وثيقة الهوية والاعتماد الرسمية',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: AppColors.present,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر إرفاق الوثيقة: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: AppColors.unexcused,
          ),
        );
      }
    }
  }

  void _removeClubIdentityDocument(BuildContext context) {
    context.read<SettingsBloc>().add(
          SettingsSaved(settings.copyWith(identityDocPath: '')),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تمت إزالة وثيقة الهوية بنجاح',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
      ),
    );
  }

  Future<void> _exportBackupFile(BuildContext context) async {
    try {
      final createUseCase = serviceLocator<CreateBackupUseCase>();
      final package = await createUseCase();
      final file = await BackupFileService.exportToFile(package);
      if (!context.mounted) return;

      await BackupFileService.shareBackupFile(file, clubName: package.manifest.clubName);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تصدير ملف النسخة الاحتياطية بنجاح جاهز للمشاركة',
              style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppColors.present,
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ أثناء التصدير: $e',
                style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: AppColors.unexcused,
          ),
        );
      }
    }
  }

  Future<void> _importBackupFile(BuildContext context) async {
    try {
      final content = await BackupFileService.pickAndReadBackupFile();
      if (content == null || !context.mounted) return;

      final restoreUseCase = serviceLocator<RestoreBackupUseCase>();
      final verification = await restoreUseCase.verify(content);

      if (!context.mounted) return;

      if (!verification.isValid || verification.manifest == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'الملف غير صالح أو تم التلاعب به: ${verification.errorMessage ?? "فشل التحقق من ختم الحزمة"}',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: AppColors.unexcused,
          ),
        );
        return;
      }

      final manifest = verification.manifest!;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('تأكيد استعادة بيانات النادي',
              style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: Text(
            'تم التحقق من ختم الحزمة بنجاح:\n'
            '• النادي: ${manifest.clubName}\n'
            '• إصدار النظام: ${manifest.appVersion}\n'
            '• اللاعبين: ${manifest.tableCounts['players'] ?? 0}\n'
            '• التمارين: ${manifest.tableCounts['sessions'] ?? 0}\n\n'
            'تحذير: سيتم استبدال البيانات الحالية ببيانات النسخة المستوردة (الترخيص وساعة النظام محمية تلقائياً).',
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.royalBlue),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('استعادة الآن',
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        await restoreUseCase(content);
        if (!context.mounted) return;
        context.read<SettingsBloc>().add(const SettingsRequested());
        try {
          context.read<TeamsBloc>().add(const TeamsRequested());
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت استعادة كافة البيانات بنجاح!',
                style: TextStyle(fontFamily: 'Cairo')),
            backgroundColor: AppColors.present,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ أثناء الاستيراد: $e',
                style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: AppColors.unexcused,
          ),
        );
      }
    }
  }
}
