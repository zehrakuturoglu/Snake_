import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScoreEntry {
  final String name;
  final int score;

  ScoreEntry({required this.name, required this.score});

  Map<String, dynamic> toJson() => {
    'name': name,
    'score': score,
  };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) {
    return ScoreEntry(
      name: json['name'],
      score: json['score'],
    );
  }
}

class HighScoreManager {
  static const String _key = 'high_scores';

  static Future<void> saveScore(String name, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key) ?? '[]';
    List list = json.decode(jsonString);

    List<ScoreEntry> scores =
    list.map((e) => ScoreEntry.fromJson(e)).toList();
    // ⚠️ Aynı isim varsa ekleme
    if (scores.any((entry) => entry.name == name)) {
      print('This name already used: $name');
      return;
    }

    scores.add(ScoreEntry(name: name, score: score));
    scores.sort((a, b) => b.score.compareTo(a.score)); // yüksekten düşüğe

    if (scores.length > 10) {
      scores = scores.sublist(0, 10); // sadece ilk 10 skor
    }

    final updatedJson =
    json.encode(scores.map((e) => e.toJson()).toList());
    await prefs.setString(_key, updatedJson);
  }

  static Future<List<ScoreEntry>> getTopScores() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key) ?? '[]';
    List list = json.decode(jsonString);
    return list.map((e) => ScoreEntry.fromJson(e)).toList();
  }

  static Future<List<ScoreEntry>> getTop3Scores() async {
    final scores = await getTopScores();
    scores.sort((a, b) => b.score.compareTo(a.score));
    return scores.take(3).toList();
  }

  static Future<bool> isPlayerInTop3(String name, int score) async {
    final topScores = await getTop3Scores();
    return topScores.any((entry) => entry.name == name && entry.score == score);
  }

  static Future<ScoreEntry?> getPlayerScoreEntry(String name, int score) async {
    final scores = await getTopScores();
    return scores.firstWhere(
          (entry) => entry.name == name && entry.score == score,
      orElse: () => ScoreEntry(name: name, score: score),
    );
  }
  static Future<void> updateScore(String name, int newScore) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key) ?? '[]';
    List list = json.decode(jsonString);

    List<ScoreEntry> scores = list.map((e) => ScoreEntry.fromJson(e)).toList();

    for (int i = 0; i < scores.length; i++) {
      if (scores[i].name == name) {
        if (newScore > scores[i].score) {
          scores[i] = ScoreEntry(name: name, score: newScore);
          print("Score is update: $name → $newScore");
        } else {
          print("New score is lower, not updated.");
        }
        break;
      }
    }

    scores.sort((a, b) => b.score.compareTo(a.score));
    if (scores.length > 10) {
      scores = scores.sublist(0, 10);
    }

    final updatedJson = json.encode(scores.map((e) => e.toJson()).toList());
    await prefs.setString(_key, updatedJson);
  }

}
