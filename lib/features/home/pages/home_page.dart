import 'package:flutter/material.dart';
import 'package:futdle/core/firebase/auth_service.dart';
import 'package:futdle/core/firebase/firestore_service.dart';
import 'package:futdle/features/home/components/home_header.dart';
import 'package:futdle/features/home/components/streak_card.dart';
import 'package:futdle/core/models/user_stats.dart';
import 'package:futdle/core/theme/app_colors.dart';
import 'package:futdle/features/wordle/pages/wordle_page.dart';

/// Página inicial do Futdle.
/// Exibe o header com o nome do usuário, o card do Wordle e o card de streaks.
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
              _WordleCard(),
              const SizedBox(height: 40),
              FutureBuilder<UserStats>(
                future: _fetchStats(),
                builder: (context, snapshot) {
                  final stats = snapshot.data;
                  if (stats == null) {
                    return const StreakCard();
                  }
                  return StreakCard(
                    bestStreak: stats.maxStreak,
                    bestStreakGame: stats.maxStreak > 0 ? 'Wordle' : '--',
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

/// Card de destaque do Wordle na landing page.
class _WordleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'jogo do dia',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WordlePage()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2980B9), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2980B9).withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2980B9).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_search,
                      size: 36,
                      color: Color(0xFF2980B9),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wordle',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.dark,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Adivinhe o jogador misterioso do dia',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Color(0xFF2980B9),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

