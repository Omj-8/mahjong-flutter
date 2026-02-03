import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_model.dart';
import '../models/history_model.dart';

class HistoryService {
  static const _historyKey = 'session_history';
  static const _cumulativeKey = 'cumulative_totals';

  Future<List<SessionEntry>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_historyKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => SessionEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, int>> loadCumulative() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cumulativeKey);
    if (raw == null || raw.isEmpty) {
      return {};
    }
    final Map<String, dynamic> decoded =
        jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as int));
  }

  Future<void> addSession(GameResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await loadHistory();
    final cumulative = await loadCumulative();

    final entry = SessionEntry(
      dateTimeIso: DateTime.now().toIso8601String(),
      players: result.players
          .map(
            (p) => SessionPlayer(
              name: p.name,
              finalScore: p.finalScore,
              totalPoints: p.totalPoints,
            ),
          )
          .toList(),
    );

    history.insert(0, entry);

    for (final player in result.players) {
      cumulative[player.name] =
          (cumulative[player.name] ?? 0) + player.totalPoints;
    }

    await prefs.setString(
      _historyKey,
      jsonEncode(history.map((e) => e.toJson()).toList()),
    );

    await prefs.setString(_cumulativeKey, jsonEncode(cumulative));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    await prefs.remove(_cumulativeKey);
  }
}
