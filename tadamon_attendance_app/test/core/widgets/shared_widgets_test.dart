import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:tadamon_attendance_app/core/constants/app_colors.dart';
import 'package:tadamon_attendance_app/core/theme/app_theme.dart';
import 'package:tadamon_attendance_app/core/widgets/app_card.dart';
import 'package:tadamon_attendance_app/core/widgets/confirmation_dialog.dart';
import 'package:tadamon_attendance_app/core/widgets/squircle_icon_container.dart';

void main() {
  testWidgets('AppCard uses the approved surface and radius', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: AppCard(child: Text('بطاقة'))),
      ),
    );

    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;

    expect(decoration.color, AppColors.surface);
    expect(decoration.borderRadius, BorderRadius.circular(14));
  });

  testWidgets('SquircleIconContainer is 40 by 40 logical pixels', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SquircleIconContainer(
            icon: LucideIcons.shieldCheck,
            color: AppColors.royalBlue,
            semanticLabel: 'الأمان',
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(Container)), const Size(40, 40));
    expect(find.byIcon(LucideIcons.shieldCheck), findsOneWidget);
  });

  testWidgets('ConfirmationDialog returns the confirmed decision', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showAppConfirmationDialog(
                context: context,
                title: 'اعتماد الكشف؟',
                message: 'سيُعتمد الكشف بعد المراجعة.',
                confirmLabel: 'اعتماد الكشف',
              );
            },
            child: const Text('فتح'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('فتح'));
    await tester.pumpAndSettle();

    expect(find.text('تراجع'), findsOneWidget);
    expect(find.text('اعتماد الكشف'), findsOneWidget);

    await tester.tap(find.text('اعتماد الكشف'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });
}
