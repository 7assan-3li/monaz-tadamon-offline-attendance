import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';

class OneTouchPresentButton extends StatelessWidget {
  const OneTouchPresentButton({
    required this.onPressed,
    this.playerCount,
    super.key,
  });

  final VoidCallback? onPressed;
  final int? playerCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.present,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.present.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white70,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: onPressed == null
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onPressed!();
              },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.checkCheck, size: 20),
            const SizedBox(width: 8),
            const Text(
              '⚡ ',
              style: TextStyle(fontSize: 15),
            ),
            const Text(
              'تحديد الجميع حاضر',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (playerCount != null)
              Text(
                ' ($playerCount لاعب)',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
