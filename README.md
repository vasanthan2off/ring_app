# Depixel App

The **Depixel App** is a Flutter-based mobile application designed to connect with the **Depixel Ring** via Bluetooth.
It allows users to view real-time health metrics, manage device settings, and experience the core features of the smart ring.

---

## 📱 Features

* Scan and connect to the Depixel Ring using Bluetooth (BLE)
* Display real-time health data (heart rate, SpO₂, temperature, etc.)
* Simple and clean user interface
* Cross-platform support (Android & iOS)

---

## 📂 Project Structure

```
lib/
 ├── screens/        # App screens (UI pages)
 ├── services/       # Bluetooth and API logic
 ├── theme/          # Styles and themes
 ├── utils/          # Helper functions
 ├── widgets/        # Reusable UI components
 └── main.dart       # App entry point
```

---

## ⚡ Tech Stack

* [Flutter](https://flutter.dev/) (Dart SDK >= 3.3.0)
* [flutter\_blue\_plus](https://pub.dev/packages/flutter_blue_plus) – Bluetooth Low Energy
* [provider](https://pub.dev/packages/provider) – State management
* [shared\_preferences](https://pub.dev/packages/shared_preferences) – Local storage
* [permission\_handler](https://pub.dev/packages/permission_handler) – Permissions

---

## 🚀 Getting Started

### Prerequisites

* Install [Flutter SDK](https://docs.flutter.dev/get-started/install)
* Android Studio / VS Code setup

### Installation

```bash
# Clone the repository
git clone https://github.com/<your-username>/depixel_app.git

# Navigate to project
cd depixel_app

# Install dependencies
flutter pub get
```

### Run the app

```bash
flutter run
```

---

## 🔒 Permissions

The app may ask for:

* **Bluetooth** – To scan and connect with the ring
* **Location** – Required for BLE scanning on Android

---

---

## 📄 License

This project is for internal use and testing purposes.
