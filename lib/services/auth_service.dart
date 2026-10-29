import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  // Sign up with Supabase Auth
  Future<String?> signup(String email, String password, String name) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      if (response.user != null) {
        return null; // Success
      }
      return 'Signup failed';
    } catch (e) {
      return e.toString();
    }
  }

  // Login with Supabase Auth
  Future<String?> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        return null; // Success
      }
      return 'Login failed';
    } catch (e) {
      return e.toString();
    }
  }

  // Logout
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  // Get current user email
  String get currentUserEmail => _client.auth.currentUser?.email ?? 'talib@khoaaoojiii.pk';

  // Get current user name
  String get currentUserName {
    final user = _client.auth.currentUser;
    if (user?.userMetadata != null && user!.userMetadata!['full_name'] != null) {
      return user.userMetadata!['full_name'];
    }
    return 'talibjan';
  }
}
