import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/home_page.dart';
import 'screens/bluetooth_connect_page.dart';
import 'services/ring_data_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => RingDataProvider(),
      child: const DePixelApp(),
    ),
  );
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
        '/home': (context) => const HomePage(),
      },
    );
  }
}
