import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/di/service_locator.dart';
import 'package:tadamon_attendance_app/features/backup/presentation/bloc/backup_bloc.dart';
import 'package:tadamon_attendance_app/features/backup/presentation/screens/backup_screen.dart';
import 'package:tadamon_attendance_app/features/settings/domain/entities/club_profile_settings.dart';
import 'package:tadamon_attendance_app/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:tadamon_attendance_app/features/settings/presentation/widgets/pin_pad_modal.dart';
import 'package:tadamon_attendance_app/features/teams/presentation/screens/teams_screen.dart';

class ClubSettingsScreen extends StatelessWidget {
  const ClubSettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('إعدادات النادي')),
    body: BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state case SettingsReady(message: final message?)) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) => switch (state) {
        SettingsLoading() => const Center(child: CircularProgressIndicator()),
        SettingsFailure(:final message) => Center(child: Text(message)),
        SettingsReady(:final settings) => _SettingsForm(settings: settings),
      },
    ),
  );
}

class _SettingsForm extends StatefulWidget {
  const _SettingsForm({required this.settings});
  final ClubProfileSettings settings;
  @override
  State<_SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<_SettingsForm> {
  late final club = TextEditingController(text: widget.settings.clubName);
  late final season = TextEditingController(text: widget.settings.season);
  late final admin = TextEditingController(text: widget.settings.adminName);
  late final manager = TextEditingController(text: widget.settings.managerName);
  @override
  void dispose() {
    club.dispose();
    season.dispose();
    admin.dispose();
    manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      TextField(
        controller: club,
        decoration: const InputDecoration(labelText: 'اسم النادي'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: season,
        decoration: const InputDecoration(labelText: 'الموسم الرياضي'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: admin,
        decoration: const InputDecoration(labelText: 'إداري الفريق'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: manager,
        decoration: const InputDecoration(labelText: 'مدير النادي'),
      ),
      const SizedBox(height: 18),
      FilledButton.icon(
        onPressed: _save,
        icon: const Icon(LucideIcons.save),
        label: const Text('حفظ إعدادات النادي'),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: _pin,
        icon: const Icon(LucideIcons.keyRound),
        label: Text(
          widget.settings.hasPin ? 'تغيير رمز الحماية' : 'تعيين رمز الحماية',
        ),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider(
                create: (_) => serviceLocator<BackupBloc>(),
                child: const BackupScreen(),
              ),
            ),
          );
        },
        icon: const Icon(LucideIcons.hardDrive),
        label: const Text('النسخ الاحتياطي والاستعادة (USB)'),
      ),
      const SizedBox(height: 24),
      const TeamsScreen(),
    ],
  );
  void _save() => context.read<SettingsBloc>().add(
    SettingsSaved(
      ClubProfileSettings(
        clubName: club.text,
        season: season.text,
        adminName: admin.text,
        managerName: manager.text,
        hasPin: widget.settings.hasPin,
      ),
    ),
  );
  Future<void> _pin() async {
    final pin = await showPinPadModal(context);
    if (pin != null && mounted) {
      context.read<SettingsBloc>().add(PinChanged(pin));
    }
  }
}
