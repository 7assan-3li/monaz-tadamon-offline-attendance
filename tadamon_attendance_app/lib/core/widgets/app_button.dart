import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';

enum AppButtonVariant { primary, secondary, destructive }

extension AppButtonVariantStyle on AppButtonVariant {
  Color get backgroundColor => switch (this) {
    AppButtonVariant.primary => AppColors.royalBlue,
    AppButtonVariant.secondary => AppColors.surface,
    AppButtonVariant.destructive => AppColors.unexcused,
  };

  Color get foregroundColor => switch (this) {
    AppButtonVariant.secondary => AppColors.textPrimary,
    AppButtonVariant.primary ||
    AppButtonVariant.destructive => AppColors.surface,
  };

  BorderSide get borderSide => switch (this) {
    AppButtonVariant.secondary => const BorderSide(
      color: AppColors.borderSubtle,
      width: 1.5,
    ),
    AppButtonVariant.primary || AppButtonVariant.destructive => BorderSide.none,
  };
}

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.leadingIcon,
    this.height = 54,
    this.expand = true,
    super.key,
  }) : assert(height >= 48 && height <= 56);

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? leadingIcon;
  final double height;
  final bool expand;

  void _handlePressed() {
    HapticFeedback.lightImpact();
    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : null,
      height: height,
      child: FilledButton.icon(
        onPressed: onPressed == null ? null : _handlePressed,
        style: FilledButton.styleFrom(
          backgroundColor: variant.backgroundColor,
          foregroundColor: variant.foregroundColor,
          disabledBackgroundColor: AppColors.borderSubtle,
          disabledForegroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: variant.borderSide,
          ),
          textStyle: Theme.of(context).textTheme.labelLarge,
          minimumSize: Size(0, height),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
        icon: leadingIcon == null
            ? const SizedBox.shrink()
            : Icon(leadingIcon, size: 20),
        label: Text(label),
      ),
    );
  }
}
