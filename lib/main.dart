import 'dart:async';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'screens/splash.dart';
import 'screens/onboarding.dart';
import 'screens/auth.dart';
import 'screens/sleep_schedule.dart';
import 'screens/profile.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xff0A0C13),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const SoundMixApp());
}

// ── Design tokens ─────────────────────────────────────────────────────────────

abstract final class _C {
  static const bg       = Color(0xff07090E);
  static const s1       = Color(0xff0F1219);
  static const s2       = Color(0xff161A24);
  static const s3       = Color(0xff1E2330);
  static const border   = Color(0xff252A38);
  static const text     = Color(0xffEDE8FF);
  static const textSub  = Color(0xff9690B0);
  static const textMut  = Color(0xff5A5575);
  static const purple   = Color(0xff7B4FFF);
  static const purpleHi = Color(0xff9D75FF);
  static const pink     = Color(0xffFF5FB0);
  static const navBg    = Color(0xff0A0C13);
}

// ── Data ──────────────────────────────────────────────────────────────────────

enum SoundSource { asset, file }

class MixSound {
  MixSound({
    required this.name,
    required this.subtitle,
    required this.source,
    required this.icon,
    required this.color,
    required this.volume,
    this.sourceType = SoundSource.asset,
    this.active = false,
  });

  final String name;
  final String subtitle;
  final String source;
  final SoundSource sourceType;
  final IconData icon;
  final Color color;
  double volume;
  bool active;
}

// ── App ───────────────────────────────────────────────────────────────────────

class SoundMixApp extends StatelessWidget {
  const SoundMixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Relax & Sleep',
      initialRoute: '/splash',
      routes: {
        '/splash':      (_) => const SplashScreen(),
        '/onboarding':  (_) => const OnboardingScreen(),
        '/auth':        (_) => const EmailLoginScreen(),
        '/otp':         (_) => const OtpScreen(),
        '/home':        (_) => const SoundMixShell(),
        '/settings':    (_) => const SettingsScreen(),
        '/sleep-schedule': (_) => const SleepScheduleScreen(),
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _C.purple,
          brightness: Brightness.dark,
          surface: _C.s1,
        ),
        scaffoldBackgroundColor: _C.bg,
        fontFamily: 'Roboto',
      ),
    );
  }
}

// ── Shell (state) ─────────────────────────────────────────────────────────────

class SoundMixShell extends StatefulWidget {
  const SoundMixShell({super.key});
  @override
  State<SoundMixShell> createState() => _SoundMixShellState();
}

class _SoundMixShellState extends State<SoundMixShell> {
  final _rng = math.Random();
  final Map<String, AudioPlayer> _players = {};

  final List<MixSound> _sounds = [
    MixSound(
      name: 'Rainforest',
      subtitle: 'Deep rain through leaves',
      source: 'assets/audio/rainforest.mp3',
      icon: Icons.water_drop_rounded,
      color: const Color(0xff4B9FFF),
      volume: .62,
      active: true,
    ),
    MixSound(
      name: 'Light Rain',
      subtitle: 'Gentle rain on glass',
      source: 'assets/audio/light_rain.mp3',
      icon: Icons.grain_rounded,
      color: const Color(0xff29C9AB),
      volume: .55,
      active: true,
    ),
    MixSound(
      name: 'Night Stream',
      subtitle: 'Low river in still air',
      source: 'assets/audio/night_stream.mp3',
      icon: Icons.waves_rounded,
      color: const Color(0xff8A5CFF),
      volume: .42,
      active: true,
    ),
    MixSound(
      name: 'Ocean Waves',
      subtitle: 'Slow rolling shore',
      source: 'assets/audio/ocean_waves.mp3',
      icon: Icons.sailing_rounded,
      color: const Color(0xffFF9840),
      volume: .72,
    ),
    MixSound(
      name: 'Wind in Leaves',
      subtitle: 'Wide calm forest wind',
      source: 'assets/audio/wind_in_leaves.mp3',
      icon: Icons.air_rounded,
      color: const Color(0xff1FCB6A),
      volume: .66,
    ),
    MixSound(
      name: 'Campfire',
      subtitle: 'Warm crackling fire',
      source: 'assets/audio/campfire.mp3',
      icon: Icons.local_fire_department_rounded,
      color: const Color(0xffFF6040),
      volume: .48,
    ),
    MixSound(
      name: 'Heavy Rain',
      subtitle: 'Intense rain and rumble',
      source: 'assets/audio/heavy_rain.mp3',
      icon: Icons.thunderstorm_rounded,
      color: const Color(0xff5C7BE0),
      volume: .50,
    ),
    MixSound(
      name: 'White Noise',
      subtitle: 'Pure flat static',
      source: 'assets/audio/white_noise.mp3',
      icon: Icons.blur_on_rounded,
      color: const Color(0xffC4BDD8),
      volume: .30,
    ),
    MixSound(
      name: 'Pink Noise',
      subtitle: 'Warm soft static',
      source: 'assets/audio/pink_noise.mp3',
      icon: Icons.graphic_eq_rounded,
      color: const Color(0xffFF78B7),
      volume: .38,
    ),
    MixSound(
      name: 'Brown Noise',
      subtitle: 'Deep low rumble',
      source: 'assets/audio/brown_noise.mp3',
      icon: Icons.surround_sound_rounded,
      color: const Color(0xffCC8040),
      volume: .45,
    ),
    MixSound(
      name: 'Binaural Delta',
      subtitle: '2 Hz deep sleep beat',
      source: 'assets/audio/binaural_delta.mp3',
      icon: Icons.psychology_rounded,
      color: const Color(0xff9B59FF),
      volume: .35,
    ),
  ];

