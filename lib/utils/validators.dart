class Validators {
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return "Email is required";
    final r = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!r.hasMatch(v.trim())) return "Enter a valid email";
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return "Password is required";
    if (v.length < 6) return "At least 6 characters";
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.isEmpty) return "Phone number is required";
    final r = RegExp(r'^[0-9]{10,15}$');
    if (!r.hasMatch(v)) return "Enter a valid phone number";
    return null;
  }
}
