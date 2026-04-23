import 'package:flutter/material.dart';

class SendFeedbackPage extends StatefulWidget {
  // Optional profile context (not required to show page)
  final String displayName;
  final String username;

  const SendFeedbackPage({
    super.key,
    this.displayName = '',
    this.username = '',
  });

  @override
  State<SendFeedbackPage> createState() => _SendFeedbackPageState();
}

class _SendFeedbackPageState extends State<SendFeedbackPage> {
  final _formKey = GlobalKey<FormState>();

  final _messageController = TextEditingController();
  final _emailController = TextEditingController();

  String _category = 'Bug';
  bool _includeContact = false;
  bool _submitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      // You said you don't need to hook anything up.
      // This is a placeholder "success" flow so the UI works.
      await Future<void>.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback sent — thank you!')),
      );
      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send feedback')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasUserContext = widget.username.trim().isNotEmpty ||
        widget.displayName.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Send Feedback')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Help us improve',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasUserContext
                        ? 'Sending as @${widget.username} (${widget.displayName})'
                        : 'Tell us what happened and how we can improve.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Category',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _category,
                          items: const [
                            DropdownMenuItem(value: 'Bug', child: Text('Bug')),
                            DropdownMenuItem(
                                value: 'Feature',
                                child: Text('Feature request')),
                            DropdownMenuItem(
                                value: 'Account',
                                child: Text('Account / Login')),
                            DropdownMenuItem(
                                value: 'Other', child: Text('Other')),
                          ],
                          onChanged: (v) =>
                              setState(() => _category = v ?? 'Bug'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Message',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _messageController,
                          minLines: 5,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            hintText:
                                'What happened?\nWhat did you expect?\nSteps to reproduce?',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final t = (v ?? '').trim();
                            if (t.length < 10)
                              return 'Write at least 10 characters.';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Let us contact you'),
                          subtitle: const Text(
                              'Optional — include an email for follow-up'),
                          value: _includeContact,
                          onChanged: (v) => setState(() => _includeContact = v),
                        ),
                        if (_includeContact) ...[
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) {
                              if (!_includeContact) return null;
                              final t = (v ?? '').trim();
                              if (!t.contains('@') || !t.contains('.')) {
                                return 'Enter a valid email.';
                              }
                              return null;
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(_submitting ? 'Sending...' : 'Send Feedback'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
