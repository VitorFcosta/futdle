import 'package:flutter/material.dart';

/// Representa um mini jogo diário exibido na grade da Home.
class MiniGameModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isAvailable;
  final bool isCompleted;

  const MiniGameModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isAvailable = true,
    this.isCompleted = false,
  });

  /// Lista padrão dos mini jogos disponíveis.
  static List<MiniGameModel> defaultGames() {
    return const [
      MiniGameModel(
        id: 'wordle',
        name: 'Wordle',
        icon: Icons.person_search,
        color: Color(0xFF2980B9),
      ),
    ];
  }
}
