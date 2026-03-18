import 'package:flutter/material.dart';
import 'package:futdle/core/firebase/firestore_service.dart';
import 'package:futdle/core/theme/app_colors.dart';
import 'package:futdle/features/wordle/wordle_game_logic.dart';
import 'package:futdle/features/wordle/components/player_guess_row.dart';
import 'package:futdle/features/wordle/components/player_search_field.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tela principal do Jogo Wordle do FutDLE.
///
/// ## Fluxo do jogo:
///  Ao abrir, busca o jogador misterioso do dia no Firestore (`daily_player/today`)
///  O usuário digita o nome de um jogador no campo de busca
///  Ao selecionar, a lógica compara os atributos e mostra feedback colorido
///  O jogador tem até 6 tentativas para adivinhar
///  Se acertar → tela de vitória 🎉
///  Se esgotar as tentativas → revela o jogador misterioso
///
/// ## Componentes usados:
/// - [PlayerSearchField] → campo de busca com autocomplete
/// - [PlayerGuessRow] → linha de feedback colorido por palpite
/// - [WordleGameLogic] → lógica de comparação
class WordlePage extends StatefulWidget {
  const WordlePage({super.key});

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  final _firestoreService = FirestoreService();

  /// Dados do jogador misterioso (do Firestore).
  Map<String, dynamic>? _targetPlayer;

  /// Lista de comparações (palpites feitos).
  final List<GuessComparison> _guesses = [];

  /// Lista de nomes já palpitados (para evitar repetição).
  final List<String> _guessedNames = [];

  /// Estado do jogo.
  bool _isLoading = true;
  bool _hasWon = false;
  bool _hasLost = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTargetPlayer();
  }

  /// Carrega o jogador misterioso do dia do Firestore.
  Future<void> _loadTargetPlayer() async {
    try {
      final player = await _firestoreService.getDailyPlayer();

      if (player == null) {
        setState(() {
          _errorMessage =
              'Nenhum jogador do dia encontrado.\n'
              'Execute o sorteio primeiro (GameManager.randomPlayer).';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _targetPlayer = player;
        _isLoading = false;
      });

      // Pré-carrega a lista de jogadores para o autocomplete
      await _firestoreService.getAllPlayers();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar o jogo: $e';
        _isLoading = false;
      });
    }
  }

  /// Processa um palpite do jogador.
  void _onPlayerGuessed(Map<String, dynamic> guessPlayer) {
    if (_targetPlayer == null || _hasWon || _hasLost) return;

    // Compara o palpite com o jogador misterioso
    final comparison = WordleGameLogic.compare(guessPlayer, _targetPlayer!);

    setState(() {
      _guesses.add(comparison);
      _guessedNames.add(guessPlayer['name'] as String);

      if (comparison.isCorrect) {
        _hasWon = true;
      } else if (_guesses.length >= WordleGameLogic.maxAttempts) {
        _hasLost = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Wordle',
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildError()
            : _buildGame(),
      ),
    );
  }

  /// Tela de erro quando o jogador do dia não foi encontrado.
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 14,
                color: AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tela principal do jogo.
  Widget _buildGame() {
    return Column(
      children: [
        // Header com legenda e tentativas restantes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Legenda das cores
              Row(
                children: [
                  _legendDot(AppColors.success, 'Certo'),
                  const SizedBox(width: 8),
                  _legendDot(AppColors.warning, 'Quase'),
                  const SizedBox(width: 8),
                  _legendDot(AppColors.error, 'Errado'),
                ],
              ),
              // Contador de tentativas
              Text(
                '${_guesses.length}/${WordleGameLogic.maxAttempts}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dark,
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Lista de palpites (scrollable)
        Expanded(
          child: _guesses.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount:
                      _guesses.length + (_hasWon ? 1 : 0) + (_hasLost ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Mensagem de vitória/derrota no final
                    if (index == _guesses.length) {
                      return _hasWon ? _buildWinMessage() : _buildLoseMessage();
                    }
                    return PlayerGuessRow(comparison: _guesses[index]);
                  },
                ),
        ),

        // Campo de busca (no rodapé)
        if (!_hasWon && !_hasLost)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              boxShadow: [
                BoxShadow(
                  color: AppColors.dark.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: PlayerSearchField(
              onPlayerSelected: _onPlayerGuessed,
              guessedNames: _guessedNames,
            ),
          ),
      ],
    );
  }

  /// Estado vazio — quando ainda não fez nenhum palpite.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Quem é o jogador\nmisterioso de hoje?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Digite o nome de um jogador\npara começar',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 13,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mensagem de vitória.
  Widget _buildWinMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success, width: 2),
      ),
      child: Column(
        children: [
          const Text('🎉', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            'Parabéns! Você acertou!',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'O jogador era ${_targetPlayer?['name']}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              color: AppColors.dark,
            ),
          ),
          Text(
            'Acertou em ${_guesses.length} tentativa${_guesses.length > 1 ? 's' : ''}!',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Mensagem de derrota.
  Widget _buildLoseMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error, width: 2),
      ),
      child: Column(
        children: [
          const Text('😔', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            'Não foi dessa vez!',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'O jogador era:',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _targetPlayer?['name'] ?? '???',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
          Text(
            '${_targetPlayer?['team']} • ${_targetPlayer?['league']}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Bolinha de legenda das cores.
  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppColors.grey),
        ),
      ],
    );
  }
}
