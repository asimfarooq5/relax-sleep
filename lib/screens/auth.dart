import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'splash.dart' show kBg, kCard, kCardHi, kTeal, kText, kSub, kBorder, AppLogo;

// ── Login Screen ──────────────────────────────────────────────────────────────

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});
  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _signInWithGoogle() async {
    setState(() { _loading = true; _error = null; });
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _loading = false);
        return; // user cancelled
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Sign in failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _BackButton(onTap: () => Navigator.pop(context)),
              ),
            ),
            const Spacer(flex: 2),
            const AppLogo(size: 84),
            const SizedBox(height: 18),
            const Text('Relaxed Sleep',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                  color: kText, letterSpacing: -0.3)),
            const SizedBox(height: 8),
            const Text('Your personal sleep sound mixer',
              style: TextStyle(fontSize: 14, color: kSub)),
            const Spacer(flex: 3),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xffFF5F5F).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffFF5F5F).withValues(alpha: 0.4)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Color(0xffFF5F5F), size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!,
                      style: const TextStyle(color: Color(0xffFF5F5F), fontSize: 13))),
                  ]),
                ),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: _loading
                  ? const CircularProgressIndicator(color: kTeal)
                  : _GoogleButton(onTap: _signInWithGoogle),
            ),
            const SizedBox(height: 16),
            const Text('By continuing you agree to our Terms & Privacy Policy',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: kSub)),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}

// ── Google Sign-In Button ─────────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" logo drawn with CustomPaint
            SizedBox(
              width: 22,
              height: 22,
              child: CustomPaint(painter: _GoogleGPainter()),
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                color: Color(0xff3C4043),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    final segments = [
      (0.0, 90.0, const Color(0xff4285F4)),   // blue top-right
      (90.0, 90.0, const Color(0xff34A853)),  // green bottom-right
      (180.0, 90.0, const Color(0xffFBBC05)), // yellow bottom-left
      (270.0, 90.0, const Color(0xffEA4335)), // red top-left
    ];

    for (final (start, sweep, color) in segments) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        _rad(start), _rad(sweep), true,
        Paint()..color = color,
      );
    }
    // White center
    canvas.drawCircle(Offset(cx, cy), r * 0.62, Paint()..color = Colors.white);

    // Blue horizontal bar (the "G" crossbar)
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - r * 0.17, r, r * 0.34),
      Paint()..color = const Color(0xff4285F4),
    );
  }

  double _rad(double deg) => deg * 3.14159265 / 180;

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
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
        width: 38, height: 38,
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
