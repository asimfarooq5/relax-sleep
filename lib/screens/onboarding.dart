import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'splash.dart' show kBg, kCard, kCardHi, kTeal, kText, kSub, kBorder, AppLogo;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;
  int _selectedGoal = 1; // "Sleep All Night" pre-selected

  void _next() {
    if (_page < 2) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 380), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          PageView(
            controller: _ctrl,
            onPageChanged: (i) => setState(() => _page = i),
            children: [
              _IntroPage(onNext: _next),
              _PermissionsPage(onNext: _next),
              _GoalsPage(
                selectedGoal: _selectedGoal,
                onSelect: (i) => setState(() => _selectedGoal = i),
                onNext: _next,
              ),
            ],
          ),
          // Dots indicator
          if (_page > 0)
            Positioned(
              bottom: 160,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 20 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? kTeal
                        : kTeal.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Page 1: Intro (campfire) ──────────────────────────────────────────────────

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Campfire background
        Positioned.fill(
          child: CustomPaint(
            painter: _CampfirePainter(),
            child: const SizedBox.expand(),
          ),
        ),
        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color(0xff0C0816).withValues(alpha: 0.10),
                  const Color(0xff0C0816).withValues(alpha: 0.78),
                  const Color(0xff1E1B4B),
                ],
                stops: const [0, 0.50, 0.72, 1],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Text(
                      'Unwind with the most\nsoothing sleep sounds',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: kText,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Choose from over 100+ sounds\nAll 100% Free to use.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: kSub,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _TealCircleButton(onTap: onNext,
                        child: const Icon(Icons.arrow_forward_rounded,
                            color: Color(0xff0D2A27), size: 28)),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Page 2: Permissions ───────────────────────────────────────────────────────

class _PermissionsPage extends StatefulWidget {
  const _PermissionsPage({required this.onNext});
  final VoidCallback onNext;
  @override
  State<_PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<_PermissionsPage> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          children: [
            const SizedBox(height: 40),
            const AppLogo(size: 90),
            const SizedBox(height: 20),
            const Text('Relaxed Sleep',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900,
                  color: kText)),
            const SizedBox(height: 12),
            const Text(
              'To ensure sleep sound works properly\nplease allow these permissions',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: kSub, height: 1.5),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Allow notifications',
                          style: TextStyle(fontWeight: FontWeight.w700,
                              color: kText, fontSize: 15)),
                        const SizedBox(height: 6),
                        Text(
                          'To send sleep time reminders, or when\ngreat new features are available.',
                          style: const TextStyle(fontSize: 12, color: kSub,
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch(
                    value: _notifications,
                    onChanged: (v) => setState(() => _notifications = v),
                    activeColor: kTeal,
                    activeTrackColor: kTeal.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _TealCircleButton(onTap: widget.onNext,
                child: const Icon(Icons.arrow_forward_rounded,
                    color: Color(0xff0D2A27), size: 28)),
            const SizedBox(height: 44),
          ],
        ),
      ),
    );
  }
}

// ── Page 3: Goals ─────────────────────────────────────────────────────────────

class _GoalsPage extends StatelessWidget {
  const _GoalsPage({
    required this.selectedGoal,
    required this.onSelect,
    required this.onNext,
  });
  final int selectedGoal;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;

