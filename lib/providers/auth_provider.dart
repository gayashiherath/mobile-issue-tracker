import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService authService;

  AuthProvider(this.authService);

  bool isLoggedIn = false;
  bool isLoading = false;
  String? errorMessage;

  Future<void> checkLogin() async {
    isLoggedIn = await authService.isLoggedIn();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    errorMessage = null;

    if (!email.contains('@')) {
      errorMessage = 'Please enter a valid email';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      errorMessage = 'Password must be at least 6 characters';
      notifyListeners();
      return false;
    }

    isLoading = true;
    notifyListeners();

    try {
      await authService.login(email, password);
      isLoggedIn = true;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      errorMessage = 'Login failed. Please try again.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await authService.logout();
    isLoggedIn = false;
    notifyListeners();
  }
}
