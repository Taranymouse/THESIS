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

                        final int groupId =
                            int.tryParse(
                              student_group['id_group_project'].toString(),
                            ) ??
                            0;

                        final int id_member =
                            int.tryParse(
                              student_group['id_member'].toString(),
                            ) ??
                            0;

                        if (studentId != 0) {
                          // ถ้าแปลงได้จริง ๆ (ไม่ใช่ 0)
                          await sessionService.saveUpdatedStudentIds(
                            [studentId], // ส่งเป็น List<int>
                          );

                          if (groupId != 0) {
                            await sessionService.setProjectGroupId(
                              groupId, // ส่งเป็น int
                            );
                            print(
                              "บันทึก id_group_project ของกลุ่มนี้ สำเร็จ : $groupId",
                            );
                          } else {
                            // ถ้าแปลงไม่ได้ (groupId = 0) ให้แจ้งเตือน
                            print(
                              "บันทึก id_group_project ของกลุ่มนี้ ไม่สำเร็จ",
                            );
                          }

                          if (id_member != 0) {
                            await sessionService.setIdmember(id_member);
                            print(
                              "บันทึก id_member ของกลุ่มนี้ สำเร็จ : $id_member",
                            );
                          } else {
                            print("บันทึก id_member ของกลุ่มนี้ ไม่สำเร็จ");
                          }

                          print(
                            "บันทึก id_student ของกลุ่มนี้ สำเร็จ : $studentId",
                          );

                          final test_id_student =
                              await sessionService.getUpdatedStudentIds();
                          print("test id_student : $test_id_student");
                          final test_id_group_project =
                              await sessionService.getProjectGroupId();
                          print(
                            "test id_group_project : $test_id_group_project",
                          );
                          final test_id_member =
                              await sessionService.getIdmember();
                          print("test id_member : $test_id_member");
                          // แล้วค่อยเปลี่ยนหน้า
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AdminRequestGroup(
                                    studentIds: test_id_student,
                                  ),
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
