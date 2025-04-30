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
                      // subtitle: Text(
                      //   student_group['name_doc'] ?? "เอกสารไม่ทราบชื่อ",
                      // ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        final String studentIdsStr =
                            student_group['student_ids'] ?? "";
                        final List<int> studentIds =
                            studentIdsStr
                                .split(',')
                                .map((id) => int.tryParse(id.trim()))
                                .where((id) => id != null)
                                .cast<int>()
                                .toList();

                        final int groupId =
                            int.tryParse(
                              student_group['id_group_project'].toString(),
                            ) ??
                            0;
                        final String professorName =
                            student_group['professor_name'] ??
                            "ยังไม่มีอาจารย์";

                        if (studentIds.isNotEmpty) {
                          await sessionService.saveUpdatedStudentIds(
                            studentIds,
                          );
                          await sessionService.setNameProfessor(professorName);

                          if (groupId != 0) {
                            await sessionService.setProjectGroupId(groupId);
                            print(
                              "บันทึก id_group_project ของกลุ่มนี้สำเร็จ : $groupId",
                            );
                          } else {
                            print(
                              "บันทึก id_group_project ของกลุ่มนี้ไม่สำเร็จ",
                            );
                          }

                          print(
                            "บันทึก student_ids ของกลุ่มนี้สำเร็จ : $studentIds",
                          );
                          print(
                            "บันทึก professor_name สำเร็จ : $professorName",
                          );

                          final testIdStudent =
                              await sessionService.getUpdatedStudentIds();
                          final testGroupId =
                              await sessionService.getProjectGroupId();
                          final testProfessorName =
                              await sessionService.getNameProfessor();

                          print("test student_ids : $testIdStudent");
                          print("test id_group_project : $testGroupId");
                          print("test professor_name : $testProfessorName");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => AdminRequestGroup(
                                    studentIds: testIdStudent,
                                  ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ไม่สามารถบันทึก student ids ได้'),
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
