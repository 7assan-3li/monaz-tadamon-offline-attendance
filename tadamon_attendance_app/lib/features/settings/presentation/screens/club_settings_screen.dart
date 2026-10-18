import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/di/service_locator.dart';
import 'package:tadamon_attendance_app/features/backup/presentation/bloc/backup_bloc.dart';
import 'package:tadamon_attendance_app/features/backup/presentation/screens/backup_screen.dart';
import 'package:tadamon_attendance_app/features/reports/data/datasources/report_storage_service.dart';
import 'package:tadamon_attendance_app/features/settings/domain/entities/club_profile_settings.dart';
import 'package:tadamon_attendance_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:tadamon_attendance_app/features/settings/presentation/widgets/pin_pad_modal.dart';
import 'package:tadamon_attendance_app/features/teams/presentation/screens/teams_screen.dart';

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
      ),
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
          icon: LucideIcons.building2,
          title: 'بيانات النادي والاعتماد',
          iconColor: AppColors.royalBlue,
        ),
        const SizedBox(height: 8),
        _buildClubProfileCard(context),
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

  Widget _buildFieldModeSwitchCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFDBFE)),
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
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.smartphone,
                  size: 20,
                  color: AppColors.royalBlue,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الوضع الحالي: جهاز الإدارة (Master Admin)',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'صلاحيات كاملة للتحكم بالكشوف والتقارير والإعدادات',
                      style: TextStyle(
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
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.info,
                  size: 16,
                  color: Color(0xFF0284C7),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'يمكنك تحويل هذا الهاتف مؤقتاً إلى وضع المحضر الميداني لتسليمه للمحضر أو تجربة الرصد فقط. سيتم إخفاء الإعدادات واللاعبين والتقارير، ولا يمكن العودة إلا برمز PIN الخاص بالإدارة.',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Color(0xFF334155),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text(
                      'تحويل إلى وضع المحضر الميداني؟',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: const Text(
                      'سيتحول التطبيق فوراً إلى واجهة التحضير والرصد الميداني فقط مع عزل الإعدادات والتقارير.\n\nللرجوع إلى وضع الإدارة، سيتطلب إدخال رمز PIN.',
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
                        child: const Text('تأكيد التحويل',
                            style: TextStyle(fontFamily: 'Cairo')),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(LucideIcons.arrowRightLeft, size: 16),
              label: const Text(
                'التبديل إلى وضع المحضر الميداني (Field Mode)',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.royalBlue,
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
                width: 42,
                height: 42,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  'assets/images/main_logo.png',
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
                        fontSize: 13,
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
                  'تعديل',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.royalBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                icon: const Icon(LucideIcons.copy, size: 13, color: AppColors.royalBlue),
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
                      const Icon(LucideIcons.keyRound, size: 16, color: AppColors.royalBlue),
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
                  onPressed: () => _openBackupScreen(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.royalBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(LucideIcons.save, size: 15),
                  label: const Text(
                    'تصدير نسخة احتياطية',
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
                  onPressed: () => _openBackupScreen(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(LucideIcons.rotateCcw, size: 15),
                  label: const Text(
                    'استعادة نسخة',
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
                avatar: const Icon(LucideIcons.downloadCloud, size: 14, color: AppColors.royalBlue),
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
                    context.read<SettingsBloc>().add(
                          SettingsSaved(
                            ClubProfileSettings(
                              clubName: clubController.text.trim(),
                              season: seasonController.text.trim(),
                              adminName: adminController.text.trim(),
                              managerName: managerController.text.trim(),
                              hasPin: settings.hasPin,
                            ),
                          ),
                        );
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
}
