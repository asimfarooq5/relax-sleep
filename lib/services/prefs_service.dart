import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class PrefsService {
  static final _db = FirebaseFirestore.instance;

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static DocumentReference<Map<String, dynamic>>? get _ref {
    final uid = _uid;
    if (uid == null) {
      debugPrint('[PrefsService] No signed-in user — skipping Firestore op');
      return null;
    }
    return _db.collection('users').doc(uid);
  }

  // Merge-save any data into the user document
  static Future<void> save(Map<String, dynamic> data) async {
    try {
      await _ref?.set(data, SetOptions(merge: true));
      debugPrint('[PrefsService] Saved: ${data.keys}');
    } catch (e) {
      debugPrint('[PrefsService] Save error: $e');
    }
  }

  // Load the full user document
  static Future<Map<String, dynamic>> load() async {
    try {
      final snap = await _ref?.get();
      final result = snap?.data() ?? {};
      debugPrint('[PrefsService] Loaded keys: ${result.keys}');
      return result;
    } catch (e) {
      debugPrint('[PrefsService] Load error: $e');
      return {};
    }
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

  static Future<void> saveMix(double masterVolume,
      List<Map<String, dynamic>> sounds) =>
      save({'mix': {'masterVolume': masterVolume, 'sounds': sounds}});

  static Future<Map<String, dynamic>> loadMix() async {
    final data = await load();
    return (data['mix'] as Map<String, dynamic>?) ?? {};
  }
}
