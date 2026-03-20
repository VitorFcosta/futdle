import 'package:flutter/material.dart';
import 'package:futdle/core/theme/app_colors.dart';
import 'package:futdle/core/utils/country_code_mapper.dart';
import 'package:futdle/features/wordle/wordle_game_logic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_flags/country_flags.dart';

/// Widget que renderiza uma linha de palpite no Wordle.
///
/// Cada linha mostra 5 "caixas" coloridas representando a comparação
/// de cada atributo (País, Liga, Time, Posição, Idade) do jogador
/// palpitado com o jogador misterioso.
///
/// Cores:
/// - 🟩 Verde ([AppColors.success]) → atributo correto
/// - 🟨 Amarelo ([AppColors.warning]) → parcialmente correto
/// - 🟥 Vermelho ([AppColors.error]) → errado
///
/// A caixa de idade mostra uma setinha ⬆️ ou ⬇️ quando a idade
/// não é exata, indicando se o misterioso é mais velho ou mais novo.
class PlayerGuessRow extends StatelessWidget {
  final GuessComparison comparison;

  const PlayerGuessRow({super.key, required this.comparison});

  @override
  Widget build(BuildContext context) {
    final guess = comparison.guessPlayer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          // Nome do jogador palpitado acima das caixas
          Text(
            guess['name'] ?? '',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Linha com as 5 caixas de comparação
          Row(
            children: [
              _CountryBox(
                nationality: guess['nationality'] ?? '?',
                result: comparison.nationalityResult,
              ),
              const SizedBox(width: 4),
              _AttributeBox(
                label: '🏟️',
                value: _shortenText(guess['league'] ?? '?', 6),
                result: comparison.leagueResult,
              ),
              const SizedBox(width: 4),
              _AttributeBox(
                label: '👕',
                value: _shortenText(guess['team'] ?? '?', 6),
                result: comparison.teamResult,
              ),
              const SizedBox(width: 4),
              _AttributeBox(
                label: '📋',
                value: _shortenPosition(guess['position'] ?? '?'),
                result: comparison.positionResult,
              ),
              const SizedBox(width: 4),
              _AgeBox(
                age: guess['age']?.toString() ?? '?',
                result: comparison.ageResult,
                direction: comparison.ageDirection,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Encurta texto longo para caber na caixa.
  String _shortenText(String text, int max) {
    if (text.length <= max) return text;
    return '${text.substring(0, max - 1)}…';
  }

  /// Encurta nomes de posição.
  String _shortenPosition(String position) {
    switch (position.toLowerCase()) {
      case 'attacker':
        return 'ATA';
      case 'midfielder':
        return 'MEI';
      case 'defender':
        return 'DEF';
      case 'goalkeeper':
        return 'GOL';
      default:
        return position.substring(0, 3).toUpperCase();
    }
  }
}

/// Caixa individual de um atributo com cor de feedback.
class _AttributeBox extends StatelessWidget {
  final String label;
  final String value;
  final GuessResult result;

  const _AttributeBox({
    required this.label,
    required this.value,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: _colorForResult(result),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForResult(GuessResult result) {
    switch (result) {
      case GuessResult.correct:
        return AppColors.success;
      case GuessResult.partial:
        return AppColors.warning;
      case GuessResult.wrong:
        return AppColors.error;
    }
  }
}

/// Caixa especial de nacionalidade que mostra a bandeira e o nome em baixo.
class _CountryBox extends StatelessWidget {
  final String nationality;
  final GuessResult result;

  const _CountryBox({
    required this.nationality,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        decoration: BoxDecoration(
          color: _colorForResult(result),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                width: 24,
                height: 18,
                child: CountryFlag.fromCountryCode(
                  CountryCodeMapper.getIsoCode(nationality),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _shortenText(nationality, 5),
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Encurta texto longo para caber na caixa.
  String _shortenText(String text, int max) {
    if (text.length <= max) return text;
    return '${text.substring(0, max - 1)}…';
  }

  Color _colorForResult(GuessResult result) {
    switch (result) {
      case GuessResult.correct:
        return AppColors.success;
      case GuessResult.partial:
        return AppColors.warning;
      case GuessResult.wrong:
        return AppColors.error;
    }
  }
}

/// Caixa especial de idade com seta direcional.
class _AgeBox extends StatelessWidget {
  final String age;
  final GuessResult result;
  final AgeDirection direction;

  const _AgeBox({
    required this.age,
    required this.result,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    // Ícone da seta baseado na direção
    String arrow = '';
    if (direction == AgeDirection.higher) {
      arrow = ' ⬆️';
    } else if (direction == AgeDirection.lower) {
      arrow = ' ⬇️';
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: _colorForResult(result),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            const Text('🎂', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 2),
            Text(
              '$age$arrow',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForResult(GuessResult result) {
    switch (result) {
      case GuessResult.correct:
        return AppColors.success;
      case GuessResult.partial:
        return AppColors.warning;
      case GuessResult.wrong:
        return AppColors.error;
    }
  }
}
