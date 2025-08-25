import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => "AuthException: $message";
}

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  static const String baseUrl = "https://www.auth.nivaring.com";

  String? _accessToken;
  String? _refreshToken;

  // Save tokens (in memory only for now)
  Future<void> _saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
  }

  // Load tokens (no persistence for now)
  Future<void> loadTokens() async {
    // TODO: Implement persistence later (e.g., SharedPreferences, Hive, SecureStorage)
  }

  // ----------------------
  // REGISTER
  // ----------------------
  Future<String> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String countryCode,
    required String phoneNumber,
  }) async {
    final url = Uri.parse("$baseUrl/auth/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "password": password,
        "country_code": countryCode,
        "phone_number": phoneNumber,
      }),
    );

    final data = _parse(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data["message"] ?? "Registered successfully. Check your email.";
    }

    _handleError(response, data, fallback: "Failed to register");
  }

  // ----------------------
  // LOGIN
  // ----------------------
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = _parse(response);

    if (response.statusCode == 200) {
      await _saveTokens(data["access_token"], data["refresh_token"]);
      return "Login successful";
    }

    _handleError(response, data, fallback: "Login failed");
  }

  // ----------------------
  // GET USER INFO
  // ----------------------
  Future<Map<String, dynamic>> me() async {
    if (_accessToken == null) throw AuthException("Not logged in");

    final url = Uri.parse("$baseUrl/auth/me");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_accessToken"
      },
    );

    final data = _parse(response);

    if (response.statusCode == 200) {
      return data;
    }

    _handleError(response, data, fallback: "Failed to fetch user");
  }

  // ----------------------
  // VERIFY EMAIL
  // ----------------------
  Future<String> verifyEmail(String token) async {
    final url = Uri.parse("$baseUrl/auth/verify-email?token=$token");

    final response = await http.get(url);
    final data = _parse(response);

    if (response.statusCode == 200) {
      return data["message"] ?? "Email verified successfully.";
    }

    _handleError(response, data, fallback: "Email verification failed");
  }

  // ----------------------
  // RESEND VERIFICATION
  // ----------------------
  Future<String> resendVerification(String email) async {
    final url = Uri.parse("$baseUrl/auth/resend-verification");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    final data = _parse(response);

    if (response.statusCode == 200) {
      return data["message"] ?? "Verification email resent";
    }

    _handleError(response, data, fallback: "Failed to resend verification");
  }

  // ----------------------
  // LOGOUT
  // ----------------------
  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
  }

  // ----------------------
  // HELPERS
  // ----------------------
  Map<String, dynamic> _parse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Never _handleError(http.Response response, Map<String, dynamic> data,
      {String fallback = "Something went wrong"}) {
    final msg = data["error"] ??
        data["message"] ??
        "HTTP ${response.statusCode}: $fallback";
    throw AuthException(msg);
  }
}
