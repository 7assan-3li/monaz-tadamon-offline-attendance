import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/di/service_locator.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/core/widgets/squircle_icon_container.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/screens/field_attendance_flow.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:tadamon_attendance_app/features/sync/presentation/screens/master_scan_qr_screen.dart';

class DesignSystemGalleryScreen extends StatelessWidget {
  const DesignSystemGalleryScreen({this.onNavigateTab, super.key});

  final ValueChanged<int>? onNavigateTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        titleSpacing: 12,
        title: Row(
          children: [
            Image.asset(
              'assets/images/main_logo.png',
              width: 32,
              height: 34,
              fit: BoxFit.contain,
              semanticLabel: 'شعار نادي تضامن حضرموت',
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'نظام تحضير نادي تضامن حضرموت',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.royalBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'MONAZ',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.royalBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'لوحة التحكم الميدانية',
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
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.royalBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.shieldCheck,
                    size: 14,
                    color: AppColors.royalBlue,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'جهاز الإدارة',
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
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        children: [
          // 1. Club & Subscription Card
          _buildClubBar(),
          const SizedBox(height: 12),

          // 2. Hero Today's Session Card
          _buildHeroSessionCard(context),
          const SizedBox(height: 16),

          // 3. Quick Counters Row
          _buildLiveCounters(),
          const SizedBox(height: 16),

          // 4. Quick Actions Grid (All Functional)
          _buildQuickActions(context),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildClubBar() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          const SquircleIconContainer(
            icon: LucideIcons.shield,
            color: AppColors.royalBlue,
            semanticLabel: 'نادي تضامن حضرموت',
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      'نادي تضامن حضرموت',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.royalBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'الفريق الأول',
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
                const Text(
                  'المكلا، ساحل حضرموت',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.presentBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.present,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'ترخيص معتمد',
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
        ],
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'الفترة المسائية',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            color: AppColors.textSecondary,
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
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                LucideIcons.mapPin,
                                size: 16,
                                color: AppColors.royalBlue,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'الميدان التدريبي',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 9,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      'منشأة بارادم',
                                      style: TextStyle(
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
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                LucideIcons.clock,
                                size: 16,
                                color: AppColors.royalBlue,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'انطلاق التحضير',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 9,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    Text(
                                      '04:15 عصراً',
                                      style: TextStyle(
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
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppButton(
                    label: 'بدء تحضير تمرين اليوم',
                    leadingIcon: LucideIcons.play,
                    height: 52,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => BlocProvider(
                            create: (_) => serviceLocator<AttendanceBloc>()
                              ..add(const StartTodaySessionEvent('team-first')),
                            child: const FieldAttendanceFlow(initialPage: 1),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveCounters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'حالة التعداد اللحظي',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'تحديث فوري',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.checkCircle2,
                          size: 14,
                          color: AppColors.present,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'حاضر',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.present,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.present,
                        ),
                        children: [
                          TextSpan(text: '0'),
                          TextSpan(
                            text: ' / 6',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.presentBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'جاهز للمران',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.present,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.xCircle,
                          size: 14,
                          color: AppColors.unexcused,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'غائب',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.unexcused,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '0',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.unexcused,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.unexcusedBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'بدون عذر',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.unexcused,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'لم يُسجل',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '6',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'في الانتظار',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
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
                        'مسح كود QR من جهاز الميدان',
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
                onTap: () => onNavigateTab?.call(1),
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
                        'إضافة وتعديل وأرشفة اللاعبين',
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
                onTap: () => onNavigateTab?.call(2),
                child: const AppCard(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SquircleIconContainer(
                        icon: LucideIcons.clipboardList,
                        color: AppColors.royalBlue,
                        semanticLabel: 'الكشوفات والتقارير',
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
                        'استعراض الحصص والاعتماد',
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
                onTap: () => onNavigateTab?.call(3),
                child: const AppCard(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SquircleIconContainer(
                        icon: LucideIcons.settings,
                        color: AppColors.royalBlue,
                        semanticLabel: 'إعدادات النادي',
                      ),
                      SizedBox(height: 10),
                      Text(
                        'إعدادات النادي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ضبط النادي ورمز PIN',
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
