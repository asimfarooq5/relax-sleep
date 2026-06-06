import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import 'splash.dart' show kBg, kCard, kCardHi, kTeal, kText, kSub, kBorder;

class SleepScheduleScreen extends StatefulWidget {
  const SleepScheduleScreen({super.key});
  @override
  State<SleepScheduleScreen> createState() => _SleepScheduleScreenState();
}

class _SleepScheduleScreenState extends State<SleepScheduleScreen> {
  bool _bedtimeEnabled = true;
  bool _wakeEnabled = true;
  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  bool _loading = true;

  final List<bool> _dayEnabled = List.filled(7, true);
  final _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  @override
  void initState() {
    super.initState();
    _loadFromFirestore();
  }

  Future<void> _loadFromFirestore() async {
    final data = await PrefsService.loadSchedule();
    if (data.isNotEmpty) {
      setState(() {
        _bedtimeEnabled = data['bedtimeEnabled'] as bool? ?? true;
        _wakeEnabled    = data['wakeEnabled']    as bool? ?? true;
        _bedtime = TimeOfDay(
          hour:   data['bedtimeHour']   as int? ?? 22,
          minute: data['bedtimeMinute'] as int? ?? 0,
        );
        _wakeTime = TimeOfDay(
          hour:   data['wakeHour']   as int? ?? 7,
          minute: data['wakeMinute'] as int? ?? 0,
        );
        final days = data['days'] as List<dynamic>?;
        if (days != null && days.length == 7) {
          for (var i = 0; i < 7; i++) {
            _dayEnabled[i] = days[i] as bool? ?? true;
          }
        }
      });
    }
    setState(() => _loading = false);
  }

  Future<void> _saveToFirestore() async {
    await PrefsService.saveSchedule({
      'bedtimeEnabled': _bedtimeEnabled,
      'wakeEnabled':    _wakeEnabled,
      'bedtimeHour':   _bedtime.hour,
      'bedtimeMinute': _bedtime.minute,
      'wakeHour':   _wakeTime.hour,
      'wakeMinute': _wakeTime.minute,
      'days': List<bool>.from(_dayEnabled),
    });
  }

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  Future<void> _pickTime(bool isBedtime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBedtime ? _bedtime : _wakeTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xff00D4B4),
            surface: Color(0xff2A2770),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isBedtime) { _bedtime = picked; }
        else { _wakeTime = picked; }
      });
    }
  }

  void _applyToAll() {
    setState(() {
      for (var i = 0; i < 7; i++) _dayEnabled[i] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Schedule applied to all days.'),
      backgroundColor: kCard,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xff1E1B4B),
        body: Center(child: CircularProgressIndicator(color: Color(0xff00D4B4))),
      );
    }
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: const Text('Sleep',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                      color: kText, letterSpacing: -0.3)),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(children: [
                  // Bedtime reminder
                  _ReminderCard(
                    icon: Icons.nightlight_round,
                    title: 'Bedtime Reminder',
                    subtitle: 'Remind me to go to bed at',
                    enabled: _bedtimeEnabled,
                    onToggle: (v) => setState(() => _bedtimeEnabled = v),
                    time: _fmt(_bedtime),
                    onTimeTap: () => _pickTime(true),
                  ),
                  const SizedBox(height: 16),
                  // Wake reminder
                  _ReminderCard(
                    icon: Icons.alarm_rounded,
                    title: 'Wake-up Reminder',
                    subtitle: 'Wake me up at',
                    enabled: _wakeEnabled,
                    onToggle: (v) => setState(() => _wakeEnabled = v),
                    time: _fmt(_wakeTime),
                    onTimeTap: () => _pickTime(false),
                  ),
                  const SizedBox(height: 20),
                  // Weekly schedule header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      border: Border.all(color: kBorder),
                    ),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: kTeal.withValues(alpha: 0.15),
                          shape: BoxShape.circle),
                        child: const Icon(Icons.calendar_month_rounded,
                            color: kTeal, size: 20)),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Weekly Schedule',
                            style: TextStyle(fontSize: 15,
                                fontWeight: FontWeight.w700, color: kText)),
                          SizedBox(height: 2),
                          Text('Set your weekly reminders',
                            style: TextStyle(fontSize: 12, color: kSub)),
                        ],
                      ),
                    ]),
                  ),
                ]),
              ),
            ),
            // Day rows
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: kCard,
                      border: Border(
                        left: BorderSide(color: kBorder),
                        right: BorderSide(color: kBorder),
                        bottom: BorderSide(color: kBorder),
                      ),
                    ),
                    child: Row(children: [
                      SizedBox(
                        width: 36,
                        child: Text(_days[i],
                          style: const TextStyle(fontSize: 13,
                              fontWeight: FontWeight.w600, color: kSub)),
                      ),
                      const SizedBox(width: 8),
                      _TimeChip(time: _fmt(_wakeTime)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 14, color: kSub),
                      const SizedBox(width: 8),
                      _TimeChip(time: _fmt(_bedtime)),
                      const Spacer(),
                      Switch(
                        value: _dayEnabled[i],
                        onChanged: (v) =>
                            setState(() => _dayEnabled[i] = v),
                        activeColor: kTeal,
                        activeTrackColor: kTeal.withValues(alpha: 0.28),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ]),
                  ),
                ),
                childCount: 7,
              ),
            ),
            // Close bottom of weekly card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: kCard,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16)),
                    border: Border(
                      left: BorderSide(color: kBorder),
                      right: BorderSide(color: kBorder),
                      bottom: BorderSide(color: kBorder),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: OutlinedButton(
                  onPressed: _applyToAll,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: kText,
                    side: const BorderSide(color: kBorder),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Apply to all days',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                child: ElevatedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await _saveToFirestore();
                    if (!mounted) return;
                    messenger.showSnackBar(SnackBar(
                      content: const Text('Schedule saved!'),
                      backgroundColor: kTeal,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.all(16),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: kTeal,
                    foregroundColor: const Color(0xff0D2A27),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Save Schedule',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onToggle,
    required this.time,
    required this.onTimeTap,
  });
  final IconData icon;
  final String title, subtitle, time;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: kTeal.withValues(alpha: 0.15),
                shape: BoxShape.circle),
              child: Icon(icon, color: kTeal, size: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15,
                      fontWeight: FontWeight.w700, color: kText)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: kSub)),
                ])),
            Switch(
              value: enabled,
              onChanged: onToggle,
              activeColor: kTeal,
              activeTrackColor: kTeal.withValues(alpha: 0.28),
            ),
          ]),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onTimeTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: kCardHi,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kTeal.withValues(alpha: 0.4)),
              ),
              child: Row(children: [
                Text(time, style: const TextStyle(fontSize: 20,
                    fontWeight: FontWeight.w700, color: kTeal)),
                const Spacer(),
                Icon(Icons.edit_rounded, color: kTeal, size: 18),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.time});
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kCardHi,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: kTeal.withValues(alpha: 0.35)),
      ),
      child: Text(time,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
            color: kTeal)),
    );
  }
}
