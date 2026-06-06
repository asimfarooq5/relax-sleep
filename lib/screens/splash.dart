import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Design tokens (Figma navy/teal) ──────────────────────────────────────────
const kBg     = Color(0xff1E1B4B);
const kCard   = Color(0xff2A2770);
const kCardHi = Color(0xff322F7A);
const kTeal   = Color(0xff00D4B4);
const kText   = Colors.white;
const kSub    = Color(0xffA0A0BE);
const kBorder = Color(0xff3A3870);

// ── Shared App Logo ───────────────────────────────────────────────────────────
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 90});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xff0D6B5E),
        shape: BoxShape.circle,
      ),
      child: CustomPaint(
        painter: _LogoPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final star = Paint()..color = Colors.white;
    final stars = [
      Offset(size.width * .22, size.height * .22),
      Offset(size.width * .68, size.height * .18),
      Offset(size.width * .80, size.height * .38),
      Offset(size.width * .14, size.height * .42),
      Offset(size.width * .50, size.height * .12),
      Offset(size.width * .38, size.height * .34),
    ];
    for (final s in stars) {
      canvas.drawCircle(s, size.width * .025, star);
    }
    final cloud = Paint()..color = const Color(0xffB0E8F0);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .50, size.height * .64),
        width: size.width * .62,
        height: size.height * .30,
      ),
      cloud,
    );
    canvas.drawCircle(Offset(size.width * .33, size.height * .56), size.width * .16, cloud);
    canvas.drawCircle(Offset(size.width * .54, size.height * .51), size.width * .21, cloud);
    canvas.drawCircle(Offset(size.width * .70, size.height * .58), size.width * .14, cloud);

    // Zzz marks
    final zPaint = Paint()
      ..color = const Color(0xff0D6B5E)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final zPath = Path()
      ..moveTo(size.width * .44, size.height * .58)
      ..lineTo(size.width * .50, size.height * .58)
      ..lineTo(size.width * .44, size.height * .64)
      ..lineTo(size.width * .50, size.height * .64);
    canvas.drawPath(zPath, zPaint);
    final zPath2 = Path()
      ..moveTo(size.width * .52, size.height * .52)
      ..lineTo(size.width * .57, size.height * .52)
      ..lineTo(size.width * .52, size.height * .57)
      ..lineTo(size.width * .57, size.height * .57);
    canvas.drawPath(zPath2, zPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Splash Screen ─────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<double>(begin: 28, end: 0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => Opacity(
            opacity: _fade.value,
            child: Transform.translate(
              offset: Offset(0, _slide.value),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  const AppLogo(size: 110),
                  const SizedBox(height: 28),
                  const Text(
                    'Relax & Sleep',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: kText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(flex: 4),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 44),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                            context, '/onboarding'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kTeal,
                          foregroundColor: const Color(0xff0D2A27),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Let's help you sleep!",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(Icons.arrow_forward_rounded, size: 20),
                          ],
                        ),
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
