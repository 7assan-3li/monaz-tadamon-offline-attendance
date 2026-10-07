import 'package:flutter/services.dart';
import 'package:tadamon_attendance_app/core/security/hardware_fingerprint.dart';

final class AndroidHardwareComponentsSource {
  const AndroidHardwareComponentsSource({
    this.channel = const MethodChannel('com.monaz.tadamon/device_hardware'),
  });

  final MethodChannel channel;

  Future<HardwareFingerprintComponents> read() async {
    final values = await channel.invokeMapMethod<String, String>(
      'getHardwareComponents',
    );
    if (values == null) {
      throw const FormatException('تعذر قراءة مكونات الجهاز.');
    }
    return HardwareFingerprintComponents(
      processorId: values['processorId'] ?? '',
      motherboardId: values['motherboardId'] ?? '',
      storageSerial: values['storageSerial'] ?? '',
      networkAdapterId: values['networkAdapterId'] ?? '',
    );
  }
}
