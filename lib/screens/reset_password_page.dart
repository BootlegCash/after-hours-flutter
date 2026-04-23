import 'package:flutter/material.dart';
import 'package:after_hours/services/api_service.dart';

class ResetPasswordPage extends StatefulWidget {
  final ApiService apiService;
  const ResetPasswordPage({super.key, required this.apiService});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _submitted = false;
  String? _error;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = "Please enter your email.");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
          'https://ranked-0xtx.onrender.com/accounts/api/password-reset/');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() => _submitted = true);
      } else {
        setState(() => _error = "Something went wrong. Try again.");
      }
    } catch (e) {
      setState(() => _error = "Network error. Check your connection.");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0c29),
      appBar: AppBar(
        title:
            const Text('Reset Password', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1c1842),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _submitted ? _successView() : _formView(),
      ),
    );
  }

  Widget _formView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Forgot your password?",
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          "Enter the email on your account and we'll send a reset link.",
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: "Email address",
            labelStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.07),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.redAccent)),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1493),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
            ),
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text("Send Reset Link",
                    style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _successView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.mark_email_read_outlined,
              color: Colors.greenAccent, size: 64),
          const SizedBox(height: 20),
          const Text(
            "Check your email",
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "If an account exists for that email, a reset link is on its way.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Back to Login",
                style: TextStyle(color: Color(0xFF00FEFC))),
          ),
        ],
      ),
    );
  }
}
