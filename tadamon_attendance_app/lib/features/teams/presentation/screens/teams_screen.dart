import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/features/teams/domain/entities/club_team.dart';
import 'package:tadamon_attendance_app/features/teams/presentation/bloc/teams_bloc.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<TeamsBloc, TeamsState>(
    builder: (context, state) => switch (state) {
      TeamsLoading() => const Center(child: CircularProgressIndicator()),
      TeamsFailure(:final message) => Center(
        child: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo', color: AppColors.unexcused),
        ),
      ),
      TeamsReady(:final teams) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(LucideIcons.shieldAlert, size: 20, color: AppColors.royalBlue),
                  SizedBox(width: 8),
                  Text(
                    'فرق وفئات نادي التضامن',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _edit(context),
                tooltip: 'إضافة فريق أو فئة جديدة',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.royalBlue.withValues(alpha: 0.1),
                  foregroundColor: AppColors.royalBlue,
                ),
                icon: const Icon(LucideIcons.plus, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...teams.map(
            (team) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.royalBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.shield,
                      size: 20,
                      color: AppColors.royalBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            team.category,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _edit(context, team),
                    tooltip: 'تعديل بيانات الفريق',
                    icon: const Icon(
                      LucideIcons.pencil,
                      size: 17,
                      color: AppColors.royalBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    },
  );

  Future<void> _edit(BuildContext context, [ClubTeam? team]) async {
    final name = TextEditingController(text: team?.name);
    final category = TextEditingController(text: team?.category);
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  team == null ? 'إضافة فريق رياضي جديد' : 'تعديل بيانات الفريق',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(LucideIcons.x, size: 18),
                ),
              ],
            ),
            const Divider(height: 16),
            const SizedBox(height: 6),
            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: 'اسم الفريق',
                labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                prefixIcon: const Icon(LucideIcons.shield, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: category,
              decoration: InputDecoration(
                labelText: 'الفئة الرياضية (مثال: ممتاز، تحت 19 سنة، ناشئين)',
                labelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                prefixIcon: const Icon(LucideIcons.tag, size: 18),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 18),
            AppButton(
              label: team == null ? 'إضافة الفريق للنادي' : 'حفظ التعديلات',
              leadingIcon: LucideIcons.check,
              onPressed: () => Navigator.pop(sheetContext, true),
            ),
          ],
        ),
      ),
    );
    if (saved == true &&
        context.mounted &&
        name.text.trim().isNotEmpty &&
        category.text.trim().isNotEmpty) {
      final now = DateTime.now().toUtc();
      context.read<TeamsBloc>().add(
        TeamSaved(
          ClubTeam(
            id: team?.id ?? 'team-${now.microsecondsSinceEpoch}',
            name: name.text.trim(),
            category: category.text.trim(),
            updatedAt: now,
          ),
        ),
      );
    }
    name.dispose();
    category.dispose();
  }
}
