import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:futdle/core/firebase/auth_service.dart';
import 'package:futdle/features/auth/pages/login_page.dart';
import 'package:futdle/features/home/pages/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      // Escuta a stream de mudanças do estado de autenticação
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Enquanto carrega, mostra um loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se tem um User na stream → está logado → vai pra Home
        if (snapshot.hasData) {
          final user = snapshot.data!;
          // Pega o displayName do perfil do Auth (definido no signUp)
          // Se não tiver nome, usa "Jogador" como fallback
          final username = user.displayName ?? 'Jogador';
          return HomePage(username: username);
        }

        // Se não tem User → não está logado → mostra Login
        return const LoginPage();
      },
    );
  }
}
