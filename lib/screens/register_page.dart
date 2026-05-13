import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';
import 'package:after_hours/main.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  final ApiService apiService;
  const RegisterPage({super.key, required this.apiService});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final displayNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;
  bool agreedToTerms = false;

  static const String _termsText = '''
Terms, Safety & Responsibility Agreement

By creating an account, you acknowledge and agree:

- You are at least 21 years old (or the legal drinking age in your location).
- This app is for social tracking and entertainment only.
- Alcohol carries health and safety risks.
- Never drink and drive. Always drink responsibly.
- This app does not encourage, endorse, or promote excessive drinking.
- You are responsible for your actions and alcohol consumption.
- The creators are not liable for any injury, damage, legal issues, or harm related to alcohol use.
- This app does not provide medical, legal, or health advice.
- Gamified ranks/points are optional.
- You will follow local laws and use the app safely and lawfully.
''';

  @override
  void dispose() {
    usernameController.dispose();
    displayNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _showTermsDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF1c1842),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7,
            maxWidth: 520,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Terms & Safety",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close, color: Colors.white54),
                    ),
                  ],
                ),
                Divider(color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _termsText,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          height: 1.5,
                          fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Colors.pinkAccent, Colors.cyanAccent]),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Center(
                      child: Text('Close',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
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

  Future<void> _register() async {
    if (!agreedToTerms) {
      setState(() => errorMessage =
          "You must accept the Terms & Safety agreement to continue.");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final username = usernameController.text.trim();
    final displayName = displayNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final password2 = confirmPasswordController.text.trim();

    if (username.isEmpty ||
        displayName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        password2.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = "Please fill out all fields.";
      });
      return;
    }

    if (password != password2) {
      setState(() {
        isLoading = false;
        errorMessage = "Passwords do not match.";
      });
      return;
    }

    final result = await widget.apiService.register(
      username: username,
      email: email,
      password: password,
      password2: password2,
      displayName: displayName,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      final loggedIn = await widget.apiService.login(username, password);
      if (!mounted) return;
      if (loggedIn) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainAppWrapper(
              apiService: widget.apiService,
              initialIndex: 4,
            ),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => LoginPage(apiService: widget.apiService)),
          (route) => false,
        );
      }
    } else {
      final err = result['error'];
      String msg = "Registration failed.";
      if (err is String) {
        msg = err;
      } else if (err is Map) {
        final parts = <String>[];
        err.forEach((key, value) => parts.add("$key: $value"));
        msg = parts.join("\n");
      }
      setState(() {
        isLoading = false;
        errorMessage = msg;
      });
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.cyanAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canSubmit = !isLoading && agreedToTerms;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.pinkAccent, Colors.cyanAccent],
                    ).createShader(bounds),
                    child: const Text(
                      "After Hours",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Create your account",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 15),
                  ),

                  const SizedBox(height: 32),

                  // Form card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Column(
                      children: [
                        _field(
                          controller: usernameController,
                          label: 'Username',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 14),
                        _field(
                          controller: displayNameController,
                          label: 'Display Name',
                          icon: Icons.nightlife_outlined,
                        ),
                        const SizedBox(height: 14),
                        _field(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.email_outlined,
                          keyboard: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),
                        _field(
                          controller: passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          obscure: true,
                        ),
                        const SizedBox(height: 14),
                        _field(
                          controller: confirmPasswordController,
                          label: 'Confirm Password',
                          icon: Icons.lock_person_outlined,
                          obscure: true,
                        ),

                        const SizedBox(height: 16),

                        // Terms checkbox
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: agreedToTerms
                                    ? Colors.pinkAccent.withOpacity(0.4)
                                    : Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: agreedToTerms,
                                activeColor: Colors.pinkAccent,
                                checkColor: Colors.white,
                                side: BorderSide(
                                    color: Colors.white.withOpacity(0.3)),
                                onChanged: (val) {
                                  setState(() {
                                    agreedToTerms = val ?? false;
                                    if (agreedToTerms) errorMessage = null;
                                  });
                                },
                              ),
                              Expanded(
                                child: Wrap(
                                  children: [
                                    Text(
                                      "I agree to the ",
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 13),
                                    ),
                                    GestureDetector(
                                      onTap: _showTermsDialog,
                                      child: const Text(
                                        "Terms & Safety",
                                        style: TextStyle(
                                          color: Colors.cyanAccent,
                                          fontSize: 13,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      " agreement.",
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.redAccent.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.redAccent, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(
                                        color: Colors.redAccent, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Register button
                  GestureDetector(
                    onTap: canSubmit ? _register : null,
                    child: Opacity(
                      opacity: canSubmit ? 1.0 : 0.45,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 17),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.pinkAccent, Colors.cyanAccent],
                          ),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: canSubmit
                              ? [
                                  BoxShadow(
                                    color: Colors.pinkAccent.withOpacity(0.45),
                                    blurRadius: 24,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text(
                                  "CREATE ACCOUNT",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                LoginPage(apiService: widget.apiService)),
                        (route) => false,
                      );
                    },
                    child: Text(
                      "Already have an account? Log In",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
