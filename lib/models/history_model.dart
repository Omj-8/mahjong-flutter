class SessionPlayer {
  final String name;
  final int finalScore;
  final int totalPoints;

  SessionPlayer({
    required this.name,
    required this.finalScore,
    required this.totalPoints,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'finalScore': finalScore,
      'totalPoints': totalPoints,
    };
  }

  factory SessionPlayer.fromJson(Map<String, dynamic> json) {
    return SessionPlayer(
      name: json['name'] as String,
      finalScore: json['finalScore'] as int,
      totalPoints: json['totalPoints'] as int,
    );
  }
}

class SessionEntry {
  final String dateTimeIso;
  final List<SessionPlayer> players;

  SessionEntry({
    required this.dateTimeIso,
    required this.players,
  });

  Map<String, dynamic> toJson() {
    return {
      'dateTimeIso': dateTimeIso,
      'players': players.map((p) => p.toJson()).toList(),
    };
  }

  factory SessionEntry.fromJson(Map<String, dynamic> json) {
    return SessionEntry(
      dateTimeIso: json['dateTimeIso'] as String,
      players: (json['players'] as List<dynamic>)
          .map((p) => SessionPlayer.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }
}
