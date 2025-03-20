import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _isLoggedInKey = 'isLoggedIn';

  Future<void> saveEmailSession(String email) async {
    await _storage.write(key: 'userEmail', value: email);
  }

  Future<void> saveDisplayName(String displayName) async {
  await _storage.write(key: 'displayName', value: displayName);
}

Future<String?> getDisplayName() async {
  return await _storage.read(key: 'displayName');
}

  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'authToken', value: token);
  }

  Future<void> saveUserRole(String role) async {
    await _storage.write(key: 'role', value: role);
  }

  Future<String?> getUserSession() async {
    return await _storage.read(key: 'userEmail');
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'authToken');
  }

  Future<String?> getUserRoleSession() async {
    return await _storage.read(key: 'role');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  Future<void> clearSession() async {
    // ลบใน Secure Storage
    await _storage.deleteAll();

    // ลบใน SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isLoggedInKey);
  }
}
