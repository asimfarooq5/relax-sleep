import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash.dart' show kBg, kCard, kCardHi, kTeal, kText, kSub, kBorder, AppLogo;

// ── Email Login ───────────────────────────────────────────────────────────────

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});
  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _email.dispose(); super.dispose(); }

  void _submit() async {
    final e = _email.text.trim();
    if (!e.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a valid email address.'),
        backgroundColor: Color(0xff322F7A),
      ));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);

    // Show "OTP sent" bottom sheet, then go to OTP input
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _OtpSentSheet(email: e),
    );

    if (!mounted) return;
    Navigator.pushNamed(context, '/otp', arguments: e);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(children: [
                _BackButton(onTap: () => Navigator.pop(context)),
                const SizedBox(width: 12),
                const Text('E-mail Login',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                      color: kText)),
              ]),
            ),
            const SizedBox(height: 36),
            Center(child: Column(children: [
              const AppLogo(size: 72),
              const SizedBox(height: 14),
              const Text('Relaxed Sleep',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                    color: kText)),
            ])),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Email',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: kText)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    style: const TextStyle(color: kText),
                    decoration: InputDecoration(
                      hintText: 'Enter your email address',
                      hintStyle: TextStyle(color: kSub),
                      filled: true,
                      fillColor: kCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: kTeal, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: _loading
                        ? const CircularProgressIndicator(color: kTeal)
                        : GestureDetector(
                            onTap: _submit,
                            child: Container(
                              width: 58,
                              height: 58,
                              decoration: BoxDecoration(
                                color: kTeal,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(
                                  color: kTeal.withValues(alpha: 0.35),
                                  blurRadius: 16, spreadRadius: 2)],
                              ),
                              child: const Icon(Icons.arrow_forward_rounded,
                                  color: Color(0xff0D2A27), size: 26),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── OTP Sent Sheet ────────────────────────────────────────────────────────────

class _OtpSentSheet extends StatelessWidget {
  const _OtpSentSheet({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mail icon with badge
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: kTeal,
                    borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.mail_rounded,
                      color: Color(0xff0D2A27), size: 42)),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 30, height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xffFFB347),
                      shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_rounded,
                        color: Colors.white, size: 18)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "We've emailed you a\nconfirmation code to",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: kText, height: 1.4),
          ),
          const SizedBox(height: 10),
          Text(
            email,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                color: kText),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('use a different email?',
              style: TextStyle(color: kTeal, fontSize: 13)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kTeal,
                foregroundColor: const Color(0xff0D2A27),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: const Text('Verify',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── OTP Input Screen ──────────────────────────────────────────────────────────

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes = List.generate(6, (_) => FocusNode());
  bool _error = false;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _otp => _ctrls.map((c) => c.text).join();

  void _onDigit(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _nodes[index + 1].requestFocus();
    }
    setState(() => _error = false);
  }

  void _onBackspace(int index) {
    if (_ctrls[index].text.isEmpty && index > 0) {
      _nodes[index - 1].requestFocus();
      _ctrls[index - 1].clear();
    }
    setState(() => _error = false);
  }

  void _verify() async {
    if (_otp.length < 6) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);

    // For demo: any 6-digit code works except obvious wrong one
    if (_otp == '000000') {
      setState(() => _error = true);
      return;
    }
    // Success → go to main app
    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final email = ModalRoute.of(context)?.settings.arguments as String? ??
        'example@gmail.com';

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 36),
              // Mail icon
              SizedBox(
                width: 90, height: 90,
                child: Stack(children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: kTeal, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.mail_rounded,
                        color: Color(0xff0D2A27), size: 42)),
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 30, height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xffFFB347), shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_rounded,
                          color: Colors.white, size: 18)),
                  ),
                ]),
              ),
              const SizedBox(height: 24),
              const Text(
                "We've emailed you a\nconfirmation code to",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: kText, height: 1.4),
              ),
              const SizedBox(height: 10),
              Text(email,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: kText)),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Change email?',
                  style: TextStyle(color: kTeal, fontSize: 13)),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Enter the 6-digit code below',
                  style: TextStyle(color: kText, fontWeight: FontWeight.w600,
                      fontSize: 14)),
              ),
              const SizedBox(height: 16),
              // OTP boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (i) => SizedBox(
                  width: 48,
                  height: 56,
                  child: TextField(
                    controller: _ctrls[i],
                    focusNode: _nodes[i],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(1),
                    ],
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: _error ? const Color(0xffFF5F5F) : kTeal,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: kCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _error
                              ? const Color(0xffFF5F5F)
                              : kTeal.withValues(alpha: 0.5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _error
                              ? const Color(0xffFF5F5F)
                              : kTeal.withValues(alpha: 0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _error
                              ? const Color(0xffFF5F5F)
                              : kTeal,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (v) => _onDigit(i, v),
                    onEditingComplete: () => _onBackspace(i),
                  ),
                )),
              ),
              const SizedBox(height: 14),
              if (_error)
                Row(children: [
                  const Icon(Icons.error_outline_rounded,
                      color: Color(0xffFF5F5F), size: 16),
                  const SizedBox(width: 6),
                  const Text('Verification failed',
                    style: TextStyle(color: Color(0xffFF5F5F), fontSize: 13)),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      for (final c in _ctrls) c.clear();
                      setState(() => _error = false);
                      _nodes[0].requestFocus();
                    },
                    child: const Text('Resend code',
                      style: TextStyle(color: kTeal, fontSize: 13)),
                  ),
                ])
              else
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Resend code',
                      style: TextStyle(color: kTeal, fontSize: 13)),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kTeal,
                    disabledBackgroundColor: kTeal.withValues(alpha: 0.5),
                    foregroundColor: const Color(0xff0D2A27),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                            color: Color(0xff0D2A27), strokeWidth: 2.5))
                      : const Text('Verify',
                          style: TextStyle(fontSize: 17,
                              fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared back button ────────────────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kBorder),
        ),
        child: const Icon(Icons.chevron_left_rounded, color: kText, size: 24),
      ),
    );
  }
}
