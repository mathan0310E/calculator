class HistoryEntry {
  final String expression;
  final String result;
  final DateTime timestamp;

  const HistoryEntry({
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