  static const _goals = [
    ('Fall Asleep Faster', Icons.directions_car_rounded),
    ('Sleep All Night', Icons.nights_stay_rounded),
    ('Relax and Unwind', Icons.alarm_rounded),
    ('Wake Refreshed', Icons.self_improvement_rounded),
    ('Help My Kids Sleep', Icons.child_care_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onNext,
                child: const Text('Skip',
                  style: TextStyle(color: kSub, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 8),
            const Text('What are your goals?',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                  color: kText)),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: _goals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final selected = selectedGoal == i;
                  return GestureDetector(
                    onTap: () => onSelect(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      decoration: BoxDecoration(
                        color: selected ? kTeal.withValues(alpha: 0.12) : kCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: selected ? kTeal : kBorder,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Row(children: [
                        Text(_goals[i].$1,
                          style: TextStyle(
                            color: selected ? kTeal : kText,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          )),
                        const Spacer(),
                        Icon(_goals[i].$2,
                          color: selected ? kTeal : kSub, size: 26),
                      ]),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
            _TealCircleButton(onTap: onNext,
                child: const Icon(Icons.check_rounded,
                    color: Color(0xff0D2A27), size: 28)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Campfire painter ──────────────────────────────────────────────────────────

class _CampfirePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * .5;
    final gy = h * .70;

    // Night sky gradient
    canvas.drawRect(Offset.zero & size,
      Paint()..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xff010105), Color(0xff08040E), Color(0xff180C06)],
        stops: [0.0, 0.65, 1.0],
      ).createShader(Offset.zero & size),
    );

    // Stars (seeded, deterministic)
    final rng = math.Random(42);
    for (var i = 0; i < 110; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * w, rng.nextDouble() * h * .62),
        rng.nextDouble() * 1.6 + 0.3,
        Paint()..color = Colors.white.withValues(alpha: 0.3 + rng.nextDouble() * 0.7),
      );
    }

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, gy, w, h - gy),
      Paint()..color = const Color(0xff060302),
    );

    // Ground glow (firelight on earth)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, gy + h * .045), width: w * .75, height: h * .085),
      Paint()..shader = RadialGradient(
        colors: [const Color(0xffFF5500).withValues(alpha: 0.40), Colors.transparent],
      ).createShader(Rect.fromCenter(
        center: Offset(cx, gy + h * .045), width: w * .75, height: h * .085,
      )),
    );

    // Wide fire halo
    canvas.drawCircle(
      Offset(cx, gy - h * .04),
      w * .52,
      Paint()..shader = RadialGradient(
        colors: [
          const Color(0xffFF7700).withValues(alpha: 0.60),
          const Color(0xffFF3300).withValues(alpha: 0.25),
          Colors.transparent,
        ],
        stops: [0.0, 0.42, 1.0],
      ).createShader(Rect.fromCircle(
        center: Offset(cx, gy - h * .04), radius: w * .52,
      )),
    );

    // Logs — two crossed sticks
    final logBase = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 16
      ..color = const Color(0xff4A2008);
    canvas.drawLine(Offset(cx - w * .26, gy + 10), Offset(cx + w * .10, gy - 8), logBase);
    canvas.drawLine(Offset(cx + w * .26, gy + 10), Offset(cx - w * .10, gy - 8), logBase);
    // Log highlight sheen
    canvas.drawLine(
      Offset(cx - w * .24, gy + 7), Offset(cx + w * .09, gy - 5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4
        ..color = const Color(0xff9B5020).withValues(alpha: 0.55),
    );

    // ── Flame layer 1: Wide outer orange (cubic bezier = wide base, tapers to tip) ──
    final r1 = Rect.fromLTWH(cx - w * .28, gy - h * .30, w * .56, h * .30);
    canvas.drawPath(
      Path()
        ..moveTo(cx - w * .24, gy)
        ..cubicTo(cx - w * .30, gy - h * .07,  // C1: slight outward bulge near base
                  cx - w * .04, gy - h * .24,  // C2: curves inward to tip
                  cx, gy - h * .30)             // tip
        ..cubicTo(cx + w * .04, gy - h * .24,
                  cx + w * .30, gy - h * .07,
                  cx + w * .24, gy)
        ..close(),
      Paint()..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xffCC3000),
          const Color(0xffFF7000).withValues(alpha: 0.80),
          const Color(0xffFFAA00).withValues(alpha: 0.0),
        ],
        stops: [0.0, 0.50, 1.0],
      ).createShader(r1),
    );

    // ── Flame layer 2: Medium amber (leans slightly right for natural look) ──
    final r2 = Rect.fromLTWH(cx - w * .20, gy - h * .38, w * .40, h * .38);
    canvas.drawPath(
      Path()
        ..moveTo(cx - w * .18, gy)
        ..cubicTo(cx - w * .22, gy - h * .08,
                  cx - w * .02, gy - h * .28,
                  cx + w * .01, gy - h * .38)
        ..cubicTo(cx + w * .05, gy - h * .28,
                  cx + w * .22, gy - h * .08,
                  cx + w * .18, gy)
        ..close(),
      Paint()..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xffFF5000),
          const Color(0xffFF9900).withValues(alpha: 0.80),
          const Color(0xffFFDD00).withValues(alpha: 0.0),
        ],
        stops: [0.0, 0.48, 1.0],
      ).createShader(r2),
    );

    // ── Flame layer 3: Bright inner yellow ──
    final r3 = Rect.fromLTWH(cx - w * .13, gy - h * .30, w * .26, h * .28);
    canvas.drawPath(
      Path()
        ..moveTo(cx - w * .12, gy - h * .01)
        ..cubicTo(cx - w * .15, gy - h * .07,
                  cx - w * .02, gy - h * .22,
                  cx, gy - h * .30)
        ..cubicTo(cx + w * .02, gy - h * .22,
                  cx + w * .15, gy - h * .07,
                  cx + w * .12, gy - h * .01)
        ..close(),
      Paint()..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          const Color(0xffFFDD00),
          const Color(0xffFFFF99).withValues(alpha: 0.80),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: [0.0, 0.36, 1.0],
      ).createShader(r3),
    );

    // Hot white core at base
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, gy - h * .06), width: w * .13, height: h * .10),
      Paint()..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.95),
          const Color(0xffFFFF88).withValues(alpha: 0.60),
          Colors.transparent,
        ],
        stops: [0.0, 0.38, 1.0],
      ).createShader(Rect.fromCenter(
        center: Offset(cx, gy - h * .06), width: w * .13, height: h * .10,
      )),
    );

    // Sparks / embers above flame
    const sparks = <(double, double, double)>[
      (0.44, 0.38, 1.6), (0.54, 0.35, 1.3), (0.50, 0.32, 1.1),
      (0.57, 0.40, 1.5), (0.45, 0.36, 1.2), (0.48, 0.30, 1.0),
      (0.55, 0.33, 1.4), (0.60, 0.38, 1.1), (0.42, 0.34, 1.3),
    ];
    final sp = Paint()..color = const Color(0xffFFCC44).withValues(alpha: 0.90);
    for (final (fx, fy, r) in sparks) {
      canvas.drawCircle(Offset(w * fx, h * fy), r, sp);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Shared button ─────────────────────────────────────────────────────────────

class _TealCircleButton extends StatelessWidget {
  const _TealCircleButton({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: kTeal,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kTeal.withValues(alpha: 0.4),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
