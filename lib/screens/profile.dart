import 'package:flutter/material.dart';
import 'splash.dart' show kBg, kCard, kCardHi, kTeal, kText, kSub, kBorder;

// ── Profile Screen ────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kBorder),
                  ),
                  child: Row(children: [
                    // Avatar
                    Container(
                      width: 58, height: 58,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kTeal.withValues(alpha: 0.4),
                              const Color(0xff7B5DFF).withValues(alpha: 0.4)]),
                        shape: BoxShape.circle),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 30)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Moin Haider',
                            style: TextStyle(fontSize: 18,
                                fontWeight: FontWeight.w800, color: kText)),
                          const SizedBox(height: 2),
                          const Text('moinexample@gmail.com',
                            style: TextStyle(fontSize: 13, color: kSub)),
                          const SizedBox(height: 6),
                          Row(children: [
                            Container(
                              width: 8, height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xff00D4B4),
                                shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            const Text('Sleep Quality: Good',
                              style: TextStyle(fontSize: 12, color: kTeal,
                                  fontWeight: FontWeight.w600)),
                          ]),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            // Stats grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: const [
                    _StatCard(label: 'Avg. Quality', value: '87%',
                        isRing: true),
                    _StatCard(label: 'Nights', value: '28'),
                    _StatCard(label: 'Avg. Time', value: '7h 45m'),
                    _StatCard(label: 'This Week', value: '+12%'),
                  ],
                ),
              ),
            ),
            // Tracker section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: const Text('Tracker',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                      color: kText)),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(children: [
                  _SettingsRow(
                    icon: Icons.alarm_rounded,
                    label: 'Wake-Alarm',
                    sub: 'Next: 08:30 AM',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.location_on_rounded,
                    label: 'Placement',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.battery_charging_full_rounded,
                    label: 'Battery Warning',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.notes_rounded,
                    label: 'Sleep Notes',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.wb_sunny_rounded,
                    label: 'Wake-up Mood',
                    onTap: () {},
                  ),
                ]),
              ),
            ),
            // Settings section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: const Text('Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                      color: kText)),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(children: [
                  _SettingsRow(
                    icon: Icons.language_rounded,
                    label: 'Language',
                    sub: 'Automatic',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.notifications_rounded,
                    label: 'Sleep Reminder',
                    sub: 'Off',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.star_rounded,
                    label: 'Rate Us',
                    onTap: () => _showRateDialog(context),
                  ),
                  _SettingsRow(
                    icon: Icons.feedback_rounded,
                    label: 'Feedback',
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.more_horiz_rounded,
                    label: 'More...',
                    onTap: () {},
                    isLast: true,
                  ),
                ]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  void _showRateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => const _RateDialog(),
    );
  }
}

// ── Settings Screen ───────────────────────────────────────────────────────────

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kBorder)),
                    child: const Icon(Icons.chevron_left_rounded,
                        color: kText, size: 24)),
                ),
                const SizedBox(width: 14),
                const Text('Settings',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                      color: kText)),
              ]),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.1,
                  children: [
                    _SettingsTile(
                      icon: Icons.star_rounded,
                      label: 'Rate us',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.chat_bubble_rounded,
                      label: 'Share your\nfeedback with us',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.add_circle_rounded,
                      label: 'More sleep\napps',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.mail_rounded,
                      label: 'Contact us',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.info_rounded,
                      label: 'App version\n1.0.0',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Rate Dialog ───────────────────────────────────────────────────────────────

class _RateDialog extends StatelessWidget {
  const _RateDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤩', style: TextStyle(fontSize: 42)),
            const SizedBox(height: 16),
            const Text(
              'If you love what we do,\nplease leave a review!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: kText, fontWeight: FontWeight.w600,
                  height: 1.4),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (_) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(Icons.star_rounded,
                    color: Color(0xffFFB347), size: 32),
              )),
            ),
            const SizedBox(height: 24),
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
                child: const Text('Rate our app',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No, maybe later',
                style: TextStyle(color: kSub, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Components ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value,
      this.isRing = false});
  final String label, value;
  final bool isRing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                color: kTeal)),
          const SizedBox(height: 4),
          Text(label,
            style: const TextStyle(fontSize: 12, color: kSub)),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.sub,
    this.isLast = false,
  });
  final IconData icon;
  final String label;
  final String? sub;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: kCard,
          border: Border(
            top: const BorderSide(color: Color(0xff3A3870)),
            bottom: isLast
                ? const BorderSide(color: Color(0xff3A3870))
                : BorderSide.none,
            left: const BorderSide(color: Color(0xff3A3870)),
            right: const BorderSide(color: Color(0xff3A3870)),
          ),
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(14))
              : BorderRadius.zero,
        ),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: kTeal.withValues(alpha: 0.15),
              shape: BoxShape.circle),
            child: Icon(icon, color: kTeal, size: 18)),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
              if (sub != null) ...[
                const SizedBox(height: 2),
                Text(sub!, style: const TextStyle(fontSize: 12, color: kSub)),
              ],
            ],
          )),
          const Icon(Icons.chevron_right_rounded, color: kSub, size: 20),
        ]),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.icon, required this.label,
      required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: kTeal, size: 28),
            const SizedBox(height: 10),
            Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13,
                  fontWeight: FontWeight.w600, color: kText),
            ),
          ],
        ),
      ),
    );
  }
}
