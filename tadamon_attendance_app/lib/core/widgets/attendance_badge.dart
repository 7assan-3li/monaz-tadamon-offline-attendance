import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';

enum AttendanceStatus { present, excused, unexcused }

extension AttendanceStatusVisuals on AttendanceStatus {
  String get label => switch (this) {
    AttendanceStatus.present => 'حاضر',
    AttendanceStatus.excused => 'غائب بعذر',
    AttendanceStatus.unexcused => 'غائب بدون عذر',
  };

  String get dbValue => switch (this) {
    AttendanceStatus.present => 'present',
    AttendanceStatus.excused => 'excused',
    AttendanceStatus.unexcused => 'unexcused',
  };

  String get shortArabicSymbol => switch (this) {
    AttendanceStatus.present => 'ح',
    AttendanceStatus.excused => 'ع',
    AttendanceStatus.unexcused => 'غ',
  };

  static AttendanceStatus fromDb(String value) => switch (value) {
    'present' => AttendanceStatus.present,
    'excused' => AttendanceStatus.excused,
    _ => AttendanceStatus.unexcused,
  };

  Color get foregroundColor => switch (this) {
    AttendanceStatus.present => AppColors.present,
    AttendanceStatus.excused => AppColors.excused,
    AttendanceStatus.unexcused => AppColors.unexcused,
  };

  Color get backgroundColor => switch (this) {
    AttendanceStatus.present => AppColors.presentBackground,
    AttendanceStatus.excused => AppColors.excusedBackground,
    AttendanceStatus.unexcused => AppColors.unexcusedBackground,
  };

  IconData get icon => switch (this) {
    AttendanceStatus.present => LucideIcons.checkCircle2,
    AttendanceStatus.excused => LucideIcons.alertCircle,
    AttendanceStatus.unexcused => LucideIcons.xCircle,
  };
}

class AttendanceBadge extends StatelessWidget {
  const AttendanceBadge({required this.status, super.key});

  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: status.label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: status.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(status.icon, size: 16, color: status.foregroundColor),
            const SizedBox(width: 6),
            Text(
              status.label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: status.foregroundColor),
            ),
          ],
        ),
      ),
    );
  }
}
