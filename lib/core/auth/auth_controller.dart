import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void signIn(String email, String password) {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const FormatException('Email and password are required.');
    }
    _isAuthenticated = true;
    notifyListeners();
  }

  void signOut() {
    _isAuthenticated = false;
    notifyListeners();
  }
}

final authController = AuthController();
