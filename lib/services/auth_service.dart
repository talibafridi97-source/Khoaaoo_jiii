import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final Map<String, String> _registeredUsers = {
    'talib@quickbite.pk': '123456',
    'admin': 'admin123',
  };

  String _currentUserName = 'Talib Nawaz';
  String _currentUserEmail = 'talib@quickbite.pk';
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  String get currentUserName => _currentUserName;
  String get currentUserEmail => _currentUserEmail;

  bool login(String identifier, String password) {
    if (_registeredUsers.containsKey(identifier) && _registeredUsers[identifier] == password) {
      _currentUserEmail = identifier;
      _currentUserName = identifier.contains('@') ? identifier.split('@')[0] : identifier;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    if (identifier.isNotEmpty && password.length >= 6) {
      _currentUserEmail = identifier;
      _currentUserName = identifier.contains('@') ? identifier.split('@')[0] : identifier;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool signup(String name, String email, String password) {
    if (email.isNotEmpty && password.length >= 6) {
      _registeredUsers[email] = password;
      _currentUserName = name;
      _currentUserEmail = email;
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
