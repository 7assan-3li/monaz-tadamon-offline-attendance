final class AthleticEntitlementResult {
  const AthleticEntitlementResult({
    required this.entitlementDays,
    required this.attendanceRate,
    required this.disciplineStatus,
  });

  final int entitlementDays;
  final double attendanceRate;
  final String disciplineStatus;
}

class CalculateEntitlementUseCase {
  const CalculateEntitlementUseCase();

  AthleticEntitlementResult call({
    required int totalSessions,
    required int presentCount,
    required int excusedCount,
    required int unexcusedCount,
    required int lateCount,
  }) {
    if (totalSessions <= 0) {
      return const AthleticEntitlementResult(
        entitlementDays: 0,
        attendanceRate: 0.0,
        disciplineStatus: 'لا توجد حصص مسجلة',
      );
    }

    // Athletic entitlement represents qualified physical sessions.
    final entitlementDays = presentCount;

    final attendanceRate = (presentCount / totalSessions) * 100;

    final String disciplineStatus;
    if (unexcusedCount >= 3) {
      disciplineStatus = 'تنبيه انضباطي بسبب الغياب';
    } else if (attendanceRate >= 80.0) {
      disciplineStatus = 'مؤهل للمشاركة الرسمية';
    } else if (attendanceRate >= 50.0) {
      disciplineStatus = 'تحت التقييم الفني';
    } else {
      disciplineStatus = 'غير مؤهل للمباريات الرسمية';
    }

    return AthleticEntitlementResult(
      entitlementDays: entitlementDays,
      attendanceRate: double.parse(attendanceRate.toStringAsFixed(1)),
      disciplineStatus: disciplineStatus,
    );
  }
}
