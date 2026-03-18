class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.football-data.org/v4';

  static const List<String> topLeagues = ['PL', 'PD', 'SA', 'BL1', 'FL1'];

  static int get currentSeason {
    final now = DateTime.now();
    return now.month >= 8 ? now.year : now.year - 1;
  }
}
