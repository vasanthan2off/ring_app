import 'package:flutter/foundation.dart';

class RingDataProvider extends ChangeNotifier {
  String _ringName = "Not Connected";
  int _heartRate = 0;
  int _steps = 0;
  int _batteryLevel = 0;

  String get ringName => _ringName;
  int get heartRate => _heartRate;
  int get steps => _steps;
  int get batteryLevel => _batteryLevel;

  void updateRingName(String name) {
    _ringName = name;
    notifyListeners();
  }

  void updateHeartRate(int value) {
    _heartRate = value;
    notifyListeners();
  }

  void updateSteps(int value) {
    _steps = value;
    notifyListeners();
  }

  void updateBatteryLevel(int value) {
    _batteryLevel = value;
    notifyListeners();
  }
}
