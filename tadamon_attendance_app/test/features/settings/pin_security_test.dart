import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/security/pin_security.dart';

void main() {
  final security = PinSecurity();

  test('hashes a four-digit PIN with a random salt and verifies it', () async {
    final first = await security.hash('1959');
    final second = await security.hash('1959');
    expect(first, isNot(second));
    expect(first, isNot(contains('1959')));
    expect(await security.verify('1959', first), isTrue);
    expect(await security.verify('0000', first), isFalse);
  });

  test('rejects malformed PIN values and stored hashes', () async {
    expect(() => security.hash('12345'), throwsFormatException);
    expect(await security.verify('abcd', 'invalid'), isFalse);
    expect(await security.verify('1234', 'invalid'), isFalse);
  });
}
