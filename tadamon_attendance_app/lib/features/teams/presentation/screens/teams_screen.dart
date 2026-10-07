import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/features/teams/domain/entities/club_team.dart';
import 'package:tadamon_attendance_app/features/teams/presentation/bloc/teams_bloc.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<TeamsBloc, TeamsState>(
    builder: (context, state) => switch (state) {
      TeamsLoading() => const Center(child: CircularProgressIndicator()),
      TeamsFailure(:final message) => Text(message),
      TeamsReady(:final teams) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'الفرق الرياضية',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                onPressed: () => _edit(context),
                tooltip: 'إضافة فريق',
                icon: const Icon(LucideIcons.plus),
              ),
            ],
          ),
          ...teams.map(
            (team) => ListTile(
              leading: const Icon(LucideIcons.shield),
              title: Text(team.name),
              subtitle: Text(team.category),
              trailing: IconButton(
                onPressed: () => _edit(context, team),
                icon: const Icon(LucideIcons.pencil),
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
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              team == null ? 'إضافة فريق' : 'تعديل الفريق',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: 'اسم الفريق'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: category,
              decoration: const InputDecoration(labelText: 'الفئة الرياضية'),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: () => Navigator.pop(sheetContext, true),
              child: const Text('حفظ الفريق'),
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
            name: name.text,
            category: category.text,
            updatedAt: now,
          ),
        ),
      );
    }
    name.dispose();
    category.dispose();
  }
}
