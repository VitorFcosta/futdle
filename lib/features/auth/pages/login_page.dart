import 'package:flutter/material.dart';
import 'package:futdle/core/firebase/auth_service.dart';
import 'package:futdle/core/theme/app_colors.dart';
import 'package:futdle/features/auth/pages/register_page.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tela de login do FutDLE.
///
/// Contém:
/// - Logo e título do app no topo
/// - Campo de email com validação
/// - Campo de senha (obscurecido)
/// - Botão "Entrar" que chama [AuthService.signIn]
/// - Link "Criar conta" que navega para [RegisterPage]
/// - Tratamento de erros com SnackBar
///
/// O design segue o design system do app (cores de [AppColors],
/// fontes Outfit para títulos e JetBrains Mono para corpo).
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controllers para capturar o texto digitado nos campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Key do formulário para validação
  final _formKey = GlobalKey<FormState>();

  // Serviço de autenticação
  final _authService = AuthService();

  // Flag para mostrar loading no botão enquanto processa
  bool _isLoading = false;

  @override
  void dispose() {
    // Libera os controllers quando o widget é destruído
    // para evitar vazamento de memória
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Executa o login quando o botão "Entrar" é pressionado.
  ///
  /// 1. Valida os campos do formulário
  /// 2. Mostra loading
  /// 3. Chama [AuthService.signIn]
  /// 4. Se der erro, mostra SnackBar com a mensagem
  /// 5. O [AuthGate] detecta automaticamente o login e troca pra Home
  Future<void> _handleLogin() async {
    // Verifica se os campos são válidos (email preenchido, senha preenchida)
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Não precisa navegar manualmente!
      // O AuthGate detecta o login via authStateChanges e mostra a Home
    } catch (e) {
      if (mounted) {
        // Mostra mensagem de erro amigável na barra inferior
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('AuthException: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ===== LOGO / TÍTULO =====
                  // Ícone de futebol grande como "logo" do app
                  Icon(Icons.sports_soccer, size: 64, color: AppColors.primary),
                  const SizedBox(height: 16),
                  // Título "FutDLE" com a fonte Outfit (mesma do header da Home)
                  Text(
                    'FutDLE',
                    style: GoogleFonts.outfit(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'O Wordle do Futebol',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ===== CAMPO DE EMAIL =====
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Email', Icons.email_outlined),
                    style: GoogleFonts.jetBrainsMono(color: AppColors.dark),
                    // Validação: campo obrigatório
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Digite seu email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ===== CAMPO DE SENHA =====
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true, // esconde o texto da senha
                    decoration: _inputDecoration('Senha', Icons.lock_outlined),
                    style: GoogleFonts.jetBrainsMono(color: AppColors.dark),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Digite sua senha';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // ===== BOTÃO ENTRAR =====
                  // Botão largo que ocupa toda a largura disponível
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              'Entrar',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== LINK PARA REGISTRO =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Não tem conta? ',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 13,
                          color: AppColors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navega para a tela de registro
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Criar conta',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Helper que cria a decoração padronizada dos campos de input.
  ///
  /// Todos os campos seguem o mesmo estilo visual:
  /// - Borda arredondada com cor escura
  /// - Ícone à esquerda (prefixIcon)
  /// - Texto placeholder (label)
  /// - Borda azul quando focado
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.jetBrainsMono(color: AppColors.grey),
      prefixIcon: Icon(icon, color: AppColors.grey),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.dark, width: 2),
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}
