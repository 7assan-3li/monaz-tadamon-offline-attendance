import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/theme/app_theme.dart';
import 'package:tadamon_attendance_app/core/widgets/app_button.dart';

void main() {
  testWidgets('provides a field-safe touch target and handles taps', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppButton(
            label: 'بدء تحضير تمرين اليوم',
            onPressed: () => tapCount++,
          ),
        ),
      ),
    );

    final buttonSize = tester.getSize(find.byType(FilledButton));
    expect(buttonSize.height, greaterThanOrEqualTo(48));
    expect(buttonSize.height, 54);

    await tester.tap(find.text('بدء تحضير تمرين اليوم'));
    await tester.pump();

    expect(tapCount, 1);
  });

  testWidgets('uses right-to-left direction for Arabic labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: AppButton(label: 'تحديد الجميع حاضر', onPressed: null),
          ),
        ),
      ),
    );

    final labelContext = tester.element(find.text('تحديد الجميع حاضر'));
    expect(Directionality.of(labelContext), TextDirection.rtl);
  });
}
