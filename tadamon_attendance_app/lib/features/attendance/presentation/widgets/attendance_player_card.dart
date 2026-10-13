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
    this.onStatusSelected,
    super.key,
  });

  final PlayerAttendanceItem item;
  final VoidCallback onTap;
  final bool enabled;
  final ValueChanged<PlayerAttendanceStatus>? onStatusSelected;

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
      child: AppCard(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: InkWell(
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onTap();
                }
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              // رقم القميص في مربع أزرق ملكي أنيق
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.royalBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.jerseyNumber?.toString() ?? '—',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // معلومات اللاعب والمركز والشارة
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.playerName,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.position ?? 'وسط ميدان',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '•',
                          style: TextStyle(
                            color: AppColors.borderSubtle,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: _buildStatusTag(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // مفتاح التحضير الثلاثي اللحظي
              if (enabled)
                _buildThreeWayToggle(context)
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTag() {
    return switch (item.status) {
      PlayerAttendanceStatus.present => const Text(
          'حاضر للمران',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.present,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      PlayerAttendanceStatus.excused => Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.excusedBackground,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'بعذر',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.excused,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      PlayerAttendanceStatus.unexcused => Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.unexcusedBackground,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'بدون عذر',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.unexcused,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      PlayerAttendanceStatus.unmarked => const Text(
          'في الانتظار',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
    };
  }

  Widget _buildThreeWayToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            label: 'حاضر',
            status: PlayerAttendanceStatus.present,
            selectedColor: AppColors.present,
          ),
          _buildToggleButton(
            label: 'عذر',
            status: PlayerAttendanceStatus.excused,
            selectedColor: AppColors.excused,
          ),
          _buildToggleButton(
            label: 'غائب',
            status: PlayerAttendanceStatus.unexcused,
            selectedColor: AppColors.unexcused,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required PlayerAttendanceStatus status,
    required Color selectedColor,
  }) {
    final isSelected = item.status == status;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        if (onStatusSelected != null) {
          onStatusSelected!(status);
        } else {
          onTap();
        }
      },
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
