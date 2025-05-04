import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _isLoggedInKey = 'isLoggedIn';

  Future<void> saveUpdatedStudentIds(List<int> ids) async {
    final jsonString = jsonEncode(ids);
    await _storage.write(key: 'updated_student_ids', value: jsonString);
  }

  Future<List<int>> getUpdatedStudentIds() async {
    final jsonString = await _storage.read(key: 'updated_student_ids');
    if (jsonString == null) return [];
    final List<dynamic> parsed = jsonDecode(jsonString);
    return parsed.cast<int>();
  }

  // ฟังก์ชันเก็บข้อมูลid_student
  Future<void> setIdStudent(int id_student) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id_student', id_student);
  }

  // ฟังก์ชันดึงข้อมูลid_student
  Future<int?> getIdStudent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_student');
  }

  // ฟังก์ชันเก็บข้อมูลid_user
  Future<void> setIdUser(int id_user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id_user', id_user);
  }

  // ฟังก์ชันดึงข้อมูลid_user
  Future<int?> getIdUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_user');
  }

  // ฟังก์ชันเก็บข้อมูลid_group_project
  Future<void> setProjectGroupId(int id_user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id_group_project', id_user);
  }

  // ฟังก์ชันดึงข้อมูลid_group_project
  Future<int?> getProjectGroupId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_group_project');
  }

  // ฟังก์ชันเก็บข้อมูลid_member
  Future<void> setIdmember(int id_member) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id_member', id_member);
  }

  // ฟังก์ชันดึงข้อมูลid_member
  Future<int?> getIdmember() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_member');
  }

  // ฟังก์ชันเก็บข้อมูลชื่ออาจารย์ที่ปรึกษาที่นศ เลือก
  Future<void> setNameProfessor(String name) async {
    await _storage.write(key: 'professor_name', value: name);
  }

  // ฟังก์ชันดึงข้อมูลชื่ออาจารย์ที่ปรึกษาที่นศ เลือก
  Future<String?> getNameProfessor() async {
    return await _storage.read(key: 'professor_name');
  }

  // ฟังก์ชันเก็บอาจารย์ที่นักศึกษาเลือกมา (id_member) จากกลุ่มโปรเจค
  Future<void> setIdmemberInGroupProject(int id_member) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id_member', id_member);
  }

  // ฟังก์ชันดึงข้อมูลอาจารย์ที่นักศึกษาเลือกมา (id_member) จากกลุ่มโปรเจค
  Future<int?> getIdmemberInGroupProject() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id_member');
  }

  // ฟังก์ชันเก็บข้อมูลอีเมล
  Future<void> saveEmailSession(String email) async {
    await _storage.write(key: 'userEmail', value: email);
  }

  // ฟังก์ชันเก็บชื่อผู้ใช้
  Future<void> saveDisplayName(String displayName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('display_name', displayName);
  }

  // ฟังก์ชันดึงชื่อผู้ใช้
  Future<String?> getDisplayName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('display_name');
  }

  // ฟังก์ชันเก็บ token
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'authToken', value: token);
  }

  // ฟังก์ชันดึง token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'authToken');
  }

  // ฟังก์ชันเก็บ role
  Future<void> saveUserRole(String role) async {
    await _storage.write(key: 'role', value: role);
  }

  // ฟังก์ชันดึง token
  Future<String?> getUserRole() async {
    return await _storage.read(key: 'role');
  }

  // ฟังก์ชันดึงอีเมลของผู้ใช้
  Future<String?> getUserSession() async {
    return await _storage.read(key: 'userEmail');
  }

  // ฟังก์ชันดึง role
  Future<String?> getUserRoleSession() async {
    return await _storage.read(key: 'role');
  }

  // ฟังก์ชันบันทึก uid
  Future<void> saveUserUid(String uid) async {
    await _storage.write(key: 'uid', value: uid);
  }

  // ฟังก์ชันดึง uid
  Future<String?> getUserUid() async {
    return await _storage.read(key: 'uid');
  }

  // ฟังก์ชันบันทึก ชื่อผู้ใช้
  Future<void> saveUserName(String firstname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstname', firstname);
  }

  // ฟังก์ชันดึง ชื่อผู้ใช้
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('firstname');
  }

  // ฟังก์ชันบันทึกนามสกุล
  Future<void> saveUserLastName(String lastname) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastname', lastname);
  }

  // ฟังก์ชันดึงนามสกุล
  Future<String?> getUserLastName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lastname');
  }

  // ฟังก์ชันบันทึกรหัสนักศึกษา
  Future<void> saveStudentId(String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('studentId', studentId);
  }

  // ฟังก์ชันดึงรหัสนักศึกษา
  Future<String?> getStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('studentId');
  }

  // ฟังก์ชันบันทึกชื่อเลือกคำนำหน้า
  /// บันทึกคำนำหน้า (prefix) เป็น String
  Future<void> savePrefix(int prefix) async {
    await _storage.write(
      key: 'prefix',
      value: prefix.toString(), // แปลง int -> String
    );
  }

  /// อ่านคำนำหน้า กลับมาเป็น int?
  Future<int?> getPrefix() async {
    final str = await _storage.read(key: 'prefix');
    if (str == null) return null;
    // แปลง String -> int ถ้าแปลงไม่ได้คืน null
    return int.tryParse(str);
  }

  // ฟังก์ชันตรวจสอบว่า login แล้วหรือไม่
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // ฟังก์ชันตั้งค่า login status
  Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  // ฟังก์ชันตรวจสอบว่าทำแบบฟอร์ม IT00G / CS00G แล้วหรือไม่
  Future<bool> isDoneFromG() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // ฟังก์ชันตั้งค่า แบบฟอร์ม IT00G / CS00G status
  Future<void> setDoneFromG(bool isDoneFromG) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isDoneFromG);
  }

  // ฟังก์ชันลบข้อมูล session
  Future<void> clearSession() async {
    // ลบใน Secure Storage
    await _storage.deleteAll();

    // ลบใน SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ลบข้อมูลทั้งหมดเมื่อ Logout
  }
}