  int _index = 0;
  bool _isPlaying = false;
  bool _isFavorite = false;
  double _masterVolume = .62;
  int _remainingSeconds = 25 * 60;
  Timer? _timer;

  List<MixSound> get _active => _sounds.where((s) => s.active).toList();

  @override
  void initState() {
    super.initState();
    unawaited(_initAll());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_isPlaying || _remainingSeconds == 0) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds == 0) {
          _isPlaying = false;
          unawaited(_pauseAll());
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final p in _players.values) unawaited(p.dispose());
    super.dispose();
  }

  String get _timerLabel {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Tab 0:Home  1:Sounds  2:Sleep(FAB)  3:Mix  4:Profile
    final pages = [
      _HomeScreen(
        sounds: _sounds,
        activeSounds: _active,
        isPlaying: _isPlaying,
        onGoToSounds: () => setState(() => _index = 1),
        onGoToPlayer: () => setState(() => _index = 2),
        onTogglePlaying: _togglePlay,
      ),
      _LibraryScreen(
        sounds: _sounds,
        onToggle: _toggle,
        onAddCustom: _pickFile,
        onEditTimer: _showTimer,
        onOpenMix: () => setState(() => _index = 3),
        onOpenPremium: _openPremium,
      ),
      _PlayerScreen(
        sounds: _active,
        isPlaying: _isPlaying,
        masterVolume: _masterVolume,
        onTogglePlaying: _togglePlay,
        onMasterVolume: _setMaster,
        onOpenPremium: _openPremium,
      ),
      _MixScreen(
        sounds: _active,
        onVolume: _setVolume,
        onRemove: _remove,
        onAdd: _showAddSheet,
        onSave: _save,
        onOpenPremium: _openPremium,
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: _C.bg,
      body: SafeArea(child: pages[_index]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _index = 2),
        backgroundColor: const Color(0xff00D4B4),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isPlaying ? Icons.pause_rounded : Icons.bedtime_rounded,
              color: const Color(0xff0D2A27),
              size: 26,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: _C.navBg,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Home',
                  sel: _index == 0,
                  onTap: () => setState(() => _index = 0)),
              _NavItem(icon: Icons.library_music_rounded, label: 'Sounds',
                  sel: _index == 1,
                  onTap: () => setState(() => _index = 1)),
              const Expanded(child: SizedBox()), // FAB gap
              _NavItem(icon: Icons.tune_rounded, label: 'Mix',
                  sel: _index == 3,
                  onTap: () => setState(() => _index = 3)),
              _NavItem(icon: Icons.person_rounded, label: 'Profile',
                  sel: _index == 4,
                  onTap: () => setState(() => _index = 4)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Audio ────────────────────────────────────────────────────────────────

  Future<void> _initAll() async {
    for (final s in _sounds) await _initOne(s);
  }

  Future<void> _initOne(MixSound sound) async {
    final p = AudioPlayer();
    _players[sound.name] = p;
    try {
      if (sound.sourceType == SoundSource.asset) {
        await p.setAsset(sound.source);
      } else {
        await p.setFilePath(sound.source);
      }
      await p.setLoopMode(LoopMode.one);
      await _applyVolume(sound);
      if (_isPlaying && sound.active) unawaited(p.play());
    } catch (_) {}
  }

  Future<void> _pauseAll() async {
    for (final p in _players.values) {
      try { await p.pause(); } catch (_) {}
    }
  }

  Future<void> _sync(MixSound s) async {
    final p = _players[s.name];
    if (p == null) return;
    try {
      await _applyVolume(s);
      if (_isPlaying && s.active) { unawaited(p.play()); }
      else { await p.pause(); }
    } catch (_) {}
  }

  Future<void> _applyVolume(MixSound s) async {
    final p = _players[s.name];
    if (p == null) return;
    await p.setVolume((s.volume * _masterVolume).clamp(0.0, 1.0));
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  void _togglePlay() {
    if (_active.isEmpty) { _msg('Add at least one sound first.'); return; }
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      for (final s in _sounds) unawaited(_sync(s));
    } else {
      unawaited(_pauseAll());
    }
  }

  void _toggle(MixSound s) {
    setState(() => s.active = !s.active);
    unawaited(_sync(s));
  }

  void _remove(MixSound s) {
    setState(() => s.active = false);
    unawaited(_sync(s));
  }

  void _setVolume(MixSound s, double v) {
    setState(() { s.active = true; s.volume = v; });
    unawaited(_sync(s));
  }

  void _setMaster(double v) {
    setState(() => _masterVolume = v);
    for (final s in _sounds) unawaited(_applyVolume(s));
  }

  void _shuffle() {
    setState(() {
      for (final s in _sounds) {
        s.active = _rng.nextBool();
        s.volume = .25 + _rng.nextDouble() * .65;
      }
      if (_active.isEmpty) _sounds.first.active = true;
    });
    for (final s in _sounds) unawaited(_sync(s));
    _msg('New random mix ready.');
  }

  void _save() => _msg('Mix saved · ${_active.length} sounds.');

  void _showAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _C.s2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Text('Add to mix',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                    color: _C.text)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                children: _sounds.map((s) => ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                  leading: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: s.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8)),
                    child: Icon(s.icon, color: s.color, size: 20)),
                  title: Text(s.name,
                    style: const TextStyle(fontWeight: FontWeight.w600,
                        color: _C.text, fontSize: 14)),
                  subtitle: Text(s.subtitle,
                    style: const TextStyle(fontSize: 12, color: _C.textSub)),
                  trailing: Icon(
                    s.active
                        ? Icons.check_circle_rounded
                        : Icons.add_circle_outline_rounded,
                    color: s.active ? _C.purple : _C.textMut),
                  onTap: () { _toggle(s); Navigator.pop(ctx); },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimer() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _C.s2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sleep Timer',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                    color: _C.text)),
              const SizedBox(height: 6),
              const Text('Playback stops when the timer ends.',
                style: TextStyle(fontSize: 13, color: _C.textSub)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [15, 25, 45, 60, 90, 120].map((min) =>
                  ActionChip(
                    label: Text('$min min'),
                    backgroundColor: _C.s3,
                    labelStyle: const TextStyle(
                        color: _C.text, fontWeight: FontWeight.w600),
                    side: const BorderSide(color: _C.border),
                    onPressed: () {
                      setState(() => _remainingSeconds = min * 60);
                      Navigator.pop(ctx);
                      _msg('Timer set · $min minutes.');
                    },
                  ),
                ).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPremium() => Navigator.push(context,
    MaterialPageRoute<void>(builder: (_) => const PremiumOfferPage()));

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
          type: FileType.audio, allowMultiple: false);
      if (result != null && result.files.single.path != null) {
        final file = result.files.single;
        final s = MixSound(
          name: file.name.split('.').first,
          subtitle: 'Custom sound',
          source: file.path!,
          sourceType: SoundSource.file,
          icon: Icons.audio_file_rounded,
          color: Colors.amber,
          volume: .5,
          active: true,
        );
        setState(() => _sounds.add(s));
        await _initOne(s);
        unawaited(_sync(s));
        _msg('Added: ${s.name}');
      }
    } catch (_) { _msg('Could not load file.'); }
  }

  void _msg(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        backgroundColor: _C.s3,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
  }
}

