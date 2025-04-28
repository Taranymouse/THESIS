import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Admin/RequestGroup/admin_group_subject_table.dart';

class ProfRequestGroup extends StatefulWidget {
  final List<int> studentIds;

  const ProfRequestGroup({super.key, required this.studentIds});

  @override
  State<ProfRequestGroup> createState() => _ProfRequestGroupState();
}

class _ProfRequestGroupState extends State<ProfRequestGroup> {
  late List<int> studentIds;
  List<PlatformFile> selectedFiles = [];

  List<Map<String, dynamic>> groupProjects = []; // สำหรับ groups/members

  List<Map<String, dynamic>> priorities = [];
  final SessionService sessionService = SessionService();
  List<Professor> professorList = [];

  String advisorName = '';

  int? selectedProfessorId;

  int? selectedAdvisorIdFromSession;

  @override
  void initState() {
    super.initState();
    studentIds = widget.studentIds;
    fetchPriorities();
    fetchProfessorsAndAdvisor();
  }

  Future<void> fetchPriorities() async {
    final int? idGroupProject = await sessionService.getProjectGroupId();
    print(
      "### From admin_request_group ###\n id_group_project : $idGroupProject",
    );
    try {
      if (idGroupProject != 0) {
        final response = await http.get(
          Uri.parse('$baseUrl/api/check/$idGroupProject'),
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          setState(() {
            priorities = List<Map<String, dynamic>>.from(data);
          });
        } else {
          print('Failed to fetch priorities: ${response.statusCode}');
          print(
            'นักศึกษาไม่ได้เลือกอันดับกลุ่มมา แสดงว่าเลือกอาจารย์ที่ปรึกษามา',
          );
        }
      } else {
        print("!!### ไม่มี id_group_project ที่เก็บมาเลย");
      }
    } catch (e) {
      print('Error fetching priorities: $e');
    }
  }

  Future<void> fetchProfessorsAndAdvisor() async {
    try {
      await fetchProfessors(); // โหลด professorList ให้เสร็จก่อน

      final int? idMemberGroup =
          await sessionService.getIdmemberInGroupProject();
      print("!!## idMemberGroup (จาก group project): $idMemberGroup");

      if (idMemberGroup != null && idMemberGroup != 0) {
        setState(() {
          selectedProfessorId = idMemberGroup; // <<<<< เพิ่มบรรทัดนี้
          selectedAdvisorIdFromSession = idMemberGroup;
        });

        final Professor advisor = professorList.firstWhere(
          (prof) => prof.idMember == idMemberGroup,
          orElse: () => Professor(idMember: 0, fullName: ''),
        );
        if (advisor.fullName.isNotEmpty) {
          setState(() {
            advisorName = advisor.fullName;
          });
        }
      } else {
        print("ไม่ได้ id_member จาก session");
      }
    } catch (e) {
      print('Error fetching professors and advisor: $e');
    }
  }

  Future<void> fetchProfessors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/groups/professors'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          professorList = data.map((item) => Professor.fromJson(item)).toList();
        });
      } else {
        print('Failed to fetch professors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching professors: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "แบบคำร้องขอเข้ารับการจัดสรรกลุ่มสำหรับการจัดทำโครงงานปริญญานิพนธ์",
        ),
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              AdminGroupSubjectTable(studentIds: studentIds),
              const SizedBox(height: 10),
              const Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(height: 10),
              const Text(
                "* กรณีนักศึกษามีอาจารย์ที่ปรึกษาโครงงานแล้วเท่านั้น",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 15),

              /// ========== ตรงนี้โชว์ชื่ออาจารย์ ==========
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "ชื่ออาจารย์ที่ปรึกษา :",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    advisorName.isNotEmpty
                        ? advisorName
                        : 'ไม่ได้เลือกอาจารย์ที่ปรึกษา',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(height: 10),
              const Text(
                "* กรณีนักศึกษายัง ไม่มี อาจารย์ที่ปรึกษาโครงงานเท่านั้น",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 10),

              /// ===== ตาราง priorities =====
              if (priorities.isNotEmpty)
                DataTable(
                  columns: [
                    DataColumn(
                      label: Text('อันดับ', style: GoogleFonts.prompt()),
                    ),
                    DataColumn(
                      label: Text('กลุ่ม', style: GoogleFonts.prompt()),
                    ),
                  ],
                  rows:
                      priorities.isNotEmpty
                          ? priorities.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;
                            return DataRow(
                              cells: [
                                DataCell(Text('${index + 1}')),
                                DataCell(Text('${item['group_name']}')),
                              ],
                            );
                          }).toList()
                          : [],
                ),
              if (priorities.isEmpty)
                const Text("นักศึกษาเลือกอาจารย์ที่ปรึกษาแล้ว"),
              const SizedBox(height: 20),

              const Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
                indent: 20,
                endIndent: 20,
              ),
              const Text("ผลการพิจารณาของผู้ประสานงาน"),
              const SizedBox(height: 10),

              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'เลือกอาจารย์ที่ปรึกษา',
                ),
                value: selectedProfessorId,
                items:
                    professorList.map((professor) {
                      return DropdownMenuItem<int>(
                        value: professor.idMember,
                        child: Text(
                          professor.fullName,
                          style: GoogleFonts.prompt(),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProfessorId = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (selectedProfessorId != null) {
                    print('อาจารย์ที่เลือก id: $selectedProfessorId');
                  } else {
                    print('ยังไม่ได้เลือกอาจารย์');
                  }
                  // update member_approve เป็น 1 ด้วยใน group_project
                  // id_status เป็น 4 (กลุ่มได้รับการยืนยันแล้ว)
                },
                child: Text("ยืนยัน", style: GoogleFonts.prompt()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Professor {
  final int idMember;
  final String fullName;

  Professor({required this.idMember, required this.fullName});

  factory Professor.fromJson(Map<String, dynamic> json) {
    return Professor(
      idMember: json['id_member'],
      fullName: '${json['fname']} ${json['lname']}',
    );
  }
}
