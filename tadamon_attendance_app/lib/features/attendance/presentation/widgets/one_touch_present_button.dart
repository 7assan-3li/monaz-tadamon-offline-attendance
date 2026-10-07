import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';

class OneTouchPresentButton extends StatelessWidget {
  const OneTouchPresentButton({required this.onPressed, super.key});
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => AppButton(
    label: 'تحديد الجميع حاضر',
    leadingIcon: LucideIcons.zap,
    onPressed: onPressed,
  );
}