// ── Screen: Library ───────────────────────────────────────────────────────────

class _LibraryScreen extends StatelessWidget {
  const _LibraryScreen({
    required this.sounds,
    required this.onToggle,
    required this.onAddCustom,
    required this.onEditTimer,
    required this.onOpenMix,
    required this.onOpenPremium,
  });

  final List<MixSound> sounds;
  final ValueChanged<MixSound> onToggle;
  final VoidCallback onAddCustom;
  final VoidCallback onEditTimer;
  final VoidCallback onOpenMix;
  final VoidCallback onOpenPremium;

  @override
  Widget build(BuildContext context) {
    final activeCount = sounds.where((s) => s.active).length;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sound Library',
                        style: TextStyle(fontSize: 26,
                            fontWeight: FontWeight.w900, color: _C.text,
                            letterSpacing: -0.3)),
                      SizedBox(height: 2),
                      Text('Tap a card to add to your mix',
                        style: TextStyle(fontSize: 13, color: _C.textSub)),
                    ],
                  ),
                ),
                _ProBadge(onTap: onOpenPremium),
              ],
            ),
          ),
        ),
        if (activeCount > 0)
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: onOpenMix,
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    _C.purple.withValues(alpha: 0.24),
                    _C.pink.withValues(alpha: 0.14),
                  ]),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _C.purple.withValues(alpha: 0.42)),
                ),
                child: Row(children: [
                  Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: _C.purple.withValues(alpha: 0.38),
                      shape: BoxShape.circle),
                    child: const Icon(Icons.music_note_rounded,
                        color: Colors.white, size: 17)),
                  const SizedBox(width: 12),
                  Text(
                    '$activeCount sound${activeCount == 1 ? '' : 's'} active',
                    style: const TextStyle(color: _C.text,
                        fontWeight: FontWeight.w700, fontSize: 14)),
                  const Spacer(),
                  const Text('Edit mix →',
                    style: TextStyle(color: _C.purpleHi,
                        fontWeight: FontWeight.w600, fontSize: 13)),
                ]),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _SoundCard(sound: sounds[i],
                  onTap: () => onToggle(sounds[i])),
              childCount: sounds.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Row(children: [
              Expanded(child: _TileButton(
                icon: Icons.add_rounded,
                label: 'Custom Sound',
                bg: const Color(0xff150F22),
                borderColor: const Color(0xff2A1848),
                onTap: onAddCustom,
              )),
              const SizedBox(width: 12),
              Expanded(child: _TileButton(
                icon: Icons.timer_outlined,
                label: 'Sleep Timer',
                bg: const Color(0xff181210),
                borderColor: const Color(0xff352415),
                onTap: onEditTimer,
              )),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Screen: Mix ───────────────────────────────────────────────────────────────

class _MixScreen extends StatelessWidget {
  const _MixScreen({
    required this.sounds,
    required this.onVolume,
    required this.onRemove,
    required this.onAdd,
    required this.onSave,
    required this.onOpenPremium,
  });

  final List<MixSound> sounds;
  final void Function(MixSound, double) onVolume;
  final ValueChanged<MixSound> onRemove;
  final VoidCallback onAdd;
  final VoidCallback onSave;
  final VoidCallback onOpenPremium;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Mix',
                        style: TextStyle(fontSize: 26,
                            fontWeight: FontWeight.w900, color: _C.text,
                            letterSpacing: -0.3)),
                      SizedBox(height: 2),
                      Text('Adjust individual volumes',
                        style: TextStyle(fontSize: 13, color: _C.textSub)),
                    ],
                  ),
                ),
                _ProBadge(onTap: onOpenPremium),
              ],
            ),
          ),
        ),
        if (sounds.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 40),
              child: _EmptyMix(),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _VolumeRow(
                    sound: sounds[i],
                    onVolume: (v) => onVolume(sounds[i], v),
                    onRemove: () => onRemove(sounds[i]),
                  ),
                ),
                childCount: sounds.length,
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Sound'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: _C.s2,
                foregroundColor: _C.purpleHi,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: OutlinedButton(
              onPressed: onSave,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: _C.textSub,
                side: const BorderSide(color: _C.border),
              ),
              child: const Text('Save Mix'),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Screen: Player ────────────────────────────────────────────────────────────

