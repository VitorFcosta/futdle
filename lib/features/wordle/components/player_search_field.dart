import 'package:flutter/material.dart';
import 'package:futdle/core/firebase/firestore_service.dart';
import 'package:futdle/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Campo de busca com autocomplete para selecionar jogadores.
///
/// Funciona assim:
/// 1. O usuário digita no campo de texto
/// 2. A cada mudança (com debounce de 300ms), busca jogadores no cache local
/// 3. Mostra uma lista de sugestões abaixo do campo
/// 4. Ao tocar numa sugestão, chama [onPlayerSelected] com os dados do jogador
///
/// A busca é case-insensitive e filtra por substring (não apenas prefixo).
/// Os dados vêm do cache em memória do [FirestoreService], então é instantâneo.
class PlayerSearchField extends StatefulWidget {
  /// Callback chamado quando o usuário seleciona um jogador da lista.
  final Function(Map<String, dynamic>) onPlayerSelected;

  /// Se true, desabilita o campo (quando o jogo já acabou).
  final bool enabled;

  /// Lista de nomes já palpitados (para não repetir).
  final List<String> guessedNames;

  const PlayerSearchField({
    super.key,
    required this.onPlayerSelected,
    this.enabled = true,
    this.guessedNames = const [],
  });

  @override
  State<PlayerSearchField> createState() => _PlayerSearchFieldState();
}

class _PlayerSearchFieldState extends State<PlayerSearchField> {
  final _controller = TextEditingController();
  final _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Busca jogadores que contêm o texto digitado.
  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await _firestoreService.searchPlayers(query.trim());

      // Filtra jogadores já palpitados
      final filtered = results
          .where(
            (p) => !widget.guessedNames
                .map((n) => n.toLowerCase())
                .contains((p['name'] as String).toLowerCase()),
          )
          .toList();

      setState(() {
        _suggestions = filtered.take(8).toList(); // máximo 8 sugestões
        _showSuggestions = _suggestions.isNotEmpty;
      });
    } catch (e) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Quando o usuário seleciona um jogador.
  void _selectPlayer(Map<String, dynamic> player) {
    _controller.clear();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
    widget.onPlayerSelected(player);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de texto para digitar o nome
        TextField(
          controller: _controller,
          enabled: widget.enabled,
          onChanged: _search,
          style: GoogleFonts.jetBrainsMono(fontSize: 14, color: AppColors.dark),
          decoration: InputDecoration(
            hintText: 'Digite o nome do jogador...',
            hintStyle: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              color: AppColors.grey,
            ),
            prefixIcon: const Icon(Icons.search, color: AppColors.grey),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.dark, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.dark.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),

        // Lista de sugestões
        if (_showSuggestions)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.dark.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.dark.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _suggestions.length,
              separatorBuilder: (_, a) => Divider(
                height: 1,
                color: AppColors.grey.withValues(alpha: 0.2),
              ),
              itemBuilder: (context, index) {
                final player = _suggestions[index];
                return ListTile(
                  dense: true,
                  onTap: () => _selectPlayer(player),
                  title: Text(
                    player['name'] ?? '',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.dark,
                    ),
                  ),
                  subtitle: Text(
                    '${player['team']} • ${player['league']}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                  ),
                  trailing: Text(
                    player['nationality'] ?? '',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
