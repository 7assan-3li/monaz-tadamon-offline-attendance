import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/bloc/attendance_bloc.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/widgets/attendance_player_card.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/widgets/locked_session_banner.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/widgets/one_touch_present_button.dart';

class QuickAttendanceScreen extends StatelessWidget {
  const QuickAttendanceScreen({required this.onReview, super.key});
  final VoidCallback onReview;
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state case AttendanceFailure(:final message)) {
            return Center(child: Text(message));
          }
          if (state is! AttendanceReady) {
            return const Center(child: CircularProgressIndicator());
          }
          final session = state.session;
          return Scaffold(
            appBar: AppBar(title: const Text('تحضير تمرين اليوم')),
            body: Column(
              children: [
                if (session.isLocked)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: LockedSessionBanner(),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: session.items.length,
                    itemBuilder: (_, index) {
                      final item = session.items[index];
                      return AttendancePlayerCard(
                        item: item,
                        enabled: !session.isLocked,
                        onTap: () => context.read<AttendanceBloc>().add(
                          UpdatePlayerStatusEvent(item.playerId),
                        ),
                      );
                    },
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        OneTouchPresentButton(
                          onPressed: session.isLocked
                              ? null
                              : () => context.read<AttendanceBloc>().add(
                                  const MarkAllPresentEvent(),
                                ),
                        ),
                        const SizedBox(height: 8),
                        AppButton(
                          label: 'مراجعة التمرين',
                          variant: AppButtonVariant.secondary,
                          onPressed: onReview,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
}
