import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'home_page.dart';
import 'heart_rate_page.dart';
import 'payments_page.dart';
import 'profile_page.dart';

class RootPage extends StatefulWidget {
  final BluetoothDevice device;
  const RootPage({super.key, required this.device});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(device: widget.device),
      const HeartRatePage(),
      const PaymentsPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Keeps all pages alive, only shows the selected one
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // ✅ Single Bottom Nav for the whole app
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: "Heart"),
          BottomNavigationBarItem(
              icon: Icon(Icons.credit_card), label: "Payments"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
