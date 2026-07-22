import 'package:flutter/foundation.dart';
import '../validation/input_validators.dart';

class AuthController extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  void signIn(String email, String password) {
    if (!isValidEmail(email) || password.length < 6) {
      throw const FormatException('Enter a valid email and a password of at least 6 characters.');
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
