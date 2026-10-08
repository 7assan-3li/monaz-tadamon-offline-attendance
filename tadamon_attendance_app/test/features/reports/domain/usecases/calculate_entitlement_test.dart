import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/features/reports/domain/usecases/calculate_entitlement_use_case.dart';

void main() {
  group('CalculateEntitlementUseCase (Strict Athletic & Disciplinary Qualification)', () {
    const useCase = CalculateEntitlementUseCase();

    test('returns zero entitlement when total sessions is 0', () {
      final result = useCase(
        totalSessions: 0,
        presentCount: 0,
        excusedCount: 0,
        unexcusedCount: 0,
        lateCount: 0,
      );

      expect(result.entitlementDays, 0);
      expect(result.attendanceRate, 0.0);
      expect(result.disciplineStatus, 'لا توجد حصص مسجلة');
    });

    test('calculates full qualification for high attendance (>= 80%)', () {
      final result = useCase(
        totalSessions: 10,
        presentCount: 9,
        excusedCount: 1,
        unexcusedCount: 0,
        lateCount: 0,
      );

      expect(result.entitlementDays, 9);
      expect(result.attendanceRate, 90.0);
      expect(result.disciplineStatus, 'مؤهل للمشاركة الرسمية');
    });

    test('flags disciplinary warning when unexcused absences >= 3', () {
      final result = useCase(
        totalSessions: 12,
        presentCount: 8,
        excusedCount: 1,
        unexcusedCount: 3,
        lateCount: 0,
      );

      expect(result.entitlementDays, 8);
      expect(result.disciplineStatus, 'تنبيه انضباطي بسبب الغياب');
    });

    test('assigns technical evaluation for medium attendance (50% - 79%)', () {
      final result = useCase(
        totalSessions: 10,
        presentCount: 6,
        excusedCount: 2,
        unexcusedCount: 2,
        lateCount: 0,
      );

      expect(result.entitlementDays, 6);
      expect(result.attendanceRate, 60.0);
      expect(result.disciplineStatus, 'تحت التقييم الفني');
    });

    test('disqualifies players with attendance < 50%', () {
      final result = useCase(
        totalSessions: 10,
        presentCount: 4,
        excusedCount: 4,
        unexcusedCount: 2,
        lateCount: 0,
      );

      expect(result.entitlementDays, 4);
      expect(result.attendanceRate, 40.0);
      expect(result.disciplineStatus, 'غير مؤهل للمباريات الرسمية');
    });
  });
}
