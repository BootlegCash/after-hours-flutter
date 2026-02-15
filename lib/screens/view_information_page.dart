import 'package:flutter/material.dart';

class YourInformationPage extends StatelessWidget {
  const YourInformationPage({super.key});

  // Mock data for preview — swap with your real user model later
  final String username = "poppy";
  final String email = "aolson949@gmail.com";
  final String displayName = "User";
  final bool emailVerified = false;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF070A1A);
    const card = Color(0xFF0D1230);
    const border = Color(0x3317F0FF);
    const neon = Color(0xFF17F0FF);
    const neon2 = Color(0xFFB56CFF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text("Your Information"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // Header card
            _GlassCard(
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [neon, neon2],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x5517F0FF),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.person, color: Colors.black, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "@$username",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Account details
            _SectionTitle("Account"),
            _GlassCard(
              child: Column(
                children: [
                  _InfoRow(label: "Username", value: username),
                  const _DividerLine(),
                  _InfoRow(label: "Display Name", value: displayName),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Email section
            _SectionTitle("Email"),
            _GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(label: "Email", value: email),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _StatusPill(
                        text: emailVerified ? "Verified" : "Not verified",
                        color: emailVerified
                            ? const Color(0xFF35F28B)
                            : const Color(0xFFFFC04D),
                      ),
                      const Spacer(),
                      if (!emailVerified)
                        _NeonButton(
                          text: "Verify Email",
                          onTap: () {
                            // TODO: Call your API to send verification email
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Verification email sent (demo)."),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  if (!emailVerified) ...[
                    const SizedBox(height: 10),
                    Text(
                      "We’ll send you a link to confirm your email.",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12.5),
                    ),
                  ]
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Security section
            _SectionTitle("Security"),
            _GlassCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_outline, color: neon),
                    title: const Text(
                      "Change Password",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "Update your password to keep your account secure.",
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 12.5),
                    ),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.white70),
                    onTap: () {
                      // TODO: Navigate to your ChangePassword page
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: card,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(18)),
                        ),
                        builder: (_) => const _ChangePasswordPreview(),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Optional: Sign out / delete account later
            // _NeonOutlineButton(text: "Sign Out", onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: Colors.white.withOpacity(0.55),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    const card = Color(0xFF0D1230);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x3317F0FF), width: 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x33000000), blurRadius: 18, offset: Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style:
                TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(height: 1, color: Colors.white.withOpacity(0.08)),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _NeonButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const neon = Color(0xFF17F0FF);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(colors: [neon, Color(0xFFB56CFF)]),
          boxShadow: const [
            BoxShadow(
                color: Color(0x4417F0FF), blurRadius: 16, spreadRadius: 1),
          ],
        ),
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w800, fontSize: 12.5),
        ),
      ),
    );
  }
}

class _ChangePasswordPreview extends StatelessWidget {
  const _ChangePasswordPreview();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Change Password",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 12),
            _Field(label: "Current password"),
            const SizedBox(height: 10),
            _Field(label: "New password"),
            const SizedBox(height: 10),
            _Field(label: "Confirm new password"),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Change password (demo).")),
                  );
                },
                child: const Text("Update Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  const _Field({required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}
