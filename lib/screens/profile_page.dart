import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String gender = "Female";
  int age = 28;
  int height = 165;
  int weight = 60;

  void _openEditDialog() {
    final genderController = TextEditingController(text: gender);
    final ageController = TextEditingController(text: age.toString());
    final heightController = TextEditingController(text: height.toString());
    final weightController = TextEditingController(text: weight.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: genderController,
                decoration: const InputDecoration(labelText: "Gender"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: "Height (cm)"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: "Weight (kg)"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                gender = genderController.text;
                age = int.tryParse(ageController.text) ?? age;
                height = int.tryParse(heightController.text) ?? height;
                weight = int.tryParse(weightController.text) ?? weight;
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Row(
                children: const [
                  Icon(Icons.arrow_back, color: Colors.black),
                  Expanded(
                    child: Text(
                      "Profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(width: 24),
                ],
              ),
              const SizedBox(height: 20),

              // Avatar
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/images/profile.png"),
                backgroundColor: Colors.transparent,
              ),
              const SizedBox(height: 12),

              // Name + subtitle
              const Text(
                "Sophia Carter",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "$gender, $age",
                style: const TextStyle(color: Colors.blue, fontSize: 14),
              ),
              TextButton(
                onPressed: _openEditDialog,
                child: const Text(
                  "Edit",
                  style: TextStyle(color: Colors.blue),
                ),
              ),

              const SizedBox(height: 20),

              // Personal Info
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Personal Information",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow("Gender", gender),
                    _infoRow("Age", "$age"),
                    _infoRow("Height", "$height cm"),
                    _infoRow("Weight", "$weight kg"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Health Goals
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Health Goals",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              _arrowRow("Set Goals", onTap: () {
                Navigator.pushNamed(context, "/setgoals");
              }),

              const SizedBox(height: 20),

              // Data Sync
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Data Sync",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              _arrowRow("Apple Health", onTap: () {
                Navigator.pushNamed(context, "/applehealth");
              }),
              _arrowRow("Google Fit", onTap: () {
                Navigator.pushNamed(context, "/googlefit");
              }),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, color: Colors.blue)),
        ],
      ),
    );
  }

  Widget _arrowRow(String title, {required VoidCallback onTap}) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, color: Colors.black),
      ),
      trailing: const Icon(Icons.arrow_forward, size: 20, color: Colors.black87),
      onTap: onTap,
    );
  }
}
