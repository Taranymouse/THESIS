import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Admin/RequestGroup/admin_request_group.dart';
import 'package:project/screen/Admin/adminhome.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';

class AdminStudentAllocate extends StatefulWidget {
  const AdminStudentAllocate({super.key});

  @override
  State<AdminStudentAllocate> createState() => _AdminStudentAllocateState();
}

class _AdminStudentAllocateState extends State<AdminStudentAllocate> {
  List<dynamic> groupProjects = [];
  final SessionService sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/check/group-project-current'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        groupProjects = data;
      });
      print('Data fetched successfully: $data');
    } else {
      print('Failed to fetch data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ระจัดการนักศึกษา"),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: AdminHomepage()),
      ),
      body:
          groupProjects.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: groupProjects.length,
                itemBuilder: (context, index) {
                  final student_group = groupProjects[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                        student_group['members'] ?? "ไม่มีข้อมูลนักศึกษา",
                      ),
                      subtitle: Text(
                        student_group['name_doc'] ?? "เอกสารไม่ทราบชื่อ",
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        // แปลง String -> int ก่อน
                        final int studentId =
                            int.tryParse(
                              student_group['student_ids'].toString(),
                            ) ??
                            0;

                        if (studentId != 0) {
                          // ถ้าแปลงได้จริง ๆ (ไม่ใช่ 0)
                          await sessionService.saveUpdatedStudentIds(
                            [studentId], // ส่งเป็น List<int>
                          );
                          print(
                            "บันทึก id_student ของกลุ่มนี้ สำเร็จ : $studentId",
                          );
                          final test =
                              await sessionService.getUpdatedStudentIds();
                          print("test: $test");
                          // แล้วค่อยเปลี่ยนหน้า
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      AdminRequestGroup(studentIds: test),
                            ),
                          );
                        } else {
                          // ถ้าแปลงไม่ได้ (studentId = 0) ให้แจ้งเตือน
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ไม่สามารถบันทึก student id ได้'),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
    );
  }
}
