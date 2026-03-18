import 'package:flutter/material.dart';
import 'package:futdle/core/theme/app_colors.dart';

/// Card de streaks — exibe maior streak e jogo com mais vitórias.
class StreakCard extends StatelessWidget {
  final int bestStreak;
  final String bestStreakGame;
  final String topWinsGame;
  final int topWinsCount;

  const StreakCard({
    super.key,
    this.bestStreak = 0,
    this.bestStreakGame = '--',
    this.topWinsGame = '--',
    this.topWinsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Pega os estilos do tema para usar Outfit nos títulos
    final theme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.dark, width: 2.5),
      ),
      child: Column(
        children: [
          // Título da seção — usa titleLarge do tema (fonte Outfit)
          Text('Streaks de vitórias', style: theme.titleLarge),
          const SizedBox(height: 24),
          IntrinsicHeight(
            child: Row(
              children: [
                // ===== COLUNA ESQUERDA: Maior Streak =====
                Expanded(
                  child: Column(
                    children: [
                      // Ícone de fogo — representa a "sequência quente"
                      const Icon(
                        Icons.local_fire_department,
                        color: Color(0xFFE67E22), // Laranja fogo
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      // Subtítulo — usa titleMedium do tema (Outfit)
                      Text('Maior streak', style: theme.titleMedium),
                      const SizedBox(height: 8),
                      // Número grande com cor laranja de destaque
                      // O número é o foco visual principal desta seção
                      Text(
                        bestStreak > 0 ? '$bestStreak' : '--',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFE67E22), // Laranja como o ícone
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Nome do jogo abaixo do número, em cinza secundário
                      Text(
                        bestStreakGame,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Divisor vertical entre as duas seções
                const VerticalDivider(
                  color: AppColors.dark,
                  thickness: 2,
                  width: 32,
                ),
                // ===== COLUNA DIREITA: Mais vitórias =====
                Expanded(
                  child: Column(
                    children: [
                      // Ícone de troféu — representa as conquistas
                      const Icon(
                        Icons.emoji_events,
                        color: Color(0xFFF39C12), // Dourado troféu
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Mais vitórias',
                        style: theme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Número grande com cor dourada de destaque
                      Text(
                        topWinsCount > 0 ? '$topWinsCount' : '--',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFF39C12), // Dourado como o ícone
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        topWinsGame,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
