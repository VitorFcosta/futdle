import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/player_model.dart';
import '../models/user_stats.dart';
import '../exceptions/app_exceptions.dart';

/// Serviço responsável por toda interação com o Firestore.
/// Isola a lógica de banco do restante do app.
class FirestoreService {
  final FirebaseFirestore _db;

  /// Cache local da lista de jogadores para evitar leituras repetidas.
  /// Carregada uma vez e reutilizada durante toda a sessão.
  List<Map<String, dynamic>>? _playersCache;

  FirestoreService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  /// Salva o jogador do dia na collection `daily_player`, documento `today`.
  Future<void> saveDailyPlayer(PlayerModel player) async {
    try {
      final stats = player.statistics;

      await _db.collection('daily_player').doc('today').set({
        'name': player.name,
        'age': player.age,
        'nationality': player.nationality,
        'team': stats?.teamName,
        'teamCrest': stats?.teamCrest,
        'league': stats?.leagueName,
        'leagueEmblem': stats?.leagueEmblem,
        'position': stats?.position,
        'photo': player.photo,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Erro ao salvar jogador do dia: $e');
    }
  }

  /// Salva o jogador do dia a partir de um Map (vindo da collection `player_list`).
  /// Usado pelo [GameManager] para salvar o jogador sorteado.
  Future<void> saveDailyPlayerFromMap(Map<String, dynamic> playerData) async {
    try {
      final now = DateTime.now();
      final dateId =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Salva no doc 'today' (acesso rápido à partida atual)
      await _db.collection('daily_player').doc('today').set({
        ...playerData,
        'dateId': dateId,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Salva no histórico para o WordleHistoryPage
      await _db.collection('daily_history').doc(dateId).set({
        ...playerData,
        'dateId': dateId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw FirestoreException('Erro ao salvar jogador do dia: $e');
    }
  }

  /// Busca o jogador do dia salvo no Firestore.
  /// Retorna `null` se não existir.
  Future<Map<String, dynamic>?> getDailyPlayer() async {
    try {
      final doc = await _db.collection('daily_player').doc('today').get();
      return doc.data();
    } catch (e) {
      throw FirestoreException('Erro ao buscar jogador do dia: $e');
    }
  }

  /// Carrega TODOS os jogadores da coleção `player_list` em memória.
  ///
  /// Usa cache local: a primeira chamada busca do Firestore,
  /// chamadas subsequentes retornam o cache.
  /// Com ~200 jogadores (~50KB), isso é eficiente e evita
  /// queries repetidas ao Firestore (economiza leituras).
  Future<List<Map<String, dynamic>>> getAllPlayers() async {
    if (_playersCache != null) return _playersCache!;

    try {
      final snapshot = await _db.collection('player_list').get();
      _playersCache = snapshot.docs.map((doc) => doc.data()).toList();
      return _playersCache!;
    } catch (e) {
      throw FirestoreException('Erro ao buscar lista de jogadores: $e');
    }
  }

  /// Busca jogadores cujo nome contém a [query].
  ///
  /// A busca é feita localmente em memória (filtrando o cache)
  /// para ser instantânea e não gastar leituras do Firestore.
  /// Usa o campo `nameLower` para busca case-insensitive.
  Future<List<Map<String, dynamic>>> searchPlayers(String query) async {
    final allPlayers = await getAllPlayers();
    final queryLower = query.toLowerCase();

    return allPlayers
        .where(
          (p) => (p['nameLower'] ?? p['name'].toString().toLowerCase())
              .contains(queryLower),
        )
        .toList();
  }

  /// NOVO: Iterar por toda a coleção `player_list` e atualizar `teamCrest` e `leagueEmblem`
  /// usando o mapeamento fornecido [teamCrestsMap] do nome do time em lowerCase para a URL.
  Future<int> updatePlayersWithCrests(Map<String, String> teamCrestsMap) async {
    try {
      final snapshot = await _db.collection('player_list').get();
      int updatedCount = 0;
      
      // Batch writes permitem até 500 operações por vez. 
      // Como devemos ter menos de 500 players, 1 batch pode ser suficiente.
      // Se tiver mais, dividimos.
      final int batchSize = 450; 
      
      for (int i = 0; i < snapshot.docs.length; i += batchSize) {
        final batch = _db.batch();
        final end = (i + batchSize > snapshot.docs.length) 
           ? snapshot.docs.length 
           : i + batchSize;
           
        for (int j = i; j < end; j++) {
           final doc = snapshot.docs[j];
           final data = doc.data();
           
           final teamName = data['team']?.toString().toLowerCase();
           final leagueCode = data['league']?.toString();
           
           if (teamName != null && leagueCode != null) {
              final crestUrl = teamCrestsMap[teamName];
              final emblemUrl = 'https://crests.football-data.org/$leagueCode.png';
              
              if (crestUrl != null) {
                 batch.update(doc.reference, {
                   'teamCrest': crestUrl,
                   'leagueEmblem': emblemUrl,
                 });
                 updatedCount++;
              }
           }
        }
        
        await batch.commit();
      }
      
      // Limpar cache local após atualizar
      _playersCache = null;
      
      return updatedCount;
    } catch (e) {
      throw FirestoreException('Erro ao atualizar times em batch: $e');
    }
  }

  // ==========================================
  // STREAK & HISTÓRICO
  // ==========================================

  /// Busca os status do usuário autenticado no banco.
  Future<UserStats> getUserStats(String uid) async {
    try {
      final doc = await _db.collection('user_stats').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserStats.fromJson(doc.data()!);
      }
      return UserStats();
    } catch (e) {
      throw FirestoreException('Erro ao buscar stats do usuário: $e');
    }
  }

  /// Salva ou atualiza os status do usuário.
  Future<void> updateUserStats(String uid, UserStats stats) async {
    try {
      await _db
          .collection('user_stats')
          .doc(uid)
          .set(stats.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Erro ao salvar stats do usuário: $e');
    }
  }

  /// Busca histórico de dias recentes, limitado a 30 dias passados.
  Future<List<Map<String, dynamic>>> getDailyHistory() async {
    try {
      final snapshot = await _db
          .collection('daily_history')
          .orderBy('dateId', descending: true)
          .limit(30)
          .get();
      return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } catch (e) {
      throw FirestoreException('Erro ao buscar histórico diário: $e');
    }
  }
}
