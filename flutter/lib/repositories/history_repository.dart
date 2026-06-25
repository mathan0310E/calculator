import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calc_pro/models/history_entry.dart';

class HistoryRepository {
  static const _key = 'calc_history_v2';

  Future<List<HistoryEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key);
    if (data == null) return [];
    return data.map((json) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return HistoryEntry.fromJson(map);
    }).toList();
  }

  Future<void> save(List<HistoryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final data = entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, data);
  }

  Future<void> add(HistoryEntry entry, List<HistoryEntry> existing) async {
    final updated = [entry, ...existing];
    if (updated.length > 100) {
      updated.removeRange(100, updated.length);
    }
    await save(updated);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
