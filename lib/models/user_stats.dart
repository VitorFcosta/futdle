class UserStats {
  int currentStreak;
  int maxStreak;
  int gamesPlayed;
  int gamesWon;
  DateTime? lastPlayedDate;
  Map<int, int> guessDistribution;

  UserStats({
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.lastPlayedDate,
    Map<int, int>? guessDistribution,
  }) : guessDistribution = guessDistribution ?? {};

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      currentStreak: json['currentStreak'] ?? 0,
      maxStreak: json['maxStreak'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      lastPlayedDate: json['lastPlayedDate'] != null
          ? DateTime.parse(json['lastPlayedDate'])
          : null,
      guessDistribution: (json['guessDistribution'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(int.parse(key), value as int),
          ) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'lastPlayedDate': lastPlayedDate?.toIso8601String(),
      'guessDistribution': guessDistribution.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
    };
  }
}
