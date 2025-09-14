import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_snackbar.dart';
import '../services/bluetooth_helper.dart';

class BluetoothConnectPage extends StatefulWidget {
  const BluetoothConnectPage({super.key});

  @override
  State<BluetoothConnectPage> createState() => _BluetoothConnectPageState();
}

class _BluetoothConnectPageState extends State<BluetoothConnectPage> {
  bool _scanning = false;
  final List<ScanResult> _devicesList = [];

  /// Start scanning
  Future<void> _startScan() async {
    bool granted = await BluetoothHelper.requestPermissions();
    if (!granted) {
      CustomSnackbar.show(context, "Bluetooth permissions not granted",
          backgroundColor: Colors.red);
      return;
    }

    var state = await FlutterBluePlus.adapterState.first;
    if (state != BluetoothAdapterState.on) {
      CustomSnackbar.show(context, "Please enable Bluetooth",
          backgroundColor: Colors.red);
      return;
    }

    setState(() {
      _scanning = true;
      _devicesList.clear();
    });

    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    FlutterBluePlus.scanResults.listen((results) {
      for (var r in results) {
        if (!_devicesList.any((d) => d.device.id == r.device.id)) {
          debugPrint(
              "Found device: ${r.advertisementData.localName.isNotEmpty ? r.advertisementData.localName : r.device.name} (${r.device.id})");
          setState(() => _devicesList.add(r));
        }
      }
    }).onError((e) {
      CustomSnackbar.show(context, "Scan error: $e",
          backgroundColor: Colors.red);
    });

    FlutterBluePlus.isScanning.listen((scanning) {
      setState(() => _scanning = scanning);
    });
  }

  /// Connect to device and go to RootPage (with bottom nav)
  Future<void> _connectToDevice(ScanResult result) async {
    try {
      FlutterBluePlus.stopScan();

      final displayName = result.advertisementData.localName.isNotEmpty
          ? result.advertisementData.localName
          : (result.device.name.isNotEmpty ? result.device.name : "Unknown");

      debugPrint("Connecting to $displayName (${result.device.id})...");
      await result.device.connect(timeout: const Duration(seconds: 10));

      CustomSnackbar.show(context, "Connected to $displayName",
          backgroundColor: Colors.green);

      if (mounted) {
        // ✅ Navigate into RootPage (with nav bar) instead of HomePage directly
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: result.device,
        );
      }
    } catch (e) {
      debugPrint("Connection failed: $e");
      CustomSnackbar.show(context, "Connection failed: $e",
          backgroundColor: Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double radarRadius = size.width * 0.35;

    return Scaffold(
      appBar: AppBar(
        title: const Text("DePixel Radar",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset("assets/images/ring_center.png",
                    width: size.width * 0.85),
                ..._devicesList.asMap().entries.map((entry) {
                  int index = entry.key;
                  ScanResult result = entry.value;

                  final displayName = result.advertisementData.localName.isNotEmpty
                      ? result.advertisementData.localName
                      : (result.device.name.isNotEmpty
                      ? result.device.name
                      : "Unknown");

                  double angle = (2 * pi / _devicesList.length) * index;
                  double radius = radarRadius * 0.8;
                  double x = (size.width / 2) + radius * cos(angle) - 20;
                  double y = (size.height / 2.5) + radius * sin(angle) - 20;

                  return Positioned(
                    left: x,
                    top: y,
                    child: GestureDetector(
                      onTap: () => _connectToDevice(result),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.purple, width: 2),
                            ),
                            child: Image.asset("assets/images/ring_small.png",
                                height: 40),
                          ),
                          Text(
                            displayName,
                            style: const TextStyle(fontSize: 10),
                          ),
                          Text(result.device.id.toString(),
                              style: const TextStyle(
                                  fontSize: 8, color: Colors.grey)),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
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
