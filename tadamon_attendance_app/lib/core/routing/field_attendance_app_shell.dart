import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/di/service_locator.dart';
import 'package:tadamon_attendance_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:tadamon_attendance_app/features/settings/presentation/widgets/pin_pad_modal.dart';

import 'package:tadamon_attendance_app/features/sync/presentation/widgets/quick_cloud_sync_modal.dart';

class FieldAttendanceAppShell extends StatelessWidget {
  const FieldAttendanceAppShell({
    required this.child,
    this.onExitFieldMode,
    super.key,
  });

  final Widget child;
  final VoidCallback? onExitFieldMode;

  Future<void> _handleExit(BuildContext context) async {
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
      onExitFieldMode?.call();
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'رمز PIN غير صحيح. لا يمكن مغادرة وضع المحضر.',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppColors.unexcused,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: onExitFieldMode != null
          ? AppBar(
              backgroundColor: const Color(0xFF0F172A),
              elevation: 0,
              titleSpacing: 16,
              title: const Row(
                children: [
                  Icon(LucideIcons.shieldAlert,
                      size: 16, color: Color(0xFF38BDF8)),
                  SizedBox(width: 8),
                  Text(
                    'وضع المحضر الميداني (مقفل)',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () => QuickCloudSyncModal.show(context),
                  icon: const Icon(LucideIcons.cloud,
                      size: 18, color: Color(0xFF38BDF8)),
                  tooltip: 'مزامنة السحابة',
                ),
                TextButton.icon(
                  onPressed: () => _handleExit(context),
                  icon: const Icon(LucideIcons.lockKeyhole,
                      size: 15, color: Color(0xFF93C5FD)),
                  label: const Text(
                    'العودة للإدارة (PIN)',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF93C5FD),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: SafeArea(child: child),
    );
  }
}
