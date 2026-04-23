import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';
import 'package:after_hours/main.dart';
import 'register_page.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  final ApiService apiService;
  const LoginPage({super.key, required this.apiService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String? errorMessage;

  // ============================================================
  // ✅ PUT YOUR NEW ROTATED KEY HERE (replace the string below)
  // ============================================================
  static const String _gateKey = "ah_9f8d2c1b6a3e4f7a8c0d_very_secret";

  // This builds: https://www.afterhoursranked.com/accounts/password_reset
  Uri get _resetUri => Uri.https(
        "www.afterhoursranked.com",
        "/accounts/password_reset/",
        {"k": _gateKey},
      );

  Future<void> _openResetPassword() async {
    setState(() => errorMessage = null);

    final uri = _resetUri;

    try {
      final canOpen = await canLaunchUrl(uri);
      if (!canOpen) {
        if (!mounted) return;
        setState(() => errorMessage = "Can't open reset page on this device.");
        return;
      }

      // iOS: in-app Safari sheet is usually the most reliable
      final ok = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);

      // Fallback: external Safari
      if (!ok) {
        final ok2 = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!ok2 && mounted) {
          setState(() => errorMessage = "Couldn't open reset page. Try again.");
        }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => errorMessage = "Reset link failed to open. Try again.");
    }
  }

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final success = await widget.apiService.login(
      usernameController.text.trim(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
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
      setState(() {
        isLoading = false;
        errorMessage = "Invalid username or password.";
      });
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    "After Hours: Ranked",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Colors.pinkAccent.withOpacity(0.9),
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: Colors.pinkAccent.withOpacity(0.9),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Log in to track, flex, and compete.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
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
                        const SizedBox(height: 12),
                        if (errorMessage != null)
                          Text(
                            errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: isLoading ? null : _login,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 70,
                      ),
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
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "LOG IN",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RegisterPage(apiService: widget.apiService),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Don't have an account? Register",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _openResetPassword,
                    child: const Text(
                      "Forgot password?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.cyanAccent,
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
