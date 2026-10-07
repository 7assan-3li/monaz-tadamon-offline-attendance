// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/presentation/design_system_gallery_screen.dart';

import 'package:tadamon_attendance_app/main.dart';

void main() {
  testWidgets('renders the Stage 1 design system gallery in RTL', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp(home: DesignSystemGalleryScreen()));
    await tester.pumpAndSettle();

    expect(find.text('نظام تحضير نادي تضامن حضرموت'), findsOneWidget);
    expect(find.text('بدء تحضير تمرين اليوم'), findsOneWidget);
    expect(find.text('حاضر'), findsOneWidget);
    expect(find.text('غائب بعذر'), findsOneWidget);
    expect(find.text('غائب بدون عذر'), findsOneWidget);

    final titleContext = tester.element(
      find.text('نظام تحضير نادي تضامن حضرموت'),
    );
    expect(Directionality.of(titleContext), TextDirection.rtl);
  });
}
