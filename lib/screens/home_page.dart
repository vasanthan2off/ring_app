import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../services/auth_service.dart';
import '../widgets/custom_button.dart';
import '../services/ring_service.dart';

class HomePage extends StatefulWidget {
  final BluetoothDevice device;
  const HomePage({super.key, required this.device});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    _loadUser();
    // ✅ Use RingService to connect
    RingService.instance.connectToDevice(widget.device);
  }

  Future<void> _loadUser() async {
    try {
      final u = await AuthService.instance.me();
      if (mounted) setState(() => user = u);
    } catch (_) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    }
  }

  @override
  void dispose() {
    RingService.instance.disconnect();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  Widget _infoCard(String title, String value,
      {String suffix = "", bool isLarge = false, Color? color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 6),
          Text(
            "$value$suffix",
            style: TextStyle(
              fontSize: isLarge ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = (user != null)
        ? "${user!['first_name'] ?? ''} ${user!['last_name'] ?? ''}"
        : "Fetching...";

    return Scaffold(
      backgroundColor: const Color(0xfff9f9f9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Image.asset("assets/images/ring_logo.png", height: 32),
            const SizedBox(width: 8),
            // Hardcode device name for now
            const Text(
              "Depixel Ring",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "Logout",
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Profile
            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage("assets/images/profile.png"),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _getGreeting(),
                      style: const TextStyle(color: Colors.purple),
                    ),
                    if (user != null)
                      Text(
                        "Email: ${user!['email'] ?? '-'}",
                        style: const TextStyle(color: Colors.black54),
                      ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 16),

            // Hardcode status for now
            const Text(
              "Status: Connected ✅",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            /// Activity Section
            _sectionTitle("Activity"),
            Row(
              children: [
                Expanded(
                  // ✅ Heart rate from RingService
                  child: ValueListenableBuilder(
                    valueListenable: RingService.instance.heartRate,
                    builder: (_, bpm, __) => _infoCard(
                      "Heart Rate",
                      "$bpm",
                      suffix: " bpm",
                      isLarge: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _infoCard("Steps", "1200", isLarge: true), // hardcoded
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Sleep Section
            _sectionTitle("Sleep"),
            _infoCard("Sleep Score", "85", isLarge: true), // hardcoded

            const SizedBox(height: 24),

            /// Ring Section
            _sectionTitle("Ring"),
            _infoCard("Battery", "75", suffix: "%", isLarge: true), // hardcoded

            const SizedBox(height: 32),

            /// View More Button
            CustomButton(
              text: "View More Insights",
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await AuthService.instance.logout();
    } catch (_) {}
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Logged out successfully"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
