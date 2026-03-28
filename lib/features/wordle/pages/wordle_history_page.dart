import 'package:flutter/material.dart';
import 'package:futdle/core/models/player_model.dart';
import 'package:futdle/core/firebase/firestore_service.dart';
import 'package:futdle/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:futdle/features/wordle/pages/wordle_page.dart';

class WordleHistoryPage extends StatefulWidget {
  const WordleHistoryPage({super.key});

  @override
  State<WordleHistoryPage> createState() => _WordleHistoryPageState();
}

class _WordleHistoryPageState extends State<WordleHistoryPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final data = await _firestoreService.getDailyHistory();
      setState(() {
        _history = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar histórico: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Histórico Wordle',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.dark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : _history.isEmpty
          ? const Center(child: Text('Nenhum jogo no histórico ainda.'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _history.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _history[index];
                final dateStr =
                    item['dateId'] as String? ?? 'Data Desconhecida';

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.dark.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  elevation: 0,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      'Desafio de $dateStr',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.dark,
                      ),
                    ),
                    subtitle: Text(
                      'Jogue puramente por diversão!',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.play_circle_fill,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WordlePage(
                            targetPlayerToPlay: PlayerModel.fromFlatMap(item),
                            isDailyStreak: false,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
