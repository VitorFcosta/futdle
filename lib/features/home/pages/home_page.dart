import 'package:flutter/material.dart';
import 'package:futdle/core/firebase/auth_service.dart';
import 'package:futdle/core/firebase/firestore_service.dart';
import 'package:futdle/features/home/components/home_header.dart';
import 'package:futdle/features/home/components/daily_games_grid.dart';
import 'package:futdle/features/home/components/streak_card.dart';
import 'package:futdle/models/mini_game_model.dart';
import 'package:futdle/models/user_stats.dart';
import 'package:futdle/core/theme/app_colors.dart';

/// Página inicial do Futdle.
/// Exibe o header (com nome real do usuário), grade de mini jogos diários e card de streaks.
///
/// Recebe o [username] do [AuthGate], que pega do Firebase Auth.
/// Também possui um botão de logout acessível pelo header.
class HomePage extends StatelessWidget {
  final String username;

  const HomePage({super.key, required this.username});

  Future<UserStats> _fetchStats() async {
    final user = AuthService().currentUser;
    if (user != null) {
      return await FirestoreService().getUserStats(user.uid);
    }
    return UserStats();
  }

  @override
  Widget build(BuildContext context) {
    final games = MiniGameModel.defaultGames();
    final authService = AuthService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeHeader(
                username: username,
                onLogout: () => authService.signOut(),
              ),
              const SizedBox(height: 30),
              DailyGamesGrid(games: games),
              const SizedBox(height: 40),
              FutureBuilder<UserStats>(
                future: _fetchStats(),
                builder: (context, snapshot) {
                  final stats = snapshot.data;
                  if (stats == null) {
                    return const StreakCard(); // Status vazio/default
                  }
                  
                  return StreakCard(
                    bestStreak: stats.maxStreak, 
                    bestStreakGame: stats.maxStreak > 0 ? 'Wordle' : '--',
                    topWinsCount: stats.gamesWon,
                    topWinsGame: stats.gamesWon > 0 ? 'Wordle' : '--',
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
