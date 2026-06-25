import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryEntry {
  final String expression;
  final String result;
  final DateTime timestamp;

  HistoryEntry({
    required this.expression,
    required this.result,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'expression': expression,
        'result': result,
        'timestamp': timestamp.millisecondsSinceEpoch,
      };

  factory HistoryEntry.fromJson(Map<String, dynamic> json) => HistoryEntry(
        expression: json['expression'] as String,
        result: json['result'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      );
}

class CalculatorHistory {
  final List<HistoryEntry> _entries = [];
  static const _key = 'calc_history';

  List<HistoryEntry> get entries => List.unmodifiable(_entries);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key);
    if (data == null) return;
    _entries.clear();
    for (final json in data) {
      final map = jsonDecode(json) as Map<String, dynamic>;
      _entries.add(HistoryEntry.fromJson(map));
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_key, data);
  }

  void add(HistoryEntry entry) {
    _entries.insert(0, entry);
    if (_entries.length > 100) {
      _entries.removeLast();
    }
    save();
  }

  void clear() {
    _entries.clear();
    save();
  }
}