class _PlayerScreen extends StatelessWidget {
  const _PlayerScreen({
    required this.sounds,
    required this.isPlaying,
    required this.masterVolume,
    required this.onTogglePlaying,
    required this.onMasterVolume,
    required this.onOpenPremium,
  });

  final List<MixSound> sounds;
  final bool isPlaying;
  final double masterVolume;
  final VoidCallback onTogglePlaying;
  final ValueChanged<double> onMasterVolume;
  final VoidCallback onOpenPremium;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _BlossomScene()),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.06),
                  Colors.black.withValues(alpha: 0.22),
                  const Color(0xff0E0B1A).withValues(alpha: 0.88),
                  const Color(0xff080611),
                ],
                stops: const [0, 0.32, 0.66, 1],
              ),
            ),
          ),
        ),
        Positioned(top: 14, right: 18,
            child: _ProBadge(onTap: onOpenPremium)),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 580;
            return Column(
              children: [
                SizedBox(height: compact ? 44 : 64),
                if (sounds.isNotEmpty)
                  SizedBox(
                    height: 28,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      children: sounds.map((s) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _SoundChip(sound: s),
                      )).toList(),
                    ),
                  ),
                const Spacer(),
                _BreathingOrb(
                  isPlaying: isPlaying,
                  onTap: onTogglePlaying,
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, 0, 20, compact ? 16 : 24),
                  child: _GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Now Playing',
                                  style: TextStyle(fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: _C.text,
                                      letterSpacing: -0.2)),
                                const SizedBox(height: 2),
                                Text(
                                  sounds.isEmpty
                                      ? 'No sounds selected'
                                      : '${sounds.length} sound${sounds.length == 1 ? '' : 's'} active',
                                  style: const TextStyle(
                                      fontSize: 12, color: _C.textSub)),
                              ],
                            ),
                          ),
                        ]),
                        if (sounds.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 6, runSpacing: 6,
                            children: sounds.take(6).map((s) =>
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: s.color.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: s.color.withValues(alpha: 0.32)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(s.icon, color: s.color, size: 11),
                                    const SizedBox(width: 5),
                                    Text(s.name, style: TextStyle(
                                      color: s.color, fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ).toList(),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(children: [
                          const Icon(Icons.volume_up_rounded,
                              size: 16, color: _C.textSub),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 7),
                                overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 14),
                                activeTrackColor: _C.pink,
                                inactiveTrackColor:
                                    Colors.white.withValues(alpha: 0.12),
                                thumbColor: _C.pink,
                                overlayColor:
                                    _C.pink.withValues(alpha: 0.18),
                              ),
                              child: Slider(
                                value: masterVolume,
                                onChanged: onMasterVolume,
                              ),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ── Screen: Queue ─────────────────────────────────────────────────────────────

class _QueueScreen extends StatelessWidget {
  const _QueueScreen({
    required this.sounds,
    required this.isPlaying,
    required this.isFavorite,
    required this.timerLabel,
    required this.onTogglePlaying,
    required this.onToggleFavorite,
    required this.onVolume,
    required this.onRemove,
    required this.onAdd,
    required this.onShuffle,
    required this.onTimer,
    required this.onOpenPremium,
  });

  final List<MixSound> sounds;
  final bool isPlaying;
  final bool isFavorite;
  final String timerLabel;
  final VoidCallback onTogglePlaying;
  final VoidCallback onToggleFavorite;
  final void Function(MixSound, double) onVolume;
  final ValueChanged<MixSound> onRemove;
  final VoidCallback onAdd;
  final VoidCallback onShuffle;
  final VoidCallback onTimer;
  final VoidCallback onOpenPremium;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Now Playing',
                        style: TextStyle(fontSize: 26,
                            fontWeight: FontWeight.w900, color: _C.text,
                            letterSpacing: -0.3)),
                      SizedBox(height: 2),
                      Text('Your current sound mix',
                        style: TextStyle(fontSize: 13, color: _C.textSub)),
                    ],
                  ),
                ),
                _ProBadge(onTap: onOpenPremium),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: _C.s2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _C.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                    child: Row(children: [
                      const Expanded(child: Text('Mix Details',
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w800, color: _C.text))),
                      IconButton(
                        onPressed: onAdd,
                        icon: const Icon(Icons.edit_rounded,
                            color: _C.purpleHi, size: 20),
                        visualDensity: VisualDensity.compact,
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 2, 16, 14),
                    child: Text(
                      '${sounds.length} sound${sounds.length == 1 ? '' : 's'} active',
                      style: const TextStyle(fontSize: 12, color: _C.textSub)),
                  ),
                  if (sounds.isEmpty)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _EmptyMix())
                  else
                    for (final s in sounds)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: _VolumeRow(
                          sound: s,
                          compact: true,
                          onVolume: (v) => onVolume(s, v),
                          onRemove: () => onRemove(s),
                        ),
                      ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                    child: Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onAdd,
                          icon: const Icon(Icons.add_rounded, size: 17),
                          label: const Text('Add'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _C.purpleHi,
                            side: const BorderSide(color: _C.border),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onShuffle,
                          icon: const Icon(Icons.shuffle_rounded, size: 17),
                          label: const Text('Shuffle'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _C.textSub,
                            side: const BorderSide(color: _C.border),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: _PlayerBar(
              isPlaying: isPlaying,
              isFavorite: isFavorite,
              timerLabel: timerLabel,
              onPlay: onTogglePlaying,
              onFavorite: onToggleFavorite,
              onTimer: onTimer,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _BreathingOrb extends StatefulWidget {
  const _BreathingOrb({required this.isPlaying, required this.onTap});
  final bool isPlaying;
  final VoidCallback onTap;
  @override
  State<_BreathingOrb> createState() => _BreathingOrbState();
}

class _BreathingOrbState extends State<_BreathingOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _alpha;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3600));
    _scale = Tween<double>(begin: 1.0, end: 1.24)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _alpha = Tween<double>(begin: 0.12, end: 0.40)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    if (widget.isPlaying) _ctrl.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_BreathingOrb old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying && !old.isPlaying) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isPlaying && old.isPlaying) {
      _ctrl.animateTo(0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => SizedBox(
        width: 168,
        height: 168,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 130, height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.pink.withValues(alpha: _alpha.value * 0.55)),
              ),
            ),
            Transform.scale(
              scale: (_scale.value * 0.84 + 0.16),
              child: Container(
                width: 116, height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.purple.withValues(
                      alpha: _alpha.value * 0.45)),
              ),
            ),
            GestureDetector(
              onTap: widget.onTap,
              child: Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xff9B65FF), Color(0xff6028E0)],
                  ),
                  border: Border.all(
                    color: _C.pink.withValues(alpha: 0.65),
                    width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: _C.purple.withValues(alpha: 0.5),
                      blurRadius: 30, spreadRadius: 4),
                    BoxShadow(
                      color: _C.pink.withValues(alpha: 0.18),
                      blurRadius: 18),
                  ],
                ),
                child: Icon(
                  widget.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 50, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoundCard extends StatelessWidget {
  const _SoundCard({required this.sound, required this.onTap});
  final MixSound sound;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: sound.active
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    sound.color.withValues(alpha: 0.26),
                    sound.color.withValues(alpha: 0.10),
                  ])
              : null,
          color: sound.active ? null : _C.s2,
          border: Border.all(
            color: sound.active
                ? sound.color.withValues(alpha: 0.52)
                : _C.border,
            width: sound.active ? 1.5 : 1),
          boxShadow: sound.active
              ? [BoxShadow(
                  color: sound.color.withValues(alpha: 0.16),
                  blurRadius: 14, offset: const Offset(0, 4))]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: sound.color.withValues(
                      alpha: sound.active ? 0.26 : 0.12),
                  borderRadius: BorderRadius.circular(11)),
                child: Icon(sound.icon, color: sound.color, size: 22)),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  sound.active
                      ? Icons.check_circle_rounded
                      : Icons.add_circle_outline_rounded,
                  key: ValueKey(sound.active),
                  color: sound.active ? sound.color : _C.textMut,
                  size: 20)),
            ]),
            const Spacer(),
            Text(sound.name,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: sound.active ? _C.text : const Color(0xffC0BAD0))),
            const SizedBox(height: 3),
            Text(sound.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: sound.active
                    ? sound.color.withValues(alpha: 0.78)
                    : _C.textMut)),
          ],
        ),
      ),
    );
  }
}

