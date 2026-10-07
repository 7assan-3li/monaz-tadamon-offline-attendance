import 'package:flutter/material.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/screens/dispatch_review_screen.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/screens/field_dashboard_screen.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/screens/quick_attendance_screen.dart';

class FieldAttendanceFlow extends StatefulWidget {
  const FieldAttendanceFlow({super.key});
  @override
  State<FieldAttendanceFlow> createState() => _FieldAttendanceFlowState();
}

class _FieldAttendanceFlowState extends State<FieldAttendanceFlow> {
  var page = 0;
  @override
  Widget build(BuildContext context) => switch (page) {
    0 => FieldDashboardScreen(onSessionStarted: () => setState(() => page = 1)),
    1 => QuickAttendanceScreen(onReview: () => setState(() => page = 2)),
    _ => const DispatchReviewScreen(),
  };
}
