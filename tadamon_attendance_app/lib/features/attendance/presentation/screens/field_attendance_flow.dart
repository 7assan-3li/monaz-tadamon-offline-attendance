import 'package:flutter/material.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/screens/dispatch_review_screen.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/screens/field_dashboard_screen.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/screens/quick_attendance_screen.dart';

class FieldAttendanceFlow extends StatefulWidget {
  const FieldAttendanceFlow({this.initialPage = 0, super.key});

  final int initialPage;

  @override
  State<FieldAttendanceFlow> createState() => _FieldAttendanceFlowState();
}

class _FieldAttendanceFlowState extends State<FieldAttendanceFlow> {
  late var page = widget.initialPage;

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: page == 0 || page == widget.initialPage,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && page > 0) {
        setState(() => page--);
      }
    },
    child: switch (page) {
      0 => FieldDashboardScreen(
        onSessionStarted: () => setState(() => page = 1),
      ),
      1 => QuickAttendanceScreen(
        onReview: () => setState(() => page = 2),
      ),
      _ => DispatchReviewScreen(
        onBack: () => setState(() => page = 1),
      ),
    },
  );
}
