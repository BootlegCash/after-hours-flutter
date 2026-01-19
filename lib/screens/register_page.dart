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

  // ✅ NEW: must accept terms
  bool agreedToTerms = false;

  // ✅ Simple Terms text
  static const String _termsText = '''
Terms, Safety & Responsibility Agreement

By creating an account, you acknowledge and agree:

• You are at least 21 years old (or the legal drinking age in your location).
• This app is for social tracking and entertainment only.
• Alcohol carries health and safety risks.
• Never drink and drive. Always drink responsibly.
• This app does not encourage, endorse, or promote excessive drinking.
• You are responsible for your actions and alcohol consumption.
• The creators are not liable for any injury, damage, legal issues, or harm related to alcohol use.
• This app does not provide medical, legal, or health advice.
• Gamified ranks/points are optional.
• You will follow local laws and use the app safely and lawfully.
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
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7,
              maxWidth: 520,
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close, color: Colors.white70),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        _termsText,
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.3,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "Close",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _register() async {
    // ✅ Block register if terms not accepted
    if (!agreedToTerms) {
      setState(() {
        errorMessage =
            "You must accept the Terms & Safety agreement to continue.";
      });
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
            builder: (_) => LoginPage(apiService: widget.apiService),
          ),
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
        err.forEach((key, value) {
          parts.add("$key: $value");
        });
        msg = parts.join("\n");
      }

      setState(() {
        isLoading = false;
        errorMessage = msg;
      });
    }
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
            colors: [
              Color(0xFF0f0c29),
              Color(0xFF302b63),
              Color(0xFF24243e),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "After Hours",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent.withOpacity(0.9),
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: Colors.pinkAccent.withOpacity(0.9),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: usernameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Colors.cyanAccent,
                            ),
                            labelText: "Username",
                            labelStyle:
                                const TextStyle(color: Colors.cyanAccent),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.07),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        TextField(
                          controller: displayNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.nightlife_outlined,
                              color: Colors.cyanAccent,
                            ),
                            labelText: "Display Name",
                            labelStyle:
                                const TextStyle(color: Colors.cyanAccent),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.07),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Colors.cyanAccent,
                            ),
                            labelText: "Email",
                            labelStyle:
                                const TextStyle(color: Colors.cyanAccent),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.07),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.cyanAccent,
                            ),
                            labelText: "Password",
                            labelStyle:
                                const TextStyle(color: Colors.cyanAccent),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.07),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),

                        TextField(
                          controller: confirmPasswordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock_person_outlined,
                              color: Colors.cyanAccent,
                            ),
                            labelText: "Confirm Password",
                            labelStyle:
                                const TextStyle(color: Colors.cyanAccent),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.07),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ✅ NEW: Terms checkbox (required)
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.12)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: agreedToTerms,
                                activeColor: Colors.pinkAccent,
                                checkColor: Colors.white,
                                onChanged: (val) {
                                  setState(() {
                                    agreedToTerms = val ?? false;
                                    if (agreedToTerms) errorMessage = null;
                                  });
                                },
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Wrap(
                                    children: [
                                      const Text(
                                        "I agree to the ",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13),
                                      ),
                                      GestureDetector(
                                        onTap: _showTermsDialog,
                                        child: const Text(
                                          "Terms & Safety agreement",
                                          style: TextStyle(
                                            color: Colors.cyanAccent,
                                            fontSize: 13,
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const Text(
                                        ".",
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        if (errorMessage != null)
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ✅ Register button disabled until terms accepted
                  GestureDetector(
                    onTap: canSubmit ? _register : null,
                    child: Opacity(
                      opacity: canSubmit ? 1.0 : 0.55,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 60),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.pinkAccent, Colors.cyanAccent],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.pinkAccent.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "CREATE ACCOUNT",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LoginPage(apiService: widget.apiService),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Already have an account? Log In",
                      style: TextStyle(
                        color: Colors.white70,
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
