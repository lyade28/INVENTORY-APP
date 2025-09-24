import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inventaire_session.dart';
import '../models/scan_entry.dart';

class LocalStorageService {
  static const _sessionsKey = 'inventaire_sessions';

  static Future<List<InventaireSession>> getSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => InventaireSession(
      id: e['id'],
      name: e['name'],
      createdAt: DateTime.parse(e['createdAt']),
      scans: (e['scans'] as List).map((s) => ScanEntry(
        barcode: s['barcode'],
        siteCode: s['siteCode'],
        localisationCode: s['localisationCode'],
      )).toList(),
    )).toList();
  }

  static Future<void> saveSessions(List<InventaireSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(sessions.map((s) => {
      'id': s.id,
      'name': s.name,
      'createdAt': s.createdAt.toIso8601String(),
      'scans': s.scans.map((e) => {
        'barcode': e.barcode,
        'siteCode': e.siteCode,
        'localisationCode': e.localisationCode,
      }).toList(),
    }).toList());
    await prefs.setString(_sessionsKey, raw);
  }

  static Future<void> addScanToSession(String sessionId, ScanEntry entry) async {
    final sessions = await getSessions();
    final index = sessions.indexWhere((s) => s.id == sessionId);
    if (index != -1) {
      sessions[index].scans.add(entry);
      await saveSessions(sessions);
    }
  }

  static Future<void> removeSession(String sessionId) async {
    final sessions = await getSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    await saveSessions(sessions);
  }
}
