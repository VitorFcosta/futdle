import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../exceptions/app_exceptions.dart';
import '../logger/app_logger.dart';

/// Serviço responsável por toda a autenticação do app.
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? db})
    : _auth = auth ?? FirebaseAuth.instance,
      _db = db ?? FirebaseFirestore.instance;

  /// Retorna o usuário logado atualmente, ou `null` se não estiver logado.
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Cria uma nova conta com email e senha.
  /// Lança [AuthException] se algo der errado (email já existe, senha fraca, etc.)
  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      //  Cria a conta no Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        //  Atualiza o displayName no perfil do Auth
        await user.updateDisplayName(name);

        //  Salva os dados extras no Firestore (coleção users)
        await _db.collection('users').doc(user.uid).set({
          'displayName': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        AppLogger.info('Usuário criado: $email (uid: ${user.uid})');
      }

      return user;
    } on FirebaseAuthException catch (e) {
      // Converte os códigos de erro do Firebase em mensagens amigáveis
      throw AuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw AuthException('Erro ao criar conta: $e');
    }
  }

  /// Faz login com email e senha.
  /// Lança [AuthException] se email/senha estiverem incorretos.
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      AppLogger.info('Login realizado: $email');
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e.code));
    } catch (e) {
      throw AuthException('Erro ao fazer login: $e');
    }
  }

  /// Faz logout do usuário atual.
  Future<void> signOut() async {
    await _auth.signOut();
    AppLogger.info('Logout realizado');
  }

  /// Converte os códigos de erro do Firebase Auth em mensagens
  String _mapFirebaseAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este email já está cadastrado.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'weak-password':
        return 'A senha deve ter pelo menos 6 caracteres.';
      case 'user-not-found':
        return 'Nenhuma conta encontrada com este email.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-credential':
        return 'Email ou senha incorretos.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro de autenticação ($code).';
    }
  }
}
