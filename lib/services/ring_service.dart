import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class RingService {
  RingService._privateConstructor();
  static final RingService instance = RingService._privateConstructor();

  BluetoothDevice? _device;
  StreamSubscription<List<int>>? _heartRateSub;

  final ValueNotifier<String> deviceName = ValueNotifier("Unknown Device");
  final ValueNotifier<int> heartRate = ValueNotifier(0);
  final ValueNotifier<String> statusMessage = ValueNotifier("Disconnected");

  Future<void> connectToDevice(BluetoothDevice device) async {
    _device = device;
    statusMessage.value = "Connecting...";

    try {
      await device.connect(autoConnect: false);
      statusMessage.value = "Connected ✅";

      final services = await device.discoverServices();
      for (var service in services) {
        // Device Info Service -> Device Name
        if (service.uuid.toString().toLowerCase().contains("180a")) {
          for (var c in service.characteristics) {
            if (c.uuid.toString().toLowerCase().contains("2a00")) {
              final nameBytes = await c.read();
              deviceName.value = String.fromCharCodes(nameBytes);
            }
          }
        }

        // Heart Rate Service
        if (service.uuid.toString().toLowerCase().contains("180d")) {
          for (var c in service.characteristics) {
            if (c.uuid.toString().toLowerCase().contains("2a37")) {
              await c.setNotifyValue(true);
              _heartRateSub?.cancel();
              _heartRateSub = c.lastValueStream.listen((value) {
                if (value.isNotEmpty) {
                  int bpm = value[0]; // Basic BPM read
                  heartRate.value = bpm;
                  statusMessage.value = "Heart Rate: $bpm bpm";
                  debugPrint("❤️ Ring BPM: $bpm");
                }
              });
            }
          }
        }
      }
    } catch (e) {
      statusMessage.value = "Error: $e";
      debugPrint("RingService connect error: $e");
    }
  }

  Future<void> disconnect() async {
    try {
      await _heartRateSub?.cancel();
      _heartRateSub = null;

      if (_device != null) {
        await _device!.disconnect();
      }

      statusMessage.value = "Disconnected";
    } catch (e) {
      debugPrint("RingService disconnect error: $e");
    }
  }
}
