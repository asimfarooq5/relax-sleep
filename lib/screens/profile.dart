import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/prefs_service.dart';
import 'splash.dart' show kBg, kCard, kCardHi, kTeal, kText, kSub, kBorder;

// ── Profile Screen ────────────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  String _language = 'Automatic';
  String _placement = 'On Bedside Table';
  bool _reminderEnabled = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final data = await PrefsService.loadSettings();
    if (!mounted) return;
    setState(() {
      _language = data['language'] as String? ?? 'Automatic';
      _placement = data['placement'] as String? ?? 'On Bedside Table';
      _reminderEnabled = data['reminderEnabled'] as bool? ?? false;
      _loading = false;
    });
  }

  Future<void> _saveSettings() => PrefsService.saveSettings({
        'language': _language,
        'placement': _placement,
        'reminderEnabled': _reminderEnabled,
      });

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xff1E1B4B),
        body: Center(child: CircularProgressIndicator(color: Color(0xff00D4B4))),
      );
    }

    final displayName = _user?.displayName ?? 'Guest';
    final email = _user?.email ?? '';
    final photoUrl = _user?.photoURL;

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
                    if (photoUrl != null)
                      CircleAvatar(
                        radius: 29,
                        backgroundImage: NetworkImage(photoUrl),
                      )
                    else
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
                          Text(displayName,
                            style: const TextStyle(fontSize: 18,
                                fontWeight: FontWeight.w800, color: kText)),
                          const SizedBox(height: 2),
                          Text(email,
                            style: const TextStyle(fontSize: 13, color: kSub)),
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
                child: Builder(builder: (context) => Column(children: [
                  _SettingsRow(
                    icon: Icons.alarm_rounded,
                    label: 'Wake-Alarm',
                    sub: 'Next: 08:30 AM',
                    onTap: () => Navigator.pushNamed(context, '/sleep-schedule'),
                  ),
                  _SettingsRow(
                    icon: Icons.location_on_rounded,
                    label: 'Placement',
                    sub: _placement,
                    onTap: () => _showPlacementSheet(context),
                  ),
                  _SettingsRow(
                    icon: Icons.battery_charging_full_rounded,
                    label: 'Battery Warning',
                    onTap: () => _showInfoSheet(context, 'Battery Warning',
                      'Alerts you when battery drops below 20% while sleep tracking is active.',
                      Icons.battery_charging_full_rounded),
                  ),
                  _SettingsRow(
                    icon: Icons.notes_rounded,
                    label: 'Sleep Notes',
                    onTap: () => _showNotesSheet(context),
                  ),
                  _SettingsRow(
                    icon: Icons.wb_sunny_rounded,
                    label: 'Wake-up Mood',
                    onTap: () => _showMoodSheet(context),
                  ),
                ])),
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
                child: Builder(builder: (context) => Column(children: [
                  _SettingsRow(
                    icon: Icons.language_rounded,
                    label: 'Language',
                    sub: _language,
                    onTap: () => _showLanguageSheet(context),
                  ),
                  _SettingsRow(
                    icon: Icons.notifications_rounded,
                    label: 'Sleep Reminder',
                    sub: _reminderEnabled ? 'On' : 'Off',
                    onTap: () => Navigator.pushNamed(context, '/sleep-schedule'),
                  ),
                  _SettingsRow(
                    icon: Icons.star_rounded,
                    label: 'Rate Us',
                    onTap: () => _showRateDialog(context),
                  ),
                  _SettingsRow(
                    icon: Icons.feedback_rounded,
                    label: 'Feedback',
                    onTap: () => _showFeedbackSheet(context),
                  ),
                  _SettingsRow(
                    icon: Icons.more_horiz_rounded,
                    label: 'More...',
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                  _SettingsRow(
                    icon: Icons.logout_rounded,
                    label: 'Sign Out',
                    onTap: () => _confirmSignOut(context),
                    isLast: true,
                    iconColor: const Color(0xffFF5F5F),
                  ),
                ])),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Sign Out',
            style: TextStyle(color: kText, fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(color: kSub)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: kSub)),
          ),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              nav.pop();
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              nav.pushNamedAndRemoveUntil('/', (_) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffFF5F5F),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            child: const Text('Sign Out',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showRateDialog(BuildContext context) {
    showDialog<void>(context: context, builder: (_) => const _RateDialog());
  }

  void _showPlacementSheet(BuildContext context) {
    const opts = ['Under Pillow', 'On Bedside Table', 'Across the Room'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Device Placement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
              const SizedBox(height: 4),
              const Text('Where do you place your phone during sleep?',
                  style: TextStyle(fontSize: 13, color: kSub)),
              const SizedBox(height: 12),
              for (final opt in opts)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                        color: kTeal.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.location_on_rounded, color: kTeal, size: 18)),
                  title: Text(opt,
                      style: const TextStyle(color: kText, fontWeight: FontWeight.w600)),
                  trailing: opt == _placement
                      ? const Icon(Icons.check_rounded, color: kTeal)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _placement = opt);
                    _saveSettings();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Placement set: $opt'),
                      backgroundColor: kCard,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(16),
                    ));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoSheet(BuildContext context, String title, String body, IconData icon) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                    color: kTeal.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(icon, color: kTeal, size: 26)),
              const SizedBox(height: 14),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
              const SizedBox(height: 10),
              Text(body,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: kSub, height: 1.5)),
              const SizedBox(height: 20),
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
                  child: const Text('Got it',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotesSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sleep Notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              maxLines: 4,
              autofocus: true,
              style: const TextStyle(color: kText),
              decoration: InputDecoration(
                hintText: 'How did you sleep? Any dreams?',
                hintStyle: const TextStyle(color: kSub),
                filled: true,
                fillColor: kCardHi,
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
                  borderSide: const BorderSide(color: kTeal, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  if (ctrl.text.trim().isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Sleep note saved!'),
                      backgroundColor: kCard,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16),
                    ));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kTeal,
                  foregroundColor: const Color(0xff0D2A27),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: const Text('Save Note',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoodSheet(BuildContext context) {
    const moods = <(String, String)>[
      ('😴', 'Still Tired'), ('😐', 'OK'), ('🙂', 'Good'),
      ('😊', 'Great'), ('🤩', 'Amazing'),
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Wake-up Mood',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
              const SizedBox(height: 4),
              const Text('How did you feel waking up?',
                  style: TextStyle(fontSize: 13, color: kSub)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: moods.map((m) => GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Mood saved: ${m.$2}'),
                      backgroundColor: kCard,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(16),
                    ));
                  },
                  child: Column(children: [
                    Text(m.$1, style: const TextStyle(fontSize: 34)),
                    const SizedBox(height: 6),
                    Text(m.$2,
                        style: const TextStyle(fontSize: 11, color: kSub)),
                  ]),
                )).toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSheet(BuildContext context) {
    const langs = [
      'Automatic', 'English', 'Spanish', 'French',
      'German', 'Arabic', 'Urdu',
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Language',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
              const SizedBox(height: 8),
              for (final lang in langs)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(lang,
                      style: const TextStyle(
                          color: kText, fontWeight: FontWeight.w600)),
                  trailing: lang == _language
                      ? const Icon(Icons.check_rounded, color: kTeal)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _language = lang);
                    _saveSettings();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Language set to $lang'),
                      backgroundColor: kCard,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(16),
                    ));
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeedbackSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share Feedback',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
            const SizedBox(height: 4),
            const Text('Tell us how we can improve',
                style: TextStyle(fontSize: 13, color: kSub)),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              maxLines: 4,
              autofocus: true,
              style: const TextStyle(color: kText),
              decoration: InputDecoration(
                hintText: 'Your feedback...',
                hintStyle: const TextStyle(color: kSub),
                filled: true,
                fillColor: kCardHi,
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
                  borderSide: const BorderSide(color: kTeal, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Thank you for your feedback!'),
                    backgroundColor: kCard,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kTeal,
                  foregroundColor: const Color(0xff0D2A27),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: const Text('Send Feedback',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
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
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (_) => const _RateDialog(),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      onTap: () => _showShareSheet(context),
                    ),
                    _SettingsTile(
                      icon: Icons.chat_bubble_rounded,
                      label: 'Share your\nfeedback with us',
                      onTap: () => _showSettingsFeedback(context),
                    ),
                    _SettingsTile(
                      icon: Icons.add_circle_rounded,
                      label: 'More sleep\napps',
                      onTap: () => _showMoreApps(context),
                    ),
                    _SettingsTile(
                      icon: Icons.mail_rounded,
                      label: 'Contact us',
                      onTap: () => _showContact(context),
                    ),
                    _SettingsTile(
                      icon: Icons.info_rounded,
                      label: 'App version\n1.0.0',
                      onTap: () => showAboutDialog(
                        context: context,
                        applicationName: 'Relax & Sleep',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2026 Relax & Sleep',
                      ),
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

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                    color: kTeal.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Icon(Icons.share_rounded, color: kTeal, size: 26)),
              const SizedBox(height: 14),
              const Text('Share Relax & Sleep',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
              const SizedBox(height: 8),
              const Text(
                '"Relax & Sleep — the best sleep sound mixer.\nAvailable on App Store & Google Play."',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kSub, height: 1.5)),
              const SizedBox(height: 20),
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
                  child: const Text('Share',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsFeedback(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Share Feedback',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              maxLines: 4,
              autofocus: true,
              style: const TextStyle(color: kText),
              decoration: InputDecoration(
                hintText: 'Your feedback...',
                hintStyle: const TextStyle(color: kSub),
                filled: true,
                fillColor: kCardHi,
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
                  borderSide: const BorderSide(color: kTeal, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Thank you for your feedback!'),
                    backgroundColor: kCard,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kTeal,
                  foregroundColor: const Color(0xff0D2A27),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: const Text('Send',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreApps(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                    color: kTeal.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Icon(Icons.apps_rounded, color: kTeal, size: 26)),
              const SizedBox(height: 14),
              const Text('More Sleep Apps',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
              const SizedBox(height: 8),
              const Text('Discover our other wellness and sleep apps\non the App Store & Google Play.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: kSub, height: 1.5)),
              const SizedBox(height: 20),
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
                  child: const Text('Explore',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContact(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54, height: 54,
                decoration: BoxDecoration(
                    color: kTeal.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: const Icon(Icons.mail_rounded, color: kTeal, size: 26)),
              const SizedBox(height: 14),
              const Text('Contact Us',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: kText)),
              const SizedBox(height: 8),
              const Text('support@relaxsleep.app',
                  style: TextStyle(fontSize: 15, color: kTeal,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              const Text('We typically respond within 24 hours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: kSub)),
              const SizedBox(height: 20),
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
                  child: const Text('Got it',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
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
    this.iconColor,
  });
  final IconData icon;
  final String label;
  final String? sub;
  final VoidCallback onTap;
  final bool isLast;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? kTeal;
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
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18)),
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
