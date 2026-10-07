import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';
import 'package:tadamon_attendance_app/core/widgets/confirmation_dialog.dart';
import 'package:tadamon_attendance_app/core/widgets/squircle_icon_container.dart';

class DesignSystemGalleryScreen extends StatelessWidget {
  const DesignSystemGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نظام تحضير نادي تضامن حضرموت')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Image.asset(
              'assets/images/main_logo.png',
              width: 128,
              height: 148,
              fit: BoxFit.contain,
              semanticLabel: 'شعار نادي تضامن حضرموت',
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SquircleIconContainer(
                      icon: LucideIcons.calendarClock,
                      color: AppColors.royalBlue,
                      semanticLabel: 'تمرين اليوم',
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'حالات التحضير المعتمدة',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AttendanceBadge(status: AttendanceStatus.present),
                    AttendanceBadge(status: AttendanceStatus.excused),
                    AttendanceBadge(status: AttendanceStatus.unexcused),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'بدء تحضير تمرين اليوم',
            leadingIcon: LucideIcons.play,
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'معاينة نافذة التأكيد',
            leadingIcon: LucideIcons.shieldCheck,
            variant: AppButtonVariant.secondary,
            onPressed: () => showAppConfirmationDialog(
              context: context,
              title: 'تأكيد الإجراء؟',
              message: 'راجع البيانات قبل المتابعة.',
              confirmLabel: 'متابعة',
            ),
          ),
        ],
      ),
    );
  }
}
