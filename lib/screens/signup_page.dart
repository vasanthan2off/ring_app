import 'package:flutter/material.dart';
import '../utils/validators.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';
import '../widgets/custom_password_field.dart';
import '../widgets/custom_snackbar.dart';
import '../services/auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String selectedCountryCode = "+91";
  bool _loading = false;

  Future<void> _onSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final msg = await AuthService.instance.register(
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        countryCode: selectedCountryCode,
        phoneNumber: phoneController.text.trim(),
      );

      if (!mounted) return;

      CustomSnackbar.show(
        context,
        "$msg. Please check your inbox and verify your email before logging in.",
        backgroundColor: Colors.green,
      );

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        e.toString(),
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Image.asset(
                      'assets/images/signup.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const Text(
                          "Signup",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // First name + Last name in one row
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: CustomTextField(
                                hintText: "First name",
                                controller: firstNameController,
                                validator: (v) => v == null || v.isEmpty
                                    ? "Enter first name"
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: CustomTextField(
                                hintText: "Last name",
                                controller: lastNameController,
                                validator: (v) => v == null || v.isEmpty
                                    ? "Enter last name"
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Email
                        CustomTextField(
                          hintText: "Enter your email",
                          controller: emailController,
                          validator: Validators.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        // Country code + phone
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: DropdownButton<String>(
                                  value: selectedCountryCode,
                                  underline: const SizedBox(),
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                      value: "+91",
                                      child: Text("+91 (IN)"),
                                    ),
                                    DropdownMenuItem(
                                      value: "+1",
                                      child: Text("+1 (US)"),
                                    ),
                                    DropdownMenuItem(
                                      value: "+44",
                                      child: Text("+44 (UK)"),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => selectedCountryCode = v);
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 4,
                              child: CustomTextField(
                                hintText: "Phone number",
                                controller: phoneController,
                                validator: Validators.phone,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Password
                        CustomPasswordField(controller: passwordController),
                        const SizedBox(height: 20),

                        // Signup button
                        CustomButton(
                          text: _loading ? "Creating..." : "Signup",
                          onPressed: _loading ? null : _onSignup,
                        ),
                        const SizedBox(height: 12),

                        // Go to Login
                        CustomButton(
                          text: "Login",
                          backgroundColor: Colors.grey[300],
                          textColor: Colors.black,
                          onPressed: () =>
                              Navigator.pushNamed(context, '/login'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
