import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/theme/app_theme.dart';
import 'package:tadamon_attendance_app/core/widgets/attendance_badge.dart';

void main() {
  final cases = <AttendanceStatus, (String, Color, Color)>{
    AttendanceStatus.present: (
      'حاضر',
      AppColors.present,
      AppColors.presentBackground,
    ),
    AttendanceStatus.excused: (
      'غائب بعذر',
      AppColors.excused,
      AppColors.excusedBackground,
    ),
    AttendanceStatus.unexcused: (
      'غائب بدون عذر',
      AppColors.unexcused,
      AppColors.unexcusedBackground,
    ),
  };

  for (final MapEntry(key: status, value: expected) in cases.entries) {
    testWidgets('renders the approved ${expected.$1} label and colors', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: AttendanceBadge(status: status)),
        ),
      );

      expect(find.text(expected.$1), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      final label = tester.widget<Text>(find.text(expected.$1));

      expect(decoration.color, expected.$3);
      expect(label.style?.color, expected.$2);
    });
  }
}
