import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/player_model.dart';
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
        'league': stats?.leagueName,
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
      await _db.collection('daily_player').doc('today').set({
        ...playerData,
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
}
