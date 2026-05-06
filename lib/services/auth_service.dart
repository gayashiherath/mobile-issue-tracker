import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String loginKey = 'is_logged_in';

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginKey, true);

    return true;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey) ?? false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginKey, false);
  }
}
