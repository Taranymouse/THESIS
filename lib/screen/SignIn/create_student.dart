import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectPrefix.dart';

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
  int? selectedPrefix;

  void onPrefixChanged(String? value) {
    setState(() {
      selectedPrefix = value != null ? int.tryParse(value) : null;
    });
  }

  Future<void> _submitStudent() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedPrefix == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกคำนำหน้าชื่อ')));
      return;
    }

    setState(() => _isLoading = true);

    final studentData = {
      'id_prefix': selectedPrefix,
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สร้างข้อมูลนักศึกษาเรียบร้อย')),
        );
        await Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ API')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onCheckUser() async {
    String? token = await _sessionService.getAuthToken();
    String? sessionEmail = await _sessionService.getUserSession();

    if (token != null) {
      final response = await http.get(
        Uri.parse('$baseUrl/api/auth/user'),
        headers: {"Authorization": "$token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String fetchedEmail = data["email"];
        if (fetchedEmail == sessionEmail) {
          setState(() {
            email = fetchedEmail;
            id_user = data['id_user'];
          });
          await _sessionService.setIdUser(data['id_user']);
        } else {
          print("อีเมลไม่ตรงกับ session");
        }
      } else {
        print("❌ ไม่สามารถดึงข้อมูลผู้ใช้: ${response.body}");
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
      appBar: AppBar(title: const Text('สร้างบัญชี')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'คำนำหน้าชื่อ :',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 200,
                            height: 60,
                            child: PrefixDropdown(
                              onPrefixChanged: onPrefixChanged,
                              value: selectedPrefix?.toString(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
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
                        child: Text('สร้างบัญชี', style: GoogleFonts.prompt()),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
