import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';

class CreateStudentScreen extends StatefulWidget {
  const CreateStudentScreen({super.key});

  @override
  State<CreateStudentScreen> createState() => _CreateStudentScreenState();
}

class _CreateStudentScreenState extends State<CreateStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentFirstNameController = TextEditingController();
  final _studentLastNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  final SessionService _sessionService = SessionService();
  String? email;
  int? id_user;

  bool _isLoading = false;

  Future<void> _submitStudent() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // สร้างข้อมูลที่จะส่งไปในรูปแบบ JSON
    final studentData = {
      'id_prefix': 1, // ใช้ค่าเหมาะสมจากฟอร์มหรือค่าคงที่
      'first_name': _studentFirstNameController.text,
      'last_name': _studentLastNameController.text,
      'code_student': _studentIdController.text,
      'id_user': id_user,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/student/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(studentData),
      );

      if (response.statusCode == 200) {
        // ถ้าสำเร็จ
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สร้างข้อมูลนักศึกษาเรียบร้อย')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // ถ้ามีข้อผิดพลาดจาก API
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${response.body}')),
        );
      }
    } catch (e) {
      // จับข้อผิดพลาดที่เกิดขึ้น
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ API')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onCheckUser() async {
    String? token = await _sessionService.getAuthToken();
    String? email = await _sessionService.getUserSession();
    print("Token : $token");
    if (token != null) {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/user'),
        headers: {"Authorization": "$token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String fetchedEmail = data["email"];
        if (fetchedEmail == email) {
          print("!!##  Email is $fetchedEmail");
          print("!!## id_user : ${data['id_user']}");
          setState(() {
            email = fetchedEmail;
            id_user = data['id_user'];
          });
          print("!!## From Create Student : $email !!##");
          print("!!## id_user : $id_user ");
          await _sessionService.setIdStudent(data['id_user']);
        } else {
          print("Email is not in use.");
        }
      } else {
        print("❌ Failed to fetch user data: ${response.body}");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _onCheckUser();
  }

  @override
  void dispose() {
    _studentFirstNameController.dispose();
    _studentLastNameController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('สร้างข้อมูลนักศึกษา')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _studentFirstNameController,
                        decoration: const InputDecoration(
                          labelText: 'ชื่อจริง',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกชื่อ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _studentLastNameController,
                        decoration: const InputDecoration(
                          labelText: 'นามสกุล',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกนามสกุล';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _studentIdController,
                        decoration: const InputDecoration(
                          labelText: 'รหัสนักศึกษา',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'กรุณากรอกรหัสนักศึกษา';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _submitStudent,
                        child: const Text('สร้างข้อมูลนักศึกษา'),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
