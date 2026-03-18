// Lógica central do jogo Wordle do FutDLE.
//
// Esta classe contém toda a lógica de comparação entre o palpite
// do jogador e o jogador misterioso do dia.
//
// Resultado da comparação:
// Cada atributo (nacionalidade, liga, time, posição, idade) recebe um
// GuessResult:
// - correct (🟩 verde) → atributo idêntico
// - partial (🟨 amarelo) → relacionado (ex: mesma liga, time diferente)
// - wrong (🟥 vermelho) → completamente diferente
//
// Para a idade, além do resultado, retorna uma seta indicando
// se o jogador misterioso é mais velho (⬆️) ou mais novo (⬇️).

/// Resultado da comparação de um atributo.
enum GuessResult {
  /// 🟩 Atributo idêntico ao jogador misterioso.
  correct,

  /// 🟨 Atributo parcialmente correto
  partial,

  /// 🟥 Atributo completamente diferente.
  wrong,
}

/// Direção da seta para a comparação de idade.
enum AgeDirection {
  /// O jogador misterioso é mais velho
  higher,

  /// O jogador misterioso é mais novo
  lower,

  /// Idade igual
  equal,
}

/// Resultado completo de um palpite, com o resultado de cada atributo.
class GuessComparison {
  final Map<String, dynamic> guessPlayer;
  final GuessResult nationalityResult;
  final GuessResult leagueResult;
  final GuessResult teamResult;
  final GuessResult positionResult;
  final GuessResult ageResult;
  final AgeDirection ageDirection;
  final bool isCorrect;

  const GuessComparison({
    required this.guessPlayer,
    required this.nationalityResult,
    required this.leagueResult,
    required this.teamResult,
    required this.positionResult,
    required this.ageResult,
    required this.ageDirection,
    required this.isCorrect,
  });
}

/// Classe com métodos estáticos para a lógica do Wordle.
class WordleGameLogic {
  /// Número máximo de tentativas permitidas.
  static const int maxAttempts = 6;

  /// Compara um palpite com o jogador misterioso.
  ///
  /// Ambos os parâmetros são Maps com as keys:
  /// `name`, `age`, `nationality`, `team`, `league`, `position`
  ///
  /// Retorna um [GuessComparison] com o resultado de cada atributo.
  static GuessComparison compare(
    Map<String, dynamic> guess,
    Map<String, dynamic> target,
  ) {
    // Verifica se é o jogador correto (acertou!)
    final isCorrect =
        (guess['name'] as String).toLowerCase() ==
        (target['name'] as String).toLowerCase();

    // Compara nacionalidade: igual → correct, senão → wrong
    final nationalityResult = _compareString(
      guess['nationality'],
      target['nationality'],
    );

    // Compara liga: igual → correct, senão → wrong
    final leagueResult = _compareString(guess['league'], target['league']);

    // Compara time: igual → correct, mesma liga → partial, senão → wrong
    GuessResult teamResult;
    if (_strEquals(guess['team'], target['team'])) {
      teamResult = GuessResult.correct;
    } else if (_strEquals(guess['league'], target['league'])) {
      // Mesmo campeonato mas time diferente = parcial
      teamResult = GuessResult.partial;
    } else {
      teamResult = GuessResult.wrong;
    }

    // Compara posição: igual → correct, senão → wrong
    final positionResult = _compareString(
      guess['position'],
      target['position'],
    );

    // Compara idade: igual → correct, diferença ≤ 2 → partial, senão → wrong
    final guessAge = guess['age'] as int? ?? 0;
    final targetAge = target['age'] as int? ?? 0;
    final ageDiff = (guessAge - targetAge).abs();

    GuessResult ageResult;
    if (ageDiff == 0) {
      ageResult = GuessResult.correct;
    } else if (ageDiff <= 2) {
      ageResult = GuessResult.partial;
    } else {
      ageResult = GuessResult.wrong;
    }

    // Direção da seta de idade
    AgeDirection ageDirection;
    if (guessAge == targetAge) {
      ageDirection = AgeDirection.equal;
    } else if (targetAge > guessAge) {
      ageDirection = AgeDirection.higher;
    } else {
      ageDirection = AgeDirection.lower;
    }

    return GuessComparison(
      guessPlayer: guess,
      nationalityResult: nationalityResult,
      leagueResult: leagueResult,
      teamResult: teamResult,
      positionResult: positionResult,
      ageResult: ageResult,
      ageDirection: ageDirection,
      isCorrect: isCorrect,
    );
  }

  /// Compara duas strings case-insensitive.
  static GuessResult _compareString(dynamic a, dynamic b) {
    if (_strEquals(a, b)) return GuessResult.correct;
    return GuessResult.wrong;
  }

  /// Helper para comparação case-insensitive de strings nullable.
  static bool _strEquals(dynamic a, dynamic b) {
    if (a == null || b == null) return false;
    return a.toString().toLowerCase() == b.toString().toLowerCase();
  }
}
