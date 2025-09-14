import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // ✅ Needed for device argument

import 'theme/app_theme.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/bluetooth_connect_page.dart';
import 'screens/root_page.dart'; // ✅ Add root page

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DePixelApp());
}

class DePixelApp extends StatelessWidget {
  const DePixelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DePixel',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/bluetooth': (context) => const BluetoothConnectPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final device = settings.arguments as BluetoothDevice;
          return MaterialPageRoute(
            builder: (context) => RootPage(device: device), // ✅ use RootPage
          );
        }
        return null;
      },
    );
  }
}
