import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../logger/app_logger.dart';

class ImportPlayers {
  static Future<int> run() async {
    final db = FirebaseFirestore.instance;

    AppLogger.info('Lendo arquivo players_data.json...');
    final jsonString = await rootBundle.loadString('assets/players_data.json');
    final List<dynamic> playersJson = jsonDecode(jsonString);
    AppLogger.info('${playersJson.length} jogadores encontrados no JSON.');

    final Set<String> seenNames = {};
    final List<Map<String, dynamic>> uniquePlayers = [];
    for (final player in playersJson) {
      final name = player['name'] as String;
      if (!seenNames.contains(name)) {
        seenNames.add(name);
        uniquePlayers.add(Map<String, dynamic>.from(player));
      }
    }
    AppLogger.info(
      '${uniquePlayers.length} jogadores únicos após remover duplicatas.',
    );

    int imported = 0;
    const int batchSize = 500;

    for (int i = 0; i < uniquePlayers.length; i += batchSize) {
      final batch = db.batch();
      final end = (i + batchSize > uniquePlayers.length)
          ? uniquePlayers.length
          : i + batchSize;

      for (int j = i; j < end; j++) {
        final player = uniquePlayers[j];
        // Cria um novo documento com ID automático
        final docRef = db.collection('player_list').doc();

        batch.set(docRef, {
          'name': player['name'],
          // nameLower é usado para busca case-insensitive no autocomplete
          'nameLower': (player['name'] as String).toLowerCase(),
          'age': player['age'],
          'nationality': player['nationality'],
          'team': player['team'],
          'league': player['league'],
          'position': player['position'],
        });
      }

      // Executa o batch (envia tudo de uma vez pro Firestore)
      await batch.commit();
      imported += (end - i);
      AppLogger.info('Batch importado: $imported/${uniquePlayers.length}');
    }

    AppLogger.info(
      ' Importação concluída! $imported jogadores salvos no Firestore.',
    );
    return imported;
  }
}
