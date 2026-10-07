import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';

class PlayerCard extends StatelessWidget {
  const PlayerCard({
    required this.player,
    required this.onEdit,
    required this.onArchive,
    super.key,
  });
  final ClubPlayer player;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) => AppCard(
    margin: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            player.jerseyNumber?.toString() ?? '—',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.royalBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.name,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (player.position?.isNotEmpty == true)
                Text(
                  player.position!,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: onEdit,
          tooltip: 'تعديل اللاعب',
          icon: const Icon(LucideIcons.pencil, size: 20),
        ),
        IconButton(
          onPressed: onArchive,
          tooltip: 'أرشفة اللاعب',
          icon: const Icon(
            LucideIcons.archive,
            size: 20,
            color: AppColors.unexcused,
          ),
        ),
      ],
    ),
  );
}
