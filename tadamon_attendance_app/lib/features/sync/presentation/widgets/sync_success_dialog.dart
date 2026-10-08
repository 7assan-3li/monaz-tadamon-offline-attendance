import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/squircle_icon_container.dart';

Future<void> showSyncSuccessDialog({
  required BuildContext context,
  required String sessionUuid,
  required int playersCount,
  VoidCallback? onConfirm,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: AppColors.surface,
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SquircleIconContainer(
              icon: LucideIcons.circleCheck,
              color: AppColors.present,
            ),
            const SizedBox(height: 16),
            const Text(
              'تم استيراد تمرين اليوم بنجاح ✅',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'تم استيراد سجلات $playersCount لاعباً وأُدرج الكشف بحالة «بانتظار الاعتماد».',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'موافق',
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onConfirm?.call();
              },
            ),
          ],
        ),
      );
    },
  );
}
