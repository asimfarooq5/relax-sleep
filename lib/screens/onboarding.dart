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
                  const Color(0xff0C0816).withValues(alpha: 0.4),
                  const Color(0xff0C0816).withValues(alpha: 0.92),
                  const Color(0xff1E1B4B),
                ],
                stops: const [0, 0.38, 0.62, 1],
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
    // Dark sky
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xff040208), Color(0xff0C0810), Color(0xff1A0A08)],
        ).createShader(Offset.zero & size),
    );

    // Stars
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    final rng = math.Random(42);
    for (var i = 0; i < 80; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height * .55),
        rng.nextDouble() * 1.5 + 0.5,
        starPaint,
      );
    }

    // Ground
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * .72, size.width, size.height * .28),
      Paint()..color = const Color(0xff0A0608),
    );

    // Fire glow
    canvas.drawCircle(
      Offset(size.width * .5, size.height * .72),
      size.width * .45,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xffFF8C00).withValues(alpha: 0.45),
            const Color(0xffFF4500).withValues(alpha: 0.25),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(size.width * .5, size.height * .72),
          radius: size.width * .45,
        )),
    );

    // Flames
    final flame1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [const Color(0xffFF6600), const Color(0xffFFCC00).withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(
          size.width * .38, size.height * .46, size.width * .24, size.height * .26));
    final flamePath = Path()
      ..moveTo(size.width * .42, size.height * .72)
      ..quadraticBezierTo(size.width * .38, size.height * .58,
          size.width * .50, size.height * .46)
      ..quadraticBezierTo(size.width * .62, size.height * .58,
          size.width * .58, size.height * .72)
      ..close();
    canvas.drawPath(flamePath, flame1);

    final flame2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [const Color(0xffFF4400), const Color(0xffFFAA00).withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(
          size.width * .42, size.height * .50, size.width * .16, size.height * .22));
    final flamePath2 = Path()
      ..moveTo(size.width * .45, size.height * .72)
      ..quadraticBezierTo(size.width * .42, size.height * .60,
          size.width * .50, size.height * .50)
      ..quadraticBezierTo(size.width * .58, size.height * .60,
          size.width * .55, size.height * .72)
      ..close();
    canvas.drawPath(flamePath2, flame2);

    // Sparks
    final sparkPaint = Paint()..color = const Color(0xffFFAA00).withValues(alpha: 0.8);
    const sparkPositions = [
      (0.46, 0.43), (0.52, 0.40), (0.48, 0.38), (0.55, 0.44), (0.44, 0.47),
    ];
    for (final sp in sparkPositions) {
      canvas.drawCircle(
        Offset(size.width * sp.$1, size.height * sp.$2),
        1.5,
        sparkPaint,
      );
    }

    // Logs
    final log = Paint()..color = const Color(0xff3D1A08);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * .44, size.height * .74),
          width: size.width * .32, height: 10),
        const Radius.circular(5)),
      log,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * .56, size.height * .74),
          width: size.width * .28, height: 10),
        const Radius.circular(5)),
      log,
    );
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
