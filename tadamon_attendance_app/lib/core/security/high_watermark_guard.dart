abstract interface class HighWatermarkStore {
  Future<DateTime?> readDatabaseWatermark();

  Future<DateTime?> readSecureWatermark();

  Future<void> writeWatermark(DateTime value);

  Future<void> latchClockTampering();
}

final class ClockTamperedException implements Exception {
  const ClockTamperedException();

  @override
  String toString() =>
      'تم رصد تراجع في ساعة النظام! يرجى تصحيح التاريخ للمتابعة.';
}

final class HighWatermarkGuard {
  HighWatermarkGuard({required this.store, DateTime Function()? currentTime})
    : _currentTime = currentTime ?? DateTime.now;

  final HighWatermarkStore store;
  final DateTime Function() _currentTime;

  Future<DateTime> verifyAndAdvance() async {
    final now = _currentTime().toUtc();
    final databaseWatermark = (await store.readDatabaseWatermark())?.toUtc();
    final secureWatermark = (await store.readSecureWatermark())?.toUtc();
    final storedWatermark = _latest(databaseWatermark, secureWatermark);

    if (storedWatermark != null && now.isBefore(storedWatermark)) {
      await store.latchClockTampering();
      throw const ClockTamperedException();
    }

    await store.writeWatermark(now);
    return now;
  }

  DateTime? _latest(DateTime? first, DateTime? second) {
    if (first == null) return second;
    if (second == null) return first;
    return first.isAfter(second) ? first : second;
  }
}
