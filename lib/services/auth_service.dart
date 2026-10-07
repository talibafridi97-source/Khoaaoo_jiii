import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _supabase = Supabase.instance.client;

  bool get isLoggedIn => _supabase.auth.currentSession != null;

  String get currentUserName {
    final user = _supabase.auth.currentUser;
    if (user != null && user.userMetadata != null) {
      return user.userMetadata?['full_name'] ?? 'User';
    }
    return 'Talib Nawaz';
  }

  String get currentUserEmail {
    final user = _supabase.auth.currentUser;
    return user?.email ?? 'talib@quickbite.pk';
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      notifyListeners();
      return response.session != null;
    } catch (e) {
      print('Supabase Login Error: $e');
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      notifyListeners();
      return response.user != null;
    } catch (e) {
      print('Supabase Signup Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      notifyListeners();
    } catch (e) {
      print('Supabase Logout Error: $e');
    }
  }
}
