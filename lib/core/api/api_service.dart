import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_constants.dart';
import '../exceptions/app_exceptions.dart';

class ApiService {
  final String _apiKey = dotenv.env['API_KEY'] ?? '';
  final String _baseUrl = ApiConstants.baseUrl;

  ApiService() {
    if (_apiKey.isEmpty) {
      debugPrint('API_KEY está vazia! Verifique o arquivo .env');
    } else {
      debugPrint('API_KEY carregada: ${_apiKey.substring(0, 4)}...');
    }
  }

  Map<String, String> get _headers => {'X-Auth-Token': _apiKey};

  ///  Busca todos os times de uma liga
  Future<List<dynamic>> fetchTeamsByLeague(String leagueCode) async {
    final url = Uri.parse('$_baseUrl/competitions/$leagueCode/teams');

    try {
      final response = await http.get(url, headers: _headers);
      debugPrint('📡 GET $url -> Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint(' Response body: ${response.body}');
        throw ApiException('Erro ao buscar times: ${response.statusCode}');
      }
      final data = jsonDecode(response.body);
      return data['teams'] ?? [];
    } catch (e) {
      debugPrint(' Exceção na API (Times): $e');
      throw ApiException('Erro na API (Times): $e');
    }
  }

  ///  Busca o elenco (squad) de um time específico
  Future<List<dynamic>> fetchSquadByTeam(int teamId) async {
    final url = Uri.parse('$_baseUrl/teams/$teamId');

    try {
      final response = await http.get(url, headers: _headers);
      debugPrint('📡 GET $url -> Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint(' Response body: ${response.body}');
        throw ApiException('Erro ao buscar elenco: ${response.statusCode}');
      }
      final data = jsonDecode(response.body);
      return data['squad'] ?? [];
    } catch (e) {
      debugPrint(' Exceção na API (Elenco): $e');
      throw ApiException('Erro na API (Elenco): $e');
    }
  }

  /// Sorteia um jogador diretamente da API
  /// Faz 2 requisições: 1 para ler os times da liga e 1 para pegar o elenco
  Future<Map<String, dynamic>> fetchRandomPlayerFromAPI(
    String leagueCode,
  ) async {
    try {
      final random = Random();

      // 1. Busca os times
      final teams = await fetchTeamsByLeague(leagueCode);
      if (teams.isEmpty) {
        throw ApiException('Nenhum time encontrado na liga $leagueCode');
      }

      // Proteção de rate limit simples
      await Future.delayed(const Duration(seconds: 1));

      // 2. Escolhe um time aleatório
      final randomTeam = teams[random.nextInt(teams.length)];
      final teamId = randomTeam['id'];
      final teamName = randomTeam['shortName'] ?? randomTeam['name'];

      // 3. Busca o elenco do time sorteado
      final squad = await fetchSquadByTeam(teamId);

      // 4. Filtra apenas os jogadores (ignorando a comissão técnica, que não tem 'position')
      final playersOnly = squad.where((p) => p['position'] != null).toList();
      if (playersOnly.isEmpty) {
        throw ApiException('O time $teamName não tem jogadores listados');
      }

      // 5. Escolhe um jogador aleatório
      final selectedPlayer = playersOnly[random.nextInt(playersOnly.length)];

      // 6. Formata os dados para o padrão do Firestore do aplicativo
      // Captura o escudo do time
      final teamCrest = randomTeam['crest'];

      // Monta a URL do emblema da liga a partir do código
      final leagueEmblem = 'https://crests.football-data.org/$leagueCode.png';

      return {
        'name': selectedPlayer['name'],
        'nameLower': selectedPlayer['name'].toString().toLowerCase(),
        'age': _calculateAge(selectedPlayer['dateOfBirth']),
        'nationality': selectedPlayer['nationality'],
        'team': teamName,
        'teamCrest': teamCrest,
        'league': leagueCode,
        'leagueEmblem': leagueEmblem,
        'position': selectedPlayer['position'],
      };
    } catch (e) {
      debugPrint(' Erro ao sortear jogador da API: $e');
      rethrow;
    }
  }

  /// Função auxiliar para transformar a data de nascimento em idade
  int? _calculateAge(String? dobString) {
    if (dobString == null) return null;
    try {
      final dob = DateTime.parse(dobString);
      final today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }
}
