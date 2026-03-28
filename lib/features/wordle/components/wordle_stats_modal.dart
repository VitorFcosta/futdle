import 'package:flutter/material.dart';
import 'package:futdle/core/theme/app_colors.dart';
import 'package:futdle/features/wordle/wordle_game_logic.dart';
import 'package:futdle/core/models/user_stats.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:futdle/features/wordle/pages/wordle_history_page.dart';

class WordleStatsModal extends StatelessWidget {
  final UserStats stats;
  final List<GuessComparison> currentGuesses;
  final bool isDailyStreak;
  final bool hasWon;
  final String dateId;

  const WordleStatsModal({
    super.key,
    required this.stats,
    required this.currentGuesses,
    required this.isDailyStreak,
    required this.hasWon,
    required this.dateId,
  });

  static void show(
    BuildContext context, {
    required UserStats stats,
    required List<GuessComparison> guesses,
    required bool isDailyStreak,
    required bool hasWon,
    required String dateId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WordleStatsModal(
        stats: stats,
        currentGuesses: guesses,
        isDailyStreak: isDailyStreak,
        hasWon: hasWon,
        dateId: dateId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isDailyStreak ? 'Estatísticas' : 'Modo Histórico',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 24),

            if (isDailyStreak) ...[
              // Linha de Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statItem('JOGOS', stats.gamesPlayed.toString()),
                  _statItem(
                    'VITÓRIAS',
                    '${stats.gamesPlayed > 0 ? ((stats.gamesWon / stats.gamesPlayed) * 100).round() : 0}%',
                  ),
                  _statItem('STREAK', stats.currentStreak.toString()),
                  _statItem('MÁXIMO', stats.maxStreak.toString()),
                ],
              ),
              const SizedBox(height: 24),

              // Distribuição de Acertos
              Text(
                'Distribuição de Acertos',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 12),
              _buildDistributionChart(),
            ] else ...[
              Text(
                hasWon ? '🥳 Partida Arquivada Concluída!' : '😔 Fim de Jogo',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: hasWon ? AppColors.success : AppColors.error,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Botões de Ação
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context); // fecha modal
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WordleHistoryPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history, color: Colors.white),
                    label: const Text(
                      'VER HISTÓRICO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context); // Volta à Home
              },
              child: const Text(
                'Voltar ao Início',
                style: TextStyle(color: AppColors.dark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.dark,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildDistributionChart() {
    int maxBarValue = 1;
    for (var count in stats.guessDistribution.values) {
      if (count > maxBarValue) maxBarValue = count;
    }

    return Column(
      children: List.generate(6, (index) {
        final guessLength = index + 1;
        final count = stats.guessDistribution[guessLength] ?? 0;
        final flex = (count / maxBarValue * 100).round();

        final isCurrentGame = hasWon && currentGuesses.length == guessLength;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Text(
                '$guessLength',
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width =
                        constraints.maxWidth * (flex > 5 ? flex / 100 : 0.05);
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: width,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        color: isCurrentGame
                            ? AppColors.success
                            : AppColors.grey.withValues(alpha: 0.5),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
