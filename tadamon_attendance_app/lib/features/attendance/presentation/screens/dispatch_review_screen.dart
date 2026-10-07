import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/core/widgets/confirmation_dialog.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/widgets/locked_session_banner.dart';

class DispatchReviewScreen extends StatelessWidget {
  const DispatchReviewScreen({super.key});
  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<AttendanceBloc, AttendanceState>(
    builder: (context, state) {
      if (state is! AttendanceReady) {
        return const Center(child: CircularProgressIndicator());
      }
      final session = state.session;
      return Scaffold(
        appBar: AppBar(title: const Text('مراجعة التمرين')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (session.isLocked) const LockedSessionBanner(),
              if (session.isLocked) const SizedBox(height: 16),
              AppCard(
                child: Column(
                  children: [
                    _count(context, 'حاضر', session.presentCount),
                    _count(context, 'غائب بعذر', session.excusedCount),
                    _count(context, 'غائب بدون عذر', session.unexcusedCount),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                label: session.isLocked
                    ? 'مرحّل ومقفل إدارياً'
                    : 'ترحيل التمرين إلى الإدارة',
                leadingIcon: LucideIcons.lockKeyhole,
                onPressed: session.isLocked ? null : () => _dispatch(context),
              ),
            ],
          ),
        ),
      );
    },
  );
  Widget _count(BuildContext context, String label, int count) => ListTile(
    title: Text(label),
    trailing: Text('$count', style: Theme.of(context).textTheme.titleLarge),
  );
  Future<void> _dispatch(BuildContext context) async {
    final confirmed = await showAppConfirmationDialog(
      context: context,
      title: 'ترحيل التمرين إلى الإدارة؟',
      message: 'سيُقفل التمرين نهائياً، ولن تتمكن من تعديل حالات اللاعبين بعد الترحيل.',
      confirmLabel: 'ترحيل وقفل',
    );
    if (confirmed && context.mounted) {
      context.read<AttendanceBloc>().add(const DispatchSessionEvent());
    }
  }
}
