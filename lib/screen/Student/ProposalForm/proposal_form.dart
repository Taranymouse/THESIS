import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Form/Form_Options/File/fileupload.dart';
import 'package:project/screen/Student/document_router.dart';
import 'package:project/screen/Student/home.dart';

class ProposalForm extends StatefulWidget {
  const ProposalForm({super.key});

  @override
  State<ProposalForm> createState() => _ProposalFormState();
}

class _ProposalFormState extends State<ProposalForm> {
  final SessionService sessionService = SessionService();
  List<Map<String, dynamic>> studentList = [];
  String? termName;
  String? year;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await getHead();
  }

  Future<void> getHead() async {
    final id_student = await sessionService.getUpdatedStudentIds();

    final response = await http.post(
      Uri.parse('$baseUrl/api/check/group-head-calculate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(id_student),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      print("Data : => $data");

      setState(() {
        studentList = List<Map<String, dynamic>>.from(data);
        if (studentList.isNotEmpty) {
          final headInfo = studentList[0]['head_info'];
          termName = headInfo['term_name'];
          year = headInfo['year'].toString(); // แปลงให้แน่ใจว่าเป็น String
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("แบบคำร้องขอเสนอหัวข้อโครงงานปริญญานิพนธ์"),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: DocumentRouter()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "สมาชิก",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...studentList.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final student = entry.value;
              final info = student['head_info'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  "$index) ${info['first_name']} ${info['last_name']} รหัสนักศึกษา ${info['code_student']}",
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                style: GoogleFonts.prompt(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(
                    text:
                        "มีความประสงค์ที่จะขอเสนอหัวข้อโครงงานปริญญานิพนธ์ประจำภาคการศึกษา ",
                  ),
                  TextSpan(
                    text: termName ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const TextSpan(text: " ปีการศึกษา "),
                  TextSpan(
                    text: year ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text("ชื่อโครงงานภาษาไทย : "),
            const SizedBox(height: 20),
            const Text("ชื่อโครงงานภาษาอังกฤษ : "),
            const SizedBox(height: 20),
            const Text("กรุณาอัพโหลดเอกสาร IT01D / CS01D"),
            FileUploadWidget(),
          ],
        ),
      ),
    );
  }
}