class _SoundChip extends StatelessWidget {
  const _SoundChip({required this.sound});
  final MixSound sound;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: sound.color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sound.color.withValues(alpha: 0.38)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(sound.icon, color: sound.color, size: 12),
        const SizedBox(width: 5),
        Text(sound.name,
          style: TextStyle(color: sound.color, fontSize: 11,
              fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _VolumeRow extends StatelessWidget {
  const _VolumeRow({
    required this.sound,
    required this.onVolume,
    required this.onRemove,
    this.compact = false,
  });
  final MixSound sound;
  final ValueChanged<double> onVolume;
  final VoidCallback onRemove;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, compact ? 9 : 12, 8, compact ? 5 : 8),
      decoration: BoxDecoration(
        color: _C.s2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sound.color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: sound.color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(9)),
            child: Icon(sound.icon, color: sound.color, size: 19)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sound.name,
                  style: const TextStyle(fontWeight: FontWeight.w700,
                      fontSize: 13, color: _C.text)),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 13),
                    activeTrackColor: sound.color,
                    inactiveTrackColor: _C.s3,
                    thumbColor: sound.color,
                    overlayColor: sound.color.withValues(alpha: 0.14),
                  ),
                  child: Slider(value: sound.volume, onChanged: onVolume),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, size: 17),
            color: _C.textMut,
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}

class _PlayerBar extends StatelessWidget {
  const _PlayerBar({
    required this.isPlaying,
    required this.isFavorite,
    required this.timerLabel,
    required this.onPlay,
    required this.onFavorite,
    required this.onTimer,
  });
  final bool isPlaying;
  final bool isFavorite;
  final String timerLabel;
  final VoidCallback onPlay;
  final VoidCallback onFavorite;
  final VoidCallback onTimer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          _C.purple.withValues(alpha: 0.52),
          _C.pink.withValues(alpha: 0.32),
        ]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _C.purple.withValues(alpha: 0.38)),
        boxShadow: [
          BoxShadow(
            color: _C.purple.withValues(alpha: 0.22),
            blurRadius: 22, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(children: [
        GestureDetector(
          onTap: onTimer,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.timer_outlined, color: Colors.white70, size: 22),
            const SizedBox(height: 4),
            Text(timerLabel,
              style: const TextStyle(fontSize: 11, color: Colors.white70,
                  fontWeight: FontWeight.w600, letterSpacing: 0.4)),
          ]),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onPlay,
          child: Container(
            width: 68, height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.pink,
              boxShadow: [BoxShadow(
                color: _C.pink.withValues(alpha: 0.48),
                blurRadius: 22, spreadRadius: 2)],
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 36, color: Colors.white),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onFavorite,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? _C.pink : Colors.white70, size: 22),
            const SizedBox(height: 4),
            Text(isFavorite ? 'Saved' : 'Save',
              style: TextStyle(fontSize: 11,
                  color: isFavorite ? _C.pink : Colors.white70,
                  fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: child,
    );
  }
}

