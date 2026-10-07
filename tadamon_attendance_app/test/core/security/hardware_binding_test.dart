import 'package:flutter_test/flutter_test.dart';
import 'package:tadamon_attendance_app/core/security/hardware_fingerprint.dart';

void main() {
  test(
    'derives a stable fingerprint and separates different devices',
    () async {
      final fingerprint = CompositeHardwareFingerprint(
        salt: 'project-test-salt',
      );
      const firstDevice = HardwareFingerprintComponents(
        processorId: 'processor-a',
        motherboardId: 'board-a',
        storageSerial: 'storage-a',
        networkAdapterId: 'network-a',
      );
      const secondDevice = HardwareFingerprintComponents(
        processorId: 'processor-b',
        motherboardId: 'board-a',
        storageSerial: 'storage-a',
        networkAdapterId: 'network-a',
      );

      final first = await fingerprint.derive(firstDevice);
      expect(await fingerprint.derive(firstDevice), first);
      expect(await fingerprint.derive(secondDevice), isNot(first));
      expect(first, matches(RegExp(r'^TD-[A-F0-9]{4}-[A-F0-9]{4}$')));
    },
  );
}
