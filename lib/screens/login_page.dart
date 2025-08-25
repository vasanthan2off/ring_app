import 'package:flutter/material.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_password_field.dart';
import '../services/auth_service.dart';
import '../widgets/custom_snackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _loading = false;

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final msg = await AuthService.instance.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      CustomSnackbar.show(
        context,
        msg, // "Login successful"
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      // ✅ Navigate to Home after login success
      Navigator.pushNamedAndRemoveUntil(context, '/bluetooth', (_) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        e.message,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Unexpected error. Please try again.",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // ✅ Logo / Image
                Center(
                  child: Image.asset(
                    'assets/images/login.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 32),

                // ✅ Title
                const Text(
                  "Login",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // ✅ Email field
                CustomTextField(
                  hintText: "Enter your email",
                  controller: emailController,
                  validator: Validators.email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // ✅ Password field
                CustomPasswordField(
                  controller: passwordController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) =>
                  !_loading ? _onLogin() : null, // Press enter to login
                ),
                const SizedBox(height: 24),

                // ✅ Login button
                CustomButton(
                  text: _loading ? "Logging in..." : "Login",
                  onPressed: _loading ? null : _onLogin,
                ),
                const SizedBox(height: 16),

                // ✅ Signup button
                CustomButton(
                  text: "Signup",
                  backgroundColor: Colors.grey[300],
                  textColor: Colors.black,
                  onPressed: () =>
                      Navigator.pushNamed(context, '/signup'),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