class _TileButton extends StatelessWidget {
  const _TileButton({
    required this.icon,
    required this.label,
    required this.bg,
    required this.borderColor,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color bg;
  final Color borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: _C.textSub),
            const SizedBox(width: 8),
            Text(label,
              style: const TextStyle(fontWeight: FontWeight.w700,
                  fontSize: 13, color: _C.textSub)),
          ],
        ),
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  const _ProBadge({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xff9B65FF), Color(0xffFF5FB0)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.auto_awesome_rounded, size: 13, color: Colors.white),
          SizedBox(width: 5),
          Text('PRO',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800,
                color: Colors.white, letterSpacing: 0.5)),
        ]),
      ),
    );
  }
}

class _EmptyMix extends StatelessWidget {
  const _EmptyMix();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Column(children: [
          Icon(Icons.queue_music_rounded, size: 40, color: _C.textMut),
          SizedBox(height: 12),
          Text('No sounds in your mix',
            style: TextStyle(color: _C.textMut, fontSize: 14)),
          SizedBox(height: 4),
          Text('Go to Library to add some',
            style: TextStyle(color: _C.textMut, fontSize: 12)),
        ]),
      ),
    );
  }
}

// ── Artwork ───────────────────────────────────────────────────────────────────

class _BlossomScene extends StatelessWidget {
  const _BlossomScene();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _BlossomPainter(), child: const SizedBox.expand());
}

class _BlossomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sky = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xff4A6878), Color(0xffBB8095), Color(0xff7A5268)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);

    // Moon glow
    canvas.drawCircle(
      Offset(size.width * .76, size.height * .13),
      size.width * .16,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xffFFFDE8).withValues(alpha: 0.55),
          const Color(0xffFFEEBB).withValues(alpha: 0.18),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(
          center: Offset(size.width * .76, size.height * .13),
          radius: size.width * .16)),
    );
    canvas.drawCircle(
      Offset(size.width * .76, size.height * .13),
      size.width * .062,
      Paint()..color = const Color(0xffFFF9D0).withValues(alpha: 0.82),
    );

    // Main branch
    final branch = Paint()
      ..color = const Color(0xff5A3D52).withValues(alpha: 0.72)
      ..strokeWidth = 15
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * .04, size.height * .20),
      Offset(size.width * .84, size.height * .52),
      branch,
    );
    canvas.drawLine(
      Offset(size.width * .36, size.height * .37),
      Offset(size.width * .50, size.height * .20),
      branch..strokeWidth = 8,
    );
    canvas.drawLine(
      Offset(size.width * .58, size.height * .44),
      Offset(size.width * .68, size.height * .28),
      branch..strokeWidth = 6,
    );

    // Petals
    final petal = Paint()
      ..color = const Color(0xffFFCCDD).withValues(alpha: 0.76);
    for (var i = 0; i < 90; i++) {
      final x = ((math.sin(i * 9.91) * 10000) % 1).abs() * size.width;
      final y = ((math.sin(i * 5.37) * 10000) % 1).abs() * size.height;
      final angle = math.sin(i * 2.73) * math.pi;
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(angle)
        ..drawOval(
            Rect.fromCenter(center: Offset.zero, width: 15, height: 8), petal)
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ── Nav Item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.sel,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool sel;
  final VoidCallback onTap;

  static const _teal = Color(0xff00D4B4);
  static const _muted = Color(0xff6E6B90);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: sel ? _teal : _muted, size: 22),
            const SizedBox(height: 3),
            Text(label,
              style: TextStyle(
                fontSize: 10,
                color: sel ? _teal : _muted,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
              )),
          ],
        ),
      ),
    );
  }
}

