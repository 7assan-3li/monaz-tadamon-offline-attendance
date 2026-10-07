import 'package:flutter/material.dart';

class FieldAttendanceAppShell extends StatelessWidget {
  const FieldAttendanceAppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: child));
  }
}
