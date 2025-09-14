import 'package:flutter/material.dart';

class PaymentsPage extends StatefulWidget {
  const PaymentsPage({super.key});

  @override
  State<PaymentsPage> createState() => _PaymentsPageState();
}

class _PaymentsPageState extends State<PaymentsPage> {
  bool _nfcEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payments",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// NFC Section
            const Text(
              "NFC Payments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enable NFC Payments",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Pay with your ring at any contactless terminal",
                        style: TextStyle(color: Colors.grey),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _nfcEnabled,
                  onChanged: (value) {
                    setState(() {
                      _nfcEnabled = value;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// Crypto Section
            const Text(
              "Crypto",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Crypto Wallet"),
              trailing: const Icon(Icons.arrow_forward, size: 20, color: Colors.black),
              onTap: () {
                Navigator.pushNamed(context, '/cryptoWallet');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Buy Crypto"),
              trailing: const Icon(Icons.arrow_forward, size: 20, color: Colors.black),
              onTap: () {
                Navigator.pushNamed(context, '/buyCrypto');
              },
            ),
          ],
        ),
      ),
    );
  }
}
