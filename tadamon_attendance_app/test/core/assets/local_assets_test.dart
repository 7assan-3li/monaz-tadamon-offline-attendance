import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundles Cairo fonts and the club logo locally', () async {
    const assetPaths = <String>[
      'assets/fonts/cairo/Cairo-Regular.ttf',
      'assets/fonts/cairo/Cairo-SemiBold.ttf',
      'assets/fonts/cairo/Cairo-Bold.ttf',
      'assets/images/main_logo.png',
    ];

    for (final assetPath in assetPaths) {
      final assetData = await rootBundle.load(assetPath);
      expect(
        assetData.lengthInBytes,
        greaterThan(0),
        reason: '$assetPath must be available without a network connection.',
      );
    }
  });

  testWidgets('uses Cairo as the application font', (tester) async {
    await tester.pumpWidget(const MyApp(home: SizedBox.shrink()));

    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(materialApp.theme?.textTheme.bodyMedium?.fontFamily, 'Cairo');
  });
}
