import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
            guess.name,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.dark,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Linha com as 5 caixas de comparação suportando mesma altura
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CountryBox(
                  nationality: guess.nationality ?? '?',
                  result: comparison.nationalityResult,
                ),
                const SizedBox(width: 4),
                _CrestBox(
                  imageUrl: guess.statistics?.leagueEmblem,
                  label: guess.statistics?.leagueName ?? '?',
                  result: comparison.leagueResult,
                  fallbackIcon: Icons.emoji_events,
                ),
                const SizedBox(width: 4),
                _CrestBox(
                  imageUrl: guess.statistics?.teamCrest,
                  label: guess.statistics?.teamName ?? '?',
                  result: comparison.teamResult,
                  fallbackIcon: Icons.shield,
                ),
                const SizedBox(width: 4),
                _AttributeBox(
                  icon: Icons.directions_run,
                  value: _abbreviatePosition(guess.statistics?.position ?? '?'),
                  result: comparison.positionResult,
                ),
                const SizedBox(width: 4),
                _AgeBox(
                  age: guess.age?.toString() ?? '?',
                  result: comparison.ageResult,
                  direction: comparison.ageDirection,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Retorna abreviações das posições em PT-BR.
  String _abbreviatePosition(String position) {
    switch (position.toLowerCase()) {
      case 'attacker':
        return 'ATA';
      case 'midfielder':
        return 'MEI';
      case 'defender':
        return 'ZAG';
      case 'goalkeeper':
        return 'GOL';
      default:
        return position;
    }
  }
}

/// Caixa com escudo/emblema carregado da rede + label de texto.
/// Usa [CachedNetworkImage] para cache local das imagens.
/// Se a URL for nula ou falhar, mostra um ícone fallback.
class _CrestBox extends StatelessWidget {
  final String? imageUrl;
  final String label;
  final GuessResult result;
  final IconData fallbackIcon;

  const _CrestBox({
    required this.imageUrl,
    required this.label,
    required this.result,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
          color: _colorForResult(result),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Escudo / Emblema
            SizedBox(
              width: 26,
              height: 26,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl!,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => Icon(
                        fallbackIcon,
                        size: 20,
                        color: AppColors.white.withValues(alpha: 0.7),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        fallbackIcon,
                        size: 20,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                    )
                  : Icon(
                      fallbackIcon,
                      size: 20,
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
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

/// Caixa individual de um atributo com cor de feedback.
class _AttributeBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final GuessResult result;

  const _AttributeBox({
    required this.icon,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: AppColors.white.withValues(alpha: 0.9)),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
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

  const _CountryBox({required this.nationality, required this.result});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
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
            const SizedBox(height: 4),
            Text(
              nationality,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: _colorForResult(result),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  age,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
                if (direction == AgeDirection.higher)
                  const Icon(
                    Icons.arrow_upward,
                    size: 14,
                    color: AppColors.white,
                  ),
                if (direction == AgeDirection.lower)
                  const Icon(
                    Icons.arrow_downward,
                    size: 14,
                    color: AppColors.white,
                  ),
              ],
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
