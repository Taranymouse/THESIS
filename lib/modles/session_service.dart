import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 👉 บันทึก Email ลงใน Storage
  Future<void> saveUserSession(String email) async {
    await _storage.write(key: 'userEmail', value: email);
  }

  // 👉 อ่าน Email จาก Storage
  Future<String?> getUserSession() async {
    return await _storage.read(key: 'userEmail');
  }

  // 👉 ลบ Session (เมื่อ Logout)
  Future<void> clearUserSession() async {
    await _storage.delete(key: 'userEmail');
  }

  // 👉 ตรวจสอบว่า Logged In หรือไม่
  Future<bool> isLoggedIn() async {
    String? email = await getUserSession();
    return email != null;
  }
}
