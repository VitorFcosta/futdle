class PlayerModel {
  final int id;
  final String name;
  final int? age;
  final String? nationality;
  final String? photo;
  final PlayerStatistics? statistics;

  PlayerModel({
    required this.id,
    required this.name,
    this.age,
    this.nationality,
    this.photo,
    this.statistics,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    final player = json['player'];
    final statsList = json['statistics'] as List?;
    PlayerStatistics? stats;

    if (statsList != null && statsList.isNotEmpty) {
      stats = PlayerStatistics.fromJson(statsList[0]);
    }

    return PlayerModel(
      id: player['id'],
      name: player['name'],
      age: player['age'],
      nationality: player['nationality'],
      photo: player['photo'],
      statistics: stats,
    );
  }

  factory PlayerModel.fromFlatMap(Map<String, dynamic> map) {
    return PlayerModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? '') ?? 0,
      name: map['name'] ?? '',
      age: map['age'] != null ? int.tryParse(map['age'].toString()) : null,
      nationality: map['nationality'],
      photo: map['photo'],
      statistics: PlayerStatistics(
        teamName: map['team'],
        teamCrest: map['teamCrest'],
        leagueName: map['league'],
        leagueEmblem: map['leagueEmblem'],
        position: map['position'],
      ),
    );
  }

  /// Serializa o modelo para um Map — útil para salvar no Firestore ou cache local.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'nationality': nationality,
      'photo': photo,
      'statistics': statistics?.toJson(),
    };
  }
}

class PlayerStatistics {
  final String? teamName;
  final String? teamCrest;
  final String? leagueName;
  final String? leagueEmblem;
  final String? position;

  PlayerStatistics({
    this.teamName,
    this.teamCrest,
    this.leagueName,
    this.leagueEmblem,
    this.position,
  });

  factory PlayerStatistics.fromJson(Map<String, dynamic> json) {
    return PlayerStatistics(
      teamName: json['team']?['name'],
      teamCrest: json['team']?['crest'],
      leagueName: json['league']?['name'],
      leagueEmblem: json['league']?['emblem'],
      position: json['games']?['position'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamName': teamName,
      'teamCrest': teamCrest,
      'leagueName': leagueName,
      'leagueEmblem': leagueEmblem,
      'position': position,
    };
  }
}
