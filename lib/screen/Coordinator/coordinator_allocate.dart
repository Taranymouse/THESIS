import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Coordinator/coordinator_home.dart';
import 'package:project/screen/Coordinator/coordinator_request_group.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';

class CoordinatorAllocate extends StatefulWidget {
  const CoordinatorAllocate({super.key});

  @override
  State<CoordinatorAllocate> createState() => _CoordinatorAllocateState();
}

class _CoordinatorAllocateState extends State<CoordinatorAllocate> {
  final SessionService sessionService = SessionService();
  late int idGroup;
  List<Map<String, dynamic>> matchedProjects = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await onCheckIdGroupProject();
    await onFetchGroupProject();
  }

  Future<void> onCheckIdGroupProject() async {
    final idGroupProject = await sessionService.getProjectGroupId();
    print(
      '!!## FROM CoordinatorAllocate ##!! \n TEST => id_group_project : $idGroupProject',
    );
    final int checkIdGroup = idGroupProject ?? 0;
    if (checkIdGroup != 0) {
      idGroup = checkIdGroup;
    } else {
      print("ไม่มี id_group_project");
    }
  }

  Future<void> onFetchGroupProject() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/check/group-project-current'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        matchedProjects =
            data
                .where((project) {
                  return project['assigned_group'] == idGroup;
                })
                .cast<Map<String, dynamic>>()
                .toList();

        print("Matched Projects: $matchedProjects");
      } else {
        print('Failed to fetch group projects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in onFetchGroupProject: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("จัดสรรนักศึกษาภายในกลุ่ม"),
        centerTitle: true,
        leading: BackButtonWidget(
          targetPage: CoordinatorHome(),
        ), // เปลี่ยนตามหน้ากลับของคุณ
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : matchedProjects.isEmpty
              ? const Center(
                child: Text(
                  'ยังไม่มีข้อมูล',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : ListView.builder(
                itemCount: matchedProjects.length,
                itemBuilder: (context, index) {
                  final studentGroup = matchedProjects[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                        studentGroup['members'] ?? 'ไม่มีข้อมูลนักศึกษา',
                      ),
                      subtitle: Text(
                        studentGroup['name_doc'] ?? 'ไม่มีชื่อเอกสาร',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        final int studentId =
                            int.tryParse(
                              studentGroup['student_ids'].toString(),
                            ) ??
                            0;
                        final int groupId =
                            int.tryParse(
                              studentGroup['id_group_project'].toString(),
                            ) ??
                            0;
                        final int idMember =
                            int.tryParse(
                              studentGroup['id_member'].toString(),
                            ) ??
                            0;

                        if (studentId != 0) {
                          await sessionService.saveUpdatedStudentIds([
                            studentId,
                          ]);
                          if (groupId != 0) {
                            await sessionService.setProjectGroupId(groupId);
                            print("บันทึก id_group_project : $groupId");
                          }
                          if (idMember != 0) {
                            await sessionService.setIdmember(idMember);
                            print("บันทึก id_member : $idMember");
                          }

                          print("บันทึก id_student : $studentId");

                          final testIdStudent =
                              await sessionService.getUpdatedStudentIds();
                          final testIdGroupProject =
                              await sessionService.getProjectGroupId();
                          final testIdMember =
                              await sessionService.getIdmember();
                          print("test id_student : $testIdStudent");
                          print("test id_group_project : $testIdGroupProject");
                          print("test id_member : $testIdMember");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => CoordinatorRequestGroup(
                                    studentIds: testIdStudent,
                                  ),
                            ),
                          );
                        } else {
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
