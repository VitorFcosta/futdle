import 'package:flutter/material.dart';
import 'package:futdle/core/firebase/auth_service.dart';
import 'package:futdle/core/firebase/firestore_service.dart';
import 'package:futdle/core/theme/app_colors.dart';
import 'package:futdle/features/wordle/wordle_game_logic.dart';
import 'package:futdle/features/wordle/components/player_guess_row.dart';
import 'package:futdle/features/wordle/components/player_search_field.dart';
import 'package:futdle/features/wordle/components/wordle_stats_modal.dart';
import 'package:futdle/core/models/user_stats.dart';
import 'package:futdle/core/models/player_model.dart';
import 'package:google_fonts/google_fonts.dart';

class WordlePage extends StatefulWidget {
  final PlayerModel? targetPlayerToPlay;
  final bool isDailyStreak;

  const WordlePage({
    super.key,
    this.targetPlayerToPlay,
    this.isDailyStreak = true,
  });

  @override
  State<WordlePage> createState() => _WordlePageState();
}

class _WordlePageState extends State<WordlePage> {
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  PlayerModel? _targetPlayer;
  final List<GuessComparison> _guesses = [];
  final List<String> _guessedNames = [];

  bool _isLoading = true;
  bool _hasWon = false;
  bool _hasLost = false;
  bool _alreadyPlayedToday = false;
  String? _errorMessage;

  UserStats? _userStats;
  String? _dateId; // Data da partida (hoje ou historico)

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    try {
      final user = _authService.currentUser;

      // Carrega status apenas se for partida do dia (valendo streak)
      if (widget.isDailyStreak && user != null) {
        _userStats = await _firestoreService.getUserStats(user.uid);
      }

      PlayerModel? player;

      if (widget.targetPlayerToPlay != null) {
        player = widget.targetPlayerToPlay;
        _dateId = 'HISTORIC'; // Se vier um modelo pronto, provável não tem dateId cru, ou trata no modal
      } else {
        final rawPlayer = await _firestoreService.getDailyPlayer();
        if (rawPlayer != null) {
          player = PlayerModel.fromFlatMap(rawPlayer);
          _dateId = rawPlayer['dateId'];
        }
      }

      if (player == null) {
        setState(() {
          _errorMessage = 'Nenhum jogador encontrado para essa partida.';
          _isLoading = false;
        });
        return;
      }

      // Se for modo Diário, valida se o usuário já jogou hoje
      if (widget.isDailyStreak && _userStats != null && _dateId != null) {
        final last = _userStats!.lastPlayedDate;
        if (last != null) {
          final lastDateStr =
              '${last.year}-${last.month.toString().padLeft(2, '0')}-${last.day.toString().padLeft(2, '0')}';
          if (lastDateStr == _dateId) {
            _alreadyPlayedToday = true;
          }
        }
      }

      setState(() {
        _targetPlayer = player;
        _isLoading = false;
      });

      await _firestoreService.getAllPlayers();

      // Se já concluiu o desafio hoje, trava o jogo e mostra a modal.
      if (_alreadyPlayedToday) {
        // Bloqueia interações do campo de busca mudando estados
        _hasWon = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showResultsModal();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar o jogo: $e';
        _isLoading = false;
      });
    }
  }

  void _onPlayerGuessed(Map<String, dynamic> guessPlayerMap) {
    if (_targetPlayer == null || _hasWon || _hasLost || _alreadyPlayedToday) {
      return;
    }

    final guessPlayer = PlayerModel.fromFlatMap(guessPlayerMap);
    final comparison = WordleGameLogic.compare(guessPlayer, _targetPlayer!);

    setState(() {
      _guesses.add(comparison);
      _guessedNames.add(guessPlayer.name);

      if (comparison.isCorrect) {
        _hasWon = true;
        _finishGame();
      } else if (_guesses.length >= WordleGameLogic.maxAttempts) {
        _hasLost = true;
        _finishGame();
      }
    });
  }

  Future<void> _finishGame() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showResultsModal();
    });

    if (!widget.isDailyStreak) return;

    final user = _authService.currentUser;
    if (user == null || _userStats == null) return;

    final stats = _userStats!;

    // Atualiza base dos Status Diários
    final yesterdayStr =
        "${DateTime.now().subtract(const Duration(days: 1)).year}-${DateTime.now().subtract(const Duration(days: 1)).month.toString().padLeft(2, '0')}-${DateTime.now().subtract(const Duration(days: 1)).day.toString().padLeft(2, '0')}";
    final lastPlayedStr = stats.lastPlayedDate != null
        ? "${stats.lastPlayedDate!.year}-${stats.lastPlayedDate!.month.toString().padLeft(2, '0')}-${stats.lastPlayedDate!.day.toString().padLeft(2, '0')}"
        : null;

    stats.gamesPlayed += 1;
    stats.lastPlayedDate = DateTime.now();

    if (_hasWon) {
      stats.gamesWon += 1;

      if (lastPlayedStr == yesterdayStr) {
        stats.currentStreak += 1;
      } else {
        stats.currentStreak = 1; // Pulou um dia ou primeira vez: começa com 1
      }

      if (stats.currentStreak > stats.maxStreak) {
        stats.maxStreak = stats.currentStreak;
      }

      final tries = _guesses.length;
      stats.guessDistribution[tries] =
          (stats.guessDistribution[tries] ?? 0) + 1;
    } else {
      stats.currentStreak = 0;
    }

    try {
      await _firestoreService.updateUserStats(user.uid, stats);
    } catch (e) {
      debugPrint("Erro ao salvar estastísticas do usuário: $e");
    }
  }

  void _showResultsModal() {
    WordleStatsModal.show(
      context,
      stats: _userStats ?? UserStats(),
      guesses: _guesses,
      isDailyStreak: widget.isDailyStreak,
      hasWon: _guesses.isNotEmpty && _guesses.last.isCorrect,
      dateId: _dateId ?? 'HOJE',
    );
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
          widget.isDailyStreak ? 'Wordle Diário' : 'Wordle Histórico',
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

  Widget _buildGame() {
    return Column(
      children: [
        // Header de informações
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _legendDot(AppColors.success, 'Certo'),
                  const SizedBox(width: 8),
                  _legendDot(AppColors.warning, 'Quase'),
                  const SizedBox(width: 8),
                  _legendDot(AppColors.error, 'Errado'),
                ],
              ),
              if (!_alreadyPlayedToday)
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

        Expanded(
          child: _guesses.isEmpty && !_alreadyPlayedToday
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount:
                      _guesses.length +
                      (_hasWon && !_alreadyPlayedToday ? 1 : 0) +
                      (_hasLost && !_alreadyPlayedToday ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _guesses.length) {
                      return _hasWon && !_alreadyPlayedToday
                          ? _buildWinMessage()
                          : _buildLoseMessage();
                    }
                    return PlayerGuessRow(comparison: _guesses[index]);
                  },
                ),
        ),

        // Search Field ou Botão Ver Resultados
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
          child: _alreadyPlayedToday || _hasWon || _hasLost
              ? SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showResultsModal,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      '🌟 Ver Meus Resultados',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              : PlayerSearchField(
                  onPlayerSelected: _onPlayerGuessed,
                  guessedNames: _guessedNames,
                ),
        ),
      ],
    );
  }

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
            'O jogador era ${_targetPlayer?.name}',
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
            _targetPlayer?.name ?? '???',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.dark,
            ),
          ),
          Text(
            '${_targetPlayer?.statistics?.teamName ?? ''} • ${_targetPlayer?.statistics?.leagueName ?? ''}',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

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
