import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/bloc/attendance_bloc.dart';

class FieldDashboardScreen extends StatelessWidget {
  const FieldDashboardScreen({required this.onSessionStarted, super.key});
  final VoidCallback onSessionStarted;
  @override
  Widget build(BuildContext context) =>
      BlocListener<AttendanceBloc, AttendanceState>(
        listenWhen: (previous, current) =>
            current is AttendanceReady && previous is! AttendanceReady,
        listener: (_, _) => onSessionStarted(),
        child: Scaffold(
          appBar: AppBar(title: const Text('التحضير الميداني')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                AppCard(
                  child: Row(
                    children: [
                      const Icon(LucideIcons.calendarClock, size: 30),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تمرين اليوم',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              _today(),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                BlocBuilder<AttendanceBloc, AttendanceState>(
                  builder: (context, state) => AppButton(
                    label: state is AttendanceLoading
                        ? 'جارٍ تجهيز الكشف…'
                        : 'بدء تحضير تمرين اليوم',
                    leadingIcon: LucideIcons.play,
                    onPressed: state is AttendanceLoading
                        ? null
                        : () => context.read<AttendanceBloc>().add(
                            const StartTodaySessionEvent('team-first'),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  static String _today() {
    final date = DateTime.now();
    return '${date.day}/${date.month}/${date.year} — الفريق الأول';
  }
}
