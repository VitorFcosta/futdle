import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:futdle/core/api/api_service.dart';
import 'package:futdle/core/api/api_constants.dart';
import 'package:futdle/core/logger/app_logger.dart';

class FetchAndImportPlayers {
  static Future<void> run() async {
    final apiService = ApiService();
    final db = FirebaseFirestore.instance;
    
    int totalImported = 0;
    final Set<String> seenNames = {};

    AppLogger.info('Iniciando importação via football-data.org (Aguarde ~15 minutos)...');

    for (final leagueCode in ApiConstants.topLeagues) {
      AppLogger.info('Buscando times da liga: $leagueCode');
      
      try {
        final teams = await apiService.fetchTeamsByLeague(leagueCode);
        
        // Proteção de Rate Limit: 1 a cada 7 segundos (~8.5 por minuto)
        await Future.delayed(const Duration(seconds: 7)); 

        for (final team in teams) {
          final teamId = team['id'];
          final teamName = team['shortName'] ?? team['name'];
          
          AppLogger.info('Baixando elenco do $teamName...');

          final squad = await apiService.fetchSquadByTeam(teamId);
          final batch = db.batch();
          int batchCount = 0;

          for (final player in squad) {
            // A API envia o técnico junto no elenco. Vamos ignorá-lo e pegar só jogadores.
            if (player['position'] == null) continue;

            final String playerName = player['name'];
            
            if (!seenNames.contains(playerName)) {
              seenNames.add(playerName);

              final docRef = db.collection('player_list').doc();
              batch.set(docRef, {
                'name': playerName,
                'nameLower': playerName.toLowerCase(),
                'age': _calculateAge(player['dateOfBirth']), // Chamada para a função auxiliar
                'nationality': player['nationality'],
                'team': teamName,
                'league': leagueCode, // PL, PD, etc.
                'position': player['position'], // Ex: "Offence", "Midfield", "Defence"
              });
              
              batchCount++;
              totalImported++;
            }
          }

          if (batchCount > 0) {
            await batch.commit();
            AppLogger.info('+$batchCount jogadores salvos. Total atual: $totalImported');
          }

          // O segredo do script: Pausa 7 segundos antes de pedir o elenco do próximo time
          await Future.delayed(const Duration(seconds: 7));
        }

      } catch (e) {
        AppLogger.info('Erro ao processar liga $leagueCode: $e');
      }
    }

    AppLogger.info('🎉 Concluído! O banco de dados do seu Futdle está 100% atualizado.');
  }

  /// Função auxiliar para transformar a data de nascimento (ex: 1990-10-24) em idade
  static int? _calculateAge(String? dobString) {
    if (dobString == null) return null;
    try {
      final dob = DateTime.parse(dobString);
      final today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return null;
    }
  }
}