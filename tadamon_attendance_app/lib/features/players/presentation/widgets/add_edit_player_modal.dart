import 'package:flutter/material.dart';
import 'package:tadamon_attendance_app/features/players/domain/entities/club_player.dart';

Future<ClubPlayer?> showAddEditPlayerModal(
  BuildContext context, {
  ClubPlayer? player,
}) {
  return showModalBottomSheet<ClubPlayer>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _PlayerForm(player: player),
  );
}

class _PlayerForm extends StatefulWidget {
  const _PlayerForm({this.player});
  final ClubPlayer? player;
  @override
  State<_PlayerForm> createState() => _PlayerFormState();
}

class _PlayerFormState extends State<_PlayerForm> {
  late final name = TextEditingController(text: widget.player?.name);
  late final number = TextEditingController(
    text: widget.player?.jerseyNumber?.toString(),
  );
  late final position = TextEditingController(text: widget.player?.position);
  @override
  void dispose() {
    name.dispose();
    number.dispose();
    position.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(
      20,
      20,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.player == null ? 'إضافة لاعب' : 'تعديل بيانات اللاعب',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 18),
        TextField(
          controller: name,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'اسم اللاعب'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: number,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'رقم القميص'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: position,
          decoration: const InputDecoration(labelText: 'المركز'),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _save,
          child: Text(widget.player == null ? 'إضافة اللاعب' : 'حفظ التعديلات'),
        ),
      ],
    ),
  );
  void _save() {
    final trimmed = name.text.trim();
    if (trimmed.length < 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('اكتب اسم اللاعب كاملاً.')));
      return;
    }
    final now = DateTime.now().toUtc();
    Navigator.pop(
      context,
      ClubPlayer(
        id: widget.player?.id ?? 'player-${now.microsecondsSinceEpoch}',
        name: trimmed,
        teamId: widget.player?.teamId ?? 'team-first',
        jerseyNumber: int.tryParse(number.text),
        position: position.text.trim(),
        joinDate: widget.player?.joinDate ?? now,
        updatedAt: now,
      ),
    );
  }
}
