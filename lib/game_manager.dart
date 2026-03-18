import 'dart:math';
import 'core/api/api_service.dart';
import 'core/api/api_constants.dart';
import 'core/firebase/firestore_service.dart';
import 'core/exceptions/app_exceptions.dart';
import 'core/logger/app_logger.dart';

/// Gerenciador principal dos jogos.
/// Orquestra a lógica de negócio (sortear jogador do dia)
/// usando [FirestoreService] para buscar e persistir dados.
///
/// Fluxo: Os jogadores já foram importados da API para o Firestore
/// pelo script [FetchAndImportPlayers]. O GameManager apenas
/// sorteia um aleatório da collection `player_list` e o salva
/// como o jogador do dia em `daily_player`.
class GameManager {
  final FirestoreService _firestoreService;
  final ApiService _apiService;

  GameManager({FirestoreService? firestoreService, ApiService? apiService})
    : _firestoreService = firestoreService ?? FirestoreService(),
      _apiService = apiService ?? ApiService();

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
}