// ── Home Screen ───────────────────────────────────────────────────────────────

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({
    required this.sounds,
    required this.activeSounds,
    required this.isPlaying,
    required this.onGoToSounds,
    required this.onGoToPlayer,
    required this.onTogglePlaying,
  });
  final List<MixSound> sounds;
  final List<MixSound> activeSounds;
  final bool isPlaying;
  final VoidCallback onGoToSounds;
  final VoidCallback onGoToPlayer;
  final VoidCallback onTogglePlaying;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    const Color(0xff00D4B4).withValues(alpha: 0.3),
                    _C.purple.withValues(alpha: 0.3),
                  ]),
                  shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 22)),
              const SizedBox(width: 12),
              const Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hi User,', style: TextStyle(fontSize: 12, color: _C.textSub)),
                  Text('Welcome', style: TextStyle(fontSize: 17,
                      fontWeight: FontWeight.w800, color: _C.text)),
                ]),
              const Spacer(),
              _IconBtn(icon: Icons.timer_outlined,
                  onTap: () {}),
              const SizedBox(width: 8),
              _IconBtn(icon: Icons.share_rounded, onTap: () {}),
              const SizedBox(width: 8),
              _IconBtn(icon: Icons.notifications_outlined, onTap: () {}),
            ]),
          ),
        ),
        // Active mix card
        if (activeSounds.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: GestureDetector(
                onTap: onGoToPlayer,
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      _C.purple.withValues(alpha: 0.55),
                      const Color(0xff00D4B4).withValues(alpha: 0.35),
                    ]),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _C.purple.withValues(alpha: 0.4)),
                  ),
                  child: Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Now Playing',
                          style: TextStyle(fontSize: 12, color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text('${activeSounds.length} sounds active',
                          style: const TextStyle(fontSize: 17,
                              fontWeight: FontWeight.w800, color: _C.text)),
                        const SizedBox(height: 8),
                        Wrap(spacing: 6, children: activeSounds.take(3).map((s) =>
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: s.color.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: s.color.withValues(alpha: 0.4))),
                            child: Text(s.name, style: TextStyle(
                                color: s.color, fontSize: 11,
                                fontWeight: FontWeight.w600)),
                          ),
                        ).toList()),
                      ],
                    )),
                    GestureDetector(
                      onTap: onTogglePlaying,
                      child: Container(
                        width: 52, height: 52,
                        decoration: const BoxDecoration(
                          color: Color(0xff00D4B4),
                          shape: BoxShape.circle),
                        child: Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: const Color(0xff0D2A27), size: 28),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        // What's new banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff1A1060), Color(0xff2A2080)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _C.border),
              ),
              child: Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("What's new?",
                      style: TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w700, color: _C.text)),
                    const SizedBox(height: 4),
                    Text('Discover new rain sounds for sleep',
                      style: TextStyle(fontSize: 12, color: _C.textSub)),
                  ],
                )),
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: _C.purple.withValues(alpha: 0.35),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 22)),
              ]),
            ),
          ),
        ),
        // Sound Mixes section
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 12),
            child: Row(children: [
              Text('Sound Library',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                    color: _C.text)),
              Spacer(),
              Text('See all →',
                style: TextStyle(fontSize: 13, color: Color(0xff00D4B4))),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 110,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: sounds.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final s = sounds[i];
                return GestureDetector(
                  onTap: onGoToSounds,
                  child: Column(children: [
                    Container(
                      width: 68, height: 68,
                      decoration: BoxDecoration(
                        color: s.color.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: s.active
                              ? s.color.withValues(alpha: 0.6)
                              : _C.border,
                          width: s.active ? 2 : 1)),
                      child: Icon(s.icon, color: s.color, size: 28)),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 68,
                      child: Text(s.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: s.active ? _C.text : _C.textSub,
                          fontWeight: s.active
                              ? FontWeight.w600 : FontWeight.w400,
                        )),
                    ),
                  ]),
                );
              },
            ),
          ),
        ),
        // Quick actions
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              Expanded(child: _QuickCard(
                icon: Icons.add_rounded,
                label: 'Build a Mix',
                color: const Color(0xff150F22),
                borderColor: const Color(0xff2A1848),
                onTap: onGoToSounds,
              )),
              const SizedBox(width: 12),
              Expanded(child: _QuickCard(
                icon: Icons.schedule_rounded,
                label: 'Sleep Schedule',
                color: const Color(0xff0D1820),
                borderColor: const Color(0xff152535),
                onTap: () => Navigator.pushNamed(context, '/sleep-schedule'),
              )),
            ]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: _C.s2,
          shape: BoxShape.circle,
          border: Border.all(color: _C.border)),
        child: Icon(icon, color: _C.textSub, size: 18)),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.borderColor,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color, borderColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: _C.textSub),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600,
              fontSize: 13, color: _C.textSub)),
        ]),
      ),
    );
  }
}

// ── Premium Page ──────────────────────────────────────────────────────────────

enum _Plan { yearly, monthly }

class PremiumOfferPage extends StatefulWidget {
  const PremiumOfferPage({super.key});
  @override
  State<PremiumOfferPage> createState() => _PremiumOfferPageState();
}

class _PremiumOfferPageState extends State<PremiumOfferPage> {
  _Plan _plan = _Plan.monthly;
  bool _restored = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff24126a),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: _OfferBody(
              plan: _plan,
              restored: _restored,
              onPlan: (p) => setState(() => _plan = p),
              onClose: () => Navigator.of(context).maybePop(),
              onRestore: () => setState(() => _restored = true),
            ),
          ),
        ),
      ),
    );
  }
}

class _OfferBody extends StatelessWidget {
  const _OfferBody({
    required this.plan,
    required this.restored,
    required this.onPlan,
    required this.onClose,
    required this.onRestore,
  });
  final _Plan plan;
  final bool restored;
  final ValueChanged<_Plan> onPlan;
  final VoidCallback onClose;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final short = constraints.maxHeight < 720;
      final heroH = short
          ? 210.0
          : (constraints.maxHeight * .34).clamp(260.0, 360.0);

