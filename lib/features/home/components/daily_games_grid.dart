import 'package:flutter/material.dart';
import 'package:futdle/models/mini_game_model.dart';
import 'package:futdle/core/theme/app_colors.dart';
import 'package:futdle/features/wordle/pages/wordle_page.dart';

class DailyGamesGrid extends StatelessWidget {
  final List<MiniGameModel> games;

  const DailyGamesGrid({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Título da seção — usa headlineMedium do tema (fonte Outfit)
        Text(
          'jogos diários',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 60),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 40,
            crossAxisSpacing: 40,
            childAspectRatio: 1,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return _GameCircle(game: game);
          },
        ),
      ],
    );
  }
}

class _GameCircle extends StatelessWidget {
  final MiniGameModel game;

  const _GameCircle({required this.game});

  /// Navega para a tela do jogo correspondente.
  /// Por enquanto, apenas o Wordle tem tela implementada.
  void _navigateToGame(BuildContext context) {
    if (game.id == 'wordle') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WordlePage()),
      );
    }
    // Os outros jogos serão implementados futuramente
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = !game.isAvailable;
    final borderColor = game.isCompleted
        ? AppColors.success
        : isLocked
        ? AppColors.grey
        : AppColors.dark;

    return Opacity(
      opacity: isLocked ? 0.45 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2.5),
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: isLocked ? null : () => _navigateToGame(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  game.icon,
                  size: 32,
                  color: isLocked ? AppColors.grey : game.color,
                ),
                const SizedBox(height: 6),
                Text(
                  game.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isLocked ? AppColors.grey : AppColors.dark,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (game.isCompleted)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
