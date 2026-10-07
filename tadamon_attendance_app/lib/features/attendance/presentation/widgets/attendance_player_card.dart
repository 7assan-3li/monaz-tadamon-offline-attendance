import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';

class AttendancePlayerCard extends StatelessWidget {
  const AttendancePlayerCard({
    required this.item,
    required this.onTap,
    required this.enabled,
    super.key,
  });
  final PlayerAttendanceItem item;
  final VoidCallback onTap;
  final bool enabled;
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (item.status) {
      PlayerAttendanceStatus.present => ('حاضر', AppColors.present),
      PlayerAttendanceStatus.excused => ('غائب بعذر', AppColors.excused),
      PlayerAttendanceStatus.unexcused => (
        'غائب بدون عذر',
        AppColors.unexcused,
      ),
      PlayerAttendanceStatus.unmarked => ('لم تُرصد', AppColors.textSecondary),
    };
    return Semantics(
      button: enabled,
      label: '${item.playerName}، $label',
      child: InkWell(
        onTap: enabled
            ? () {
                HapticFeedback.selectionClick();
                onTap();
              }
            : null,
        borderRadius: BorderRadius.circular(14),
        child: AppCard(
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.jerseyNumber?.toString() ?? '—',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.playerName,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
