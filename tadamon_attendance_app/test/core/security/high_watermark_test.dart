import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/security/high_watermark_guard.dart';

void main() {
  test('advances both stores when device time is monotonic', () async {
    final store = _MemoryHighWatermarkStore(
      database: DateTime.utc(2026, 10, 6, 12),
      secure: DateTime.utc(2026, 10, 6, 13),
    );
    final guard = HighWatermarkGuard(
      store: store,
      currentTime: () => DateTime.utc(2026, 10, 7, 12),
    );

    final result = await guard.verifyAndAdvance();

    expect(result, DateTime.utc(2026, 10, 7, 12));
    expect(store.database, result);
    expect(store.secure, result);
    expect(store.tamperLatched, isFalse);
  });

  test('latches tampering when either stored watermark is ahead', () async {
    final store = _MemoryHighWatermarkStore(
      database: DateTime.utc(2026, 10, 7, 12),
      secure: DateTime.utc(2026, 11, 7, 12),
    );
    final guard = HighWatermarkGuard(
      store: store,
      currentTime: () => DateTime.utc(2026, 10, 7, 13),
    );

    await expectLater(
      guard.verifyAndAdvance(),
      throwsA(isA<ClockTamperedException>()),
    );
    expect(store.tamperLatched, isTrue);
    expect(store.secure, DateTime.utc(2026, 11, 7, 12));
  });
}

final class _MemoryHighWatermarkStore implements HighWatermarkStore {
  _MemoryHighWatermarkStore({this.database, this.secure});

  DateTime? database;
  DateTime? secure;
  bool tamperLatched = false;

  @override
  Future<void> latchClockTampering() async => tamperLatched = true;

  @override
  Future<DateTime?> readDatabaseWatermark() async => database;

  @override
  Future<DateTime?> readSecureWatermark() async => secure;

  @override
  Future<void> writeWatermark(DateTime value) async {
    database = value;
    secure = value;
  }
}
