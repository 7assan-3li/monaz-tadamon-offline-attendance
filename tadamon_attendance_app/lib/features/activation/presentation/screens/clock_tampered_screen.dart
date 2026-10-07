import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/squircle_icon_container.dart';

final class ClockTamperedScreen extends StatelessWidget {
  const ClockTamperedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SquircleIconContainer(
                icon: LucideIcons.clockAlert,
                color: AppColors.unexcused,
                semanticLabel: 'تنبيه ساعة الجهاز',
              ),
              SizedBox(height: 24),
              Text(
                'ساعة الجهاز غير مضبوطة',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'تم رصد تراجع في تاريخ أو وقت الجهاز. صحّح الساعة للمتابعة.',
                style: TextStyle(fontSize: 17),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
