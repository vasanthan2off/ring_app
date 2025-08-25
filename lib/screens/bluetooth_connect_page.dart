import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../services/bluetooth_helper.dart';
import '../services/ring_data_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import 'home_page.dart';

class BluetoothConnectPage extends StatefulWidget {
  const BluetoothConnectPage({super.key});

  @override
  State<BluetoothConnectPage> createState() => _BluetoothConnectPageState();
}

class _BluetoothConnectPageState extends State<BluetoothConnectPage> {
  bool _scanning = false;
  final List<BluetoothDevice> _devices = [];

  Future<void> _startScan() async {
    bool granted = await BluetoothHelper.requestPermissions();
    if (!granted) {
      CustomSnackbar.show(
        context,
        "Bluetooth permissions not granted",
        backgroundColor: Colors.red,
      );
      return;
    }

    var state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      CustomSnackbar.show(
        context,
        "Please enable Bluetooth",
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _scanning = true;
      _devices.clear();
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));

    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!_devices.contains(r.device)) {
          setState(() => _devices.add(r.device));
        }
      }
    });

    Future.delayed(const Duration(seconds: 8), () {
      FlutterBluePlus.stopScan();
      if (mounted) setState(() => _scanning = false);
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      if (mounted) {
        CustomSnackbar.show(
          context,
          "Connected to ${device.name.isNotEmpty ? device.name : "device"}",
          backgroundColor: Colors.green,
        );

        // ✅ Discover services & subscribe
        List<BluetoothService> services = await device.discoverServices();
        for (var service in services) {
          for (var characteristic in service.characteristics) {
            final uuid = characteristic.uuid.toString();

            // 🫀 Heart Rate (UUID 0x2A37 usually)
            if (uuid.contains("2a37")) {
              await characteristic.setNotifyValue(true);
              characteristic.lastValueStream.listen((value) {
                if (value.isNotEmpty) {
                  int hr = value[1]; // byte 1 → heart rate value
                  Provider.of<RingDataProvider>(context, listen: false)
                      .updateHeartRate(hr);
                }
              });
            }

            // 🔋 Battery Level (UUID 0x2A19)
            else if (uuid.contains("2a19")) {
              await characteristic.setNotifyValue(true);
              characteristic.lastValueStream.listen((value) {
                if (value.isNotEmpty) {
                  int battery = value[0]; // byte 0 → battery %
                  Provider.of<RingDataProvider>(context, listen: false)
                      .updateBatteryLevel(battery);
                }
              });
            }

            // 👣 Steps (replace UUID with your ring’s actual UUID)
            else if (uuid.contains("xxxx")) {
              await characteristic.setNotifyValue(true);
              characteristic.lastValueStream.listen((value) {
                int steps = _bytesToInt(value);
                Provider.of<RingDataProvider>(context, listen: false)
                    .updateSteps(steps);
              });
            }
          }
        }

        // ✅ Go to HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Connection failed: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  int _bytesToInt(List<int> bytes) {
    int result = 0;
    for (int i = 0; i < bytes.length; i++) {
      result |= (bytes[i] << (8 * i));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "DePixel Radar",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Radar background image
                  Image.asset(
                    "assets/images/ring_center.png",
                    width: size.width * 0.9,
                  ),

                  // Devices plotted around
                  ..._devices.asMap().entries.map((entry) {
                    int index = entry.key;
                    BluetoothDevice device = entry.value;

                    double angle =
                        (2 * pi / (_devices.isEmpty ? 1 : _devices.length)) *
                            index;
                    double radius = 120;

                    return Positioned(
                      left: (size.width / 2) + radius * cos(angle) - 20,
                      top: (size.height / 3) + radius * sin(angle) - 20,
                      child: GestureDetector(
                        onTap: () => _connectToDevice(device),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.purple, width: 2),
                              ),
                              child: Image.asset(
                                "assets/images/ring_small.png",
                                height: 40,
                              ),
                            ),
                            Text(
                              device.name.isNotEmpty
                                  ? device.name
                                  : "Unknown",
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Scan button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: _scanning ? "Scanning..." : "Scan Now",
                onPressed: _scanning ? null : _startScan,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
