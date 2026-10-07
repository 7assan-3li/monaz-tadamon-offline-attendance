import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/features/attendance/domain/entities/player_attendance_item.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/widgets/attendance_player_card.dart';
import 'package:tadamon_attendance_app/features/attendance/presentation/widgets/locked_session_banner.dart';

void main() {
  testWidgets('locked player card ignores taps and shows administrative lock', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              const LockedSessionBanner(),
              AttendancePlayerCard(
                item: const PlayerAttendanceItem(
                  playerId: 'p1',
                  playerName: 'سالم مبارك',
                  status: PlayerAttendanceStatus.present,
                ),
                enabled: false,
                onTap: () => taps++,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('سالم مبارك'));
    expect(taps, 0);
    expect(find.text('مرحّل ومقفل إدارياً'), findsOneWidget);
    expect(
      tester.getSize(find.byType(AttendancePlayerCard)).height,
      greaterThanOrEqualTo(48),
    );
  });
}
