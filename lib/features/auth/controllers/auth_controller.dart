import 'package:flutter/material.dart';
import 'package:futdle/core/di/injection.dart';
import 'package:futdle/core/firebase/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = getIt<AuthService>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signIn(email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String name, String email, String password) async {
    _setLoading(true);
    try {
      await _authService.signUp(name: name, email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }
}
