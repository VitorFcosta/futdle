import 'dart:math';
import 'package:futdle/core/api/api_service.dart';
import 'package:futdle/core/api/api_constants.dart';
import 'package:futdle/core/firebase/firestore_service.dart';
import 'package:futdle/core/exceptions/app_exceptions.dart';
import 'package:futdle/core/logger/app_logger.dart';
import 'package:futdle/core/di/injection.dart';

/// Gerenciador principal dos jogos.
/// Orquestra a lógica de negócio (sortear jogador do dia)
/// usando [FirestoreService] para buscar e persistir dados.
///
/// Fluxo: Os jogadores já foram importados da API para o Firestore
/// pelo script [FetchAndImportPlayers]. O GameManager apenas
/// sorteia um aleatório da collection `player_list` e o salva
/// como o jogador do dia em `daily_player`.
class DailyPlayerManager {
  final FirestoreService _firestoreService;
  final ApiService _apiService;

  DailyPlayerManager({FirestoreService? firestoreService, ApiService? apiService})
    : _firestoreService = firestoreService ?? getIt<FirestoreService>(),
      _apiService = apiService ?? getIt<ApiService>();

  /// Sorteia um jogador aleatório da collection `player_list` do Firestore
  /// e o salva como jogador do dia na collection `daily_player`.
  ///
  /// Lança [PlayerNotFoundException] se a collection estiver vazia.
  Future<void> randomPlayer() async {
    final random = Random();

    AppLogger.info('Buscando lista de jogadores do Firestore...');

    try {
      final players = await _firestoreService.getAllPlayers();

      if (players.isEmpty) {
        throw const PlayerNotFoundException(
          'Nenhum jogador encontrado no banco de dados. '
          'Execute a importação primeiro.',
        );
      }

      final playerData = players[random.nextInt(players.length)];

      AppLogger.info('Jogador sorteado: "${playerData['name']}"');

      // Salva diretamente o Map como jogador do dia
      await _firestoreService.saveDailyPlayerFromMap(playerData);

      AppLogger.info(
        'Jogador do dia salvo com sucesso: "${playerData['name']}"',
      );
    } catch (e) {
      if (e is PlayerNotFoundException) rethrow;
      AppLogger.error('Erro ao sortear jogador', e);
      throw const PlayerNotFoundException(
        'Não foi possível sortear um jogador. Tente novamente mais tarde.',
      );
    }
  }

  /// NOVO: Sorteia o jogador do dia buscando DIRETAMENTE da API.
  /// Isso atende aos requisitos do professor de consumo de API em tempo real.
  /// Faz apenas 2 requests (1 de liga, 1 de time) para evitar os limites do Rate Limit.
  Future<void> randomPlayerFromAPI() async {
    final random = Random();
    const maxAttempts = 3;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      // Sorteia uma das top leagues configuradas no App
      final leagueCode = ApiConstants
          .topLeagues[random.nextInt(ApiConstants.topLeagues.length)];

      AppLogger.info(
        'Sorteio da API (Tentativa $attempt) -> Liga escolhida: $leagueCode',
      );

      try {
        final playerData = await _apiService.fetchRandomPlayerFromAPI(
          leagueCode,
        );

        AppLogger.info('Jogador sorteado da API: "${playerData['name']}"');

        // Salva no Firestore e sobrescreve o atual jogador do dia
        await _firestoreService.saveDailyPlayerFromMap(playerData);

        AppLogger.info('Jogador do dia atualizado com sucesso no Firestore 🎉');
        return;
      } catch (e) {
        AppLogger.error('Erro na tentativa $attempt da API', e);

        if (attempt >= maxAttempts) {
          throw Exception(
            'Não foi possível sortear um jogador da API.'
            'Verifique sua conexão, API_KEY ou se o rate limit (10/min) foi atingido. Erro final: $e',
          );
        }
      }
    }
  }

  /// Método utilitário para atualizar todos os jogadores no Firestore
  /// com os campos `teamCrest` e `leagueEmblem`, usando os dados da API.
  /// Isso é necessário pois os jogadores já existentes no banco não têm esses campos.
  Future<int> updateAllPlayersWithCrests() async {
    AppLogger.info('Iniciando atualização em lote dos escudos no Firestore...');

    try {
      // 1. Cria um dicionário com todos os times das topLeagues
      final Map<String, String> teamCrestsMap = {};
      
      for (final leagueCode in ApiConstants.topLeagues) {
        AppLogger.info('Buscando times da liga: $leagueCode');
        try {
          final teams = await _apiService.fetchTeamsByLeague(leagueCode);
          for (final team in teams) {
            final teamName = team['shortName'] ?? team['name'];
            if (teamName != null && team['crest'] != null) {
              // Usamos lowerCase pro match ser mais fácil
              teamCrestsMap[teamName.toString().toLowerCase()] = team['crest'];
            }
          }
          // Delay menor só pra evitar rate limit caso a API seja chata
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          AppLogger.error('Erro ao buscar times da liga $leagueCode: $e');
        }
      }

      return await _firestoreService.updatePlayersWithCrests(teamCrestsMap);
      
    } catch (e) {
      AppLogger.error('Erro geral ao atualizar escudos: $e');
      rethrow;
    }
  }
}

