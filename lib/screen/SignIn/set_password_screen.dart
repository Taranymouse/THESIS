import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectPrefix.dart';

class SetPasswordScreen extends StatefulWidget {
  const SetPasswordScreen({super.key});

  @override
  State<SetPasswordScreen> createState() => _SetPasswordScreenState();
}

class _SetPasswordScreenState extends State<SetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _studentFirstNameController = TextEditingController();
  final _studentLastNameController = TextEditingController();
  final _studentIdController = TextEditingController();

  final SessionService _sessionService = SessionService();
  bool _isLoading = false;

  String? email;
  int? id_user;
  int? selectedPrefix;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final fetchedEmail = await _sessionService.getUserSession();
    final fetchedId = await _sessionService.getIdUser();
    setState(() {
      email = fetchedEmail;
      id_user = fetchedId;
    });
  }

  void onPrefixChanged(String? value) {
    setState(() {
      selectedPrefix = value != null ? int.tryParse(value) : null;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedPrefix == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกคำนำหน้าชื่อ')));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('รหัสผ่านไม่ตรงกัน')));
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'email': email,
      'new_password': _passwordController.text,
      'prefix_id': selectedPrefix,
      'first_name': _studentFirstNameController.text,
      'last_name': _studentLastNameController.text,
      'student_code': _studentIdController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/set-password-and-info'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (_studentIdController.text == '000000000') {
          await _sessionService.saveUserRole('2' ?? 'No Role');
          print("can Change Role");
        } else {
          print(" ### Can't Change Role");
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('สร้างบัญชีสำเร็จ')));
        String userRole = await _sessionService.getUserRole() ?? '';
        print("ROLE => $userRole");
        if (userRole == "1") {
          Navigator.pushReplacementNamed(context, '/home');
        } else if (userRole == "2") {
          Navigator.pushReplacementNamed(context, '/prof-home');
        } else if (userRole == "3") {
          Navigator.pushReplacementNamed(context, '/coordinator-home');
        } else if (userRole == "4") {
          Navigator.pushReplacementNamed(context, '/admin-home');
        }
      } else {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: ${data}')));
        print("DATA : $data");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการเชื่อมต่อ API')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _studentFirstNameController.dispose();
    _studentLastNameController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งรหัสผ่านและข้อมูลส่วนตัว')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'รหัสผ่าน',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'กรุณากรอกรหัสผ่าน'
                                      : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'ยืนยันรหัสผ่าน',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'กรุณายืนยันรหัสผ่าน'
                                      : null,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text('คำนำหน้าชื่อ:'),
                            const SizedBox(width: 10),
                            Expanded(
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
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'กรุณากรอกชื่อ'
                                      : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _studentLastNameController,
                          decoration: const InputDecoration(
                            labelText: 'นามสกุล',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null || value.isEmpty
                                      ? 'กรุณากรอกนามสกุล'
                                      : null,
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
                            } else if (value.length != 9) {
                              return 'รหัสนักศึกษาต้องมีความยาว 9 หลัก';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _submit,
                          child: Text(
                            'บันทึกข้อมูล',
                            style: GoogleFonts.prompt(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
