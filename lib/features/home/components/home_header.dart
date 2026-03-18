import 'package:flutter/material.dart';
import 'package:futdle/core/theme/app_colors.dart';
import 'package:futdle/features/admin/pages/admin_page.dart';

/// Cabeçalho da Home com logo do app, avatar do usuário e botão de logout.
///
/// O avatar usa [CircleAvatar] mostrando a primeira letra do nome do usuário
/// dentro de um círculo com a cor primária do app.
///
/// O [onLogout] é um callback opcional chamado quando o usuário
/// toca no ícone de logout. Se for `null`, o ícone não aparece.
class HomeHeader extends StatelessWidget {
  final String username;
  final VoidCallback? onLogout;

  const HomeHeader({super.key, required this.username, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Título do app — usa headlineMedium (Outfit, bold, cor primária)
          Text(
            'FutDLE',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          Row(
            children: [
              // CircleAvatar mostra a primeira letra do username em maiúscula
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : '?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Nome do usuário ao lado do avatar
              Text(
                username,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  color: AppColors.dark,
                ),
              ),
              // Botão do Admin
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminPage()),
                  );
                },
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              // Botão de logout (só aparece se onLogout não for null)
              if (onLogout != null) ...[
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onLogout,
                  child: const Icon(
                    Icons.logout,
                    color: AppColors.grey,
                    size: 22,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
