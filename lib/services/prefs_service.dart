import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrefsService {
  static final _db = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static DocumentReference<Map<String, dynamic>>? get _ref {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid);
  }

  // Merge-save any data into the user document
  static Future<void> save(Map<String, dynamic> data) async {
    try { await _ref?.set(data, SetOptions(merge: true)); } catch (_) {}
  }

  // Load the full user document
  static Future<Map<String, dynamic>> load() async {
    try {
      final snap = await _ref?.get();
      return snap?.data() ?? {};
    } catch (_) { return {}; }
  }

  // ── Convenience helpers ───────────────────────────────────────────────────

  static Future<void> saveSettings(Map<String, dynamic> settings) =>
      save({'settings': settings});

  static Future<Map<String, dynamic>> loadSettings() async {
    final data = await load();
    return (data['settings'] as Map<String, dynamic>?) ?? {};
  }

  static Future<void> saveSchedule(Map<String, dynamic> schedule) =>
      save({'schedule': schedule});

  static Future<Map<String, dynamic>> loadSchedule() async {
    final data = await load();
    return (data['schedule'] as Map<String, dynamic>?) ?? {};
  }
}
