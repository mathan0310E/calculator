import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calc_pro/models/history_entry.dart';
import 'package:calc_pro/repositories/history_repository.dart';

class HistoryNotifier extends StateNotifier<List<HistoryEntry>> {
  final HistoryRepository _repository;

  HistoryNotifier(this._repository) : super([]);

  Future<void> load() async {
    state = await _repository.load();
  }

  Future<void> add(HistoryEntry entry) async {
    state = [entry, ...state];
    if (state.length > 100) {
      state = state.sublist(0, 100);
    }
    await _repository.save(state);
  }

  Future<void> clear() async {
    state = [];
    await _repository.clear();
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<HistoryEntry>>((ref) {
  final repo = HistoryRepository();
  final notifier = HistoryNotifier(repo);
  notifier.load();
  return notifier;
});
