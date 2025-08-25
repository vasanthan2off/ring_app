// services/bluetooth_helper.dart
import 'package:permission_handler/permission_handler.dart';

class BluetoothHelper {
  static Future<bool> requestPermissions() async {
    final permissions = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];

    for (final p in permissions) {
      final status = await p.request();
      if (!status.isGranted) return false;
    }
    return true;
  }

  static Future<bool> hasPermissions() async {
    return await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.locationWhenInUse.isGranted;
  }
}
