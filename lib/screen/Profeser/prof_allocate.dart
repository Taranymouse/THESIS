import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Profeser/prof_request_group.dart';
import 'package:project/screen/Profeser/profhome.dart';

class ProfAllocate extends StatefulWidget {
  const ProfAllocate({super.key});

  @override
  State<ProfAllocate> createState() => _ProfAllocateState();
}

class _ProfAllocateState extends State<ProfAllocate> {
  final SessionService sessionService = SessionService();
  late int idGroup;
  late int idMember;
  List<dynamic> matchedProjects = [];
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
    final idMemberProf = await sessionService.getIdmember();
    print(
      '!!## FROM ProfAllocate ##!! \n TEST => id_group_project : $idGroupProject , id_member : $idMemberProf',
    );
    final int checkIdGroup = idGroupProject ?? 0;
    final int checkIdmember = idMemberProf ?? 0;
    if (checkIdGroup != 0) {
      idGroup = checkIdGroup;
    } else {
      print("ไม่มี id_group_project");
    }
    if (checkIdmember != 0) {
      idMember = checkIdmember;
    } else {
      print("ไม่มี id_member");
    }
  }

  Future<void> onFetchGroupProject() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/check/professor-group-project/$idMember'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        print("DATA : ${data}");
        if (data.isNotEmpty) {
          matchedProjects = data;
        } else {
          print("ไม่มีข้อมูลตามฟิลเตอร์ด้วย => idGroup : $idMember");
        }
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
        title: const Text("แบบคำร้องขอจัดสรรกลุ่ม"),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: ProfHomepage()),
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
                      subtitle: Text("ประสงค์ให้คุณเป็นที่ปรึกษาโปรเจค"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        // แปลง student_ids เป็น List<int>
                        final String rawStudentIds =
                            studentGroup['student_ids'].toString();
                        final List<int> studentIdList =
                            rawStudentIds
                                .split(',')
                                .map((id) => int.tryParse(id.trim()))
                                .where((id) => id != null)
                                .cast<int>()
                                .toList();

                        final int groupId =
                            int.tryParse(
                              studentGroup['id_group_project'].toString(),
                            ) ??
                            0;
                        final String nameprof =
                            studentGroup['professor_name'] ?? '';

                        if (studentIdList.isNotEmpty) {
                          await sessionService.saveUpdatedStudentIds(
                            studentIdList,
                          );

                          if (groupId != 0) {
                            await sessionService.setProjectGroupId(groupId);
                            print("บันทึก id_group_project : $groupId");
                          }

                          if (nameprof.isNotEmpty) {
                            await sessionService.setNameProfessor(nameprof);
                            print("บันทึกชื่ออาจารย์ : $nameprof");
                          }

                          print("บันทึก id_student ทั้งหมด: $studentIdList");

                          final testIdStudent =
                              await sessionService.getUpdatedStudentIds();
                          final testIdGroupProject =
                              await sessionService.getProjectGroupId();
                          final testnameprof =
                              await sessionService.getNameProfessor();
                          print("test id_student : $testIdStudent");
                          print("test id_group_project : $testIdGroupProject");
                          print("test professor_name : $testnameprof");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ProfRequestGroup(
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