      return Stack(children: [
        Positioned.fill(child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff4420a1), Color(0xff2d177a),
                Color(0xff211061), Color(0xff24126a),
              ],
              stops: [0, .22, .54, 1],
            ),
          ),
        )),
        SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(children: [
              SizedBox(
                height: heroH,
                child: Stack(children: [
                  Positioned.fill(child: CustomPaint(
                    painter: _SunsetPainter(),
                    child: const SizedBox.expand(),
                  )),
                  Positioned.fill(child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xff24126a).withValues(alpha: 0.2),
                          const Color(0xff24126a),
                        ],
                        stops: const [.35, .68, 1],
                      ),
                    ),
                  )),
                  Positioned(
                    left: 18, top: 12,
                    child: SizedBox(
                      width: 52, height: 52,
                      child: IconButton.filledTonal(
                        onPressed: onClose,
                        icon: const Icon(Icons.close_rounded, size: 26),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xff52245d).withValues(alpha: 0.7),
                          foregroundColor: Colors.white),
                      ),
                    ),
                  ),
                ]),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(26, 0, 26, short ? 16 : 20),
                child: Column(children: [
                  const Text('Relax & Sleep\nBetter',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 36, height: 1.08,
                        fontWeight: FontWeight.w800, letterSpacing: 0,
                        color: Colors.white)),
                  SizedBox(height: short ? 10 : 16),
                  const Text(
                    'Unlock the full library, no ads,\nand advanced sleep features.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xffd7d1ff), fontSize: 17,
                        height: 1.35, fontWeight: FontWeight.w500)),
                  SizedBox(height: short ? 20 : 26),
                  Row(children: [
                    Expanded(child: _PlanCard(
                      label: 'Yearly',
                      badge: 'Save 70%',
                      price: r'$19.99',
                      period: '/year',
                      detail: r'$4.99/month',
                      sub: '3 months free',
                      btnLabel: 'Start Free Trial',
                      accent: const Color(0xff1ee3d4),
                      selected: plan == _Plan.yearly,
                      onTap: () => onPlan(_Plan.yearly),
                    )),
                    const SizedBox(width: 14),
                    Expanded(child: _PlanCard(
                      label: 'Monthly',
                      badge: 'Most Popular',
                      price: r'$1.99',
                      period: '/month',
                      detail: r'$4.99/month',
                      sub: 'Pay monthly',
                      btnLabel: 'Get Discount',
                      accent: const Color(0xffffd86b),
                      selected: plan == _Plan.monthly,
                      onTap: () => onPlan(_Plan.monthly),
                    )),
                  ]),
                  SizedBox(height: short ? 18 : 36),
                  TextButton(
                    onPressed: onRestore,
                    child: Text(
                      restored ? 'Purchases Restored ✓' : 'Cancel Anytime',
                      style: const TextStyle(color: Colors.white,
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(height: short ? 8 : 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _FooterLink('Terms of Service'),
                      const Text(' | ',
                          style: TextStyle(color: Color(0xff8d7ed6))),
                      _FooterLink('Privacy Policy'),
                    ],
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ]);
    });
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.label,
    required this.badge,
    required this.price,
    required this.period,
    required this.detail,
    required this.sub,
    required this.btnLabel,
    required this.accent,
    required this.selected,
    required this.onTap,
  });
  final String label, badge, price, period, detail, sub, btnLabel;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: 270,
            padding: const EdgeInsets.fromLTRB(14, 30, 14, 16),
            decoration: BoxDecoration(
              color: const Color(0xff2d177a),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: selected ? accent : const Color(0xff6d50c9),
                width: selected ? 2 : 1),
              boxShadow: [BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18, offset: const Offset(0, 10))],
            ),
            child: Column(children: [
              Text(label,
                style: const TextStyle(fontSize: 22,
                    fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 16),
              Text(detail,
                style: const TextStyle(color: Color(0xffa99be8), fontSize: 13,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: Color(0xffa99be8))),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(price,
                      style: const TextStyle(fontSize: 36, height: 1,
                          fontWeight: FontWeight.w900, color: Colors.white)),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(period,
                        style: const TextStyle(color: Color(0xffd2c9ff),
                            fontSize: 15, fontWeight: FontWeight.w600))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(sub,
                style: const TextStyle(color: Color(0xffd2c9ff),
                    fontSize: 14, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [BoxShadow(
                    color: accent.withValues(alpha: 0.26),
                    blurRadius: 14, offset: const Offset(0, 6))],
                ),
                alignment: Alignment.center,
                child: Text(btnLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xff24126a),
                      fontSize: 15, fontWeight: FontWeight.w900)),
              ),
            ]),
          ),
          Positioned(
            top: -13,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(18)),
              alignment: Alignment.center,
              child: Text(badge,
                style: const TextStyle(color: Color(0xff24126a),
                    fontSize: 13, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        minimumSize: const Size(0, 30),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label,
        style: const TextStyle(color: Color(0xffb8aafd),
            fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }
}

class _SunsetPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size,
      Paint()..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xffff5d69), Color(0xff7644ac), Color(0xff19155b)],
      ).createShader(Offset.zero & size));

    canvas.drawCircle(
      Offset(size.width * .26, size.height * .45),
      size.width * .34,
      Paint()..shader = RadialGradient(colors: [
        const Color(0xffffd16b).withValues(alpha: 0.92),
        const Color(0xffff7d65).withValues(alpha: 0.22),
        Colors.transparent,
      ]).createShader(Rect.fromCircle(
        center: Offset(size.width * .26, size.height * .45),
        radius: size.width * .34)));

    final mtn = Paint()..color = const Color(0xff2d1e68);
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * .66)
        ..lineTo(size.width * .18, size.height * .42)
        ..lineTo(size.width * .32, size.height * .62)
        ..lineTo(size.width * .48, size.height * .38)
        ..lineTo(size.width * .68, size.height * .68)
        ..lineTo(size.width, size.height * .46)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      mtn);

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * .76)
        ..quadraticBezierTo(size.width * .22, size.height * .64,
            size.width * .46, size.height * .76)
        ..quadraticBezierTo(size.width * .68, size.height * .88,
            size.width, size.height * .68)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close(),
      Paint()..color = const Color(0xff151047));

    final stars = Paint()..color = Colors.white.withValues(alpha: 0.68);
    for (var i = 0; i < 36; i++) {
      final x = ((math.sin(i * 12.989) * 43758.5453) % 1).abs() * size.width;
      final y = ((math.sin(i * 7.123) * 24634.6345) % 1).abs() *
          size.height * .56;
      canvas.drawCircle(Offset(x, y), 1.2, stars);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
