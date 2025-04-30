import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Admin/RequestGroup/admin_group_subject_table.dart';

class AdminRequestGroup extends StatefulWidget {
  final List<int> studentIds;

  const AdminRequestGroup({super.key, required this.studentIds});

  @override
  State<AdminRequestGroup> createState() => _AdminRequestGroupState();
}

class _AdminRequestGroupState extends State<AdminRequestGroup> {
  late List<int> studentIds;
  List<PlatformFile> selectedFiles = [];

  List<Map<String, dynamic>> groupProjects = []; // สำหรับ groups/members
  int? selectedGroups; // สำหรับเลือกกลุ่ม

  List<Map<String, dynamic>> priorities = [];
  final SessionService sessionService = SessionService();
  List<Professor> professorList = [];

  String? advisorName; // <-- เพิ่มตัวแปรตรงนี้

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    studentIds = widget.studentIds;

    await getProfessorName();
    await fetchGroupProject();
    await fetchPriorities();
  }

  Future<void> getProfessorName() async {
    advisorName = await sessionService.getNameProfessor();
  }

  Future<void> fetchGroupProject() async {
    final response = await http.get(Uri.parse('$baseUrl/api/groups/members'));
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      setState(() {
        groupProjects = List<Map<String, dynamic>>.from(data);
        groupProjects.sort((a, b) => a['id_group'].compareTo(b['id_group']));
        // selectedGroups = List.filled(5, null);
      });
    } else {
      print('Failed to fetch group project data: ${response.statusCode}');
    }
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
        }
      } else {
        print("!!### ไม่มี id_group_project ที่เก็บมาเลย");
      }
    } catch (e) {
      print('Error fetching priorities: $e');
    }
  }

  Future<void> updateAssignedGroup() async {
    final int? idGroupProject = await sessionService.getProjectGroupId();

    if (idGroupProject != null && selectedGroups != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/check/admin-update-assigned-group'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id_group_project': idGroupProject,
            'assigned_group': selectedGroups,
          }),
        );

        if (response.statusCode == 200) {
          // อัปเดตสำเร็จ
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.topSlide,
            title: 'สำเร็จ',
            desc: 'อัพเดทกลุ่มให้กับกลุ่มโปรเจคสำเร็จ',
            btnOkOnPress: () {},
          ).show();
        } else {
          // แสดงข้อผิดพลาด
          print('อัปเดตไม่สำเร็จ: ${response.statusCode}');
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.topSlide,
            title: 'เกิดข้อผิดพลาด',
            desc: 'ไม่สามารถอัพเดทข้อมูลกลุ่มโปรเจคได้',
            btnOkOnPress: () {},
          ).show();
        }
      } catch (e) {
        print('เกิดข้อผิดพลาดขณะส่งข้อมูล: $e');
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.topSlide,
          title: 'แจ้งเตือน',
          desc: 'เกิดข้อผิดพลาด: $e',
          btnOkOnPress: () {},
        ).show();
      }
    } else {
      print("id_group_project หรือ selectedGroups เป็น null");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.topSlide,
        title: 'แจ้งเตือน',
        desc: 'กรุณาเลือกกลุ่มให้กับโปรเจคก่อนยืนยัน',
        btnOkOnPress: () {},
      ).show();
      return;
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
                    advisorName ?? 'กำลังโหลด...',
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
                const Text("นักศึกษาไม่ได้เลือกอันดับกลุ่ม"),
              const Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(height: 10),
              const Text("ผลการพิจารณาของผู้ประสานงานรายวิชา"),
              const SizedBox(height: 10),

              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelText: 'เลือกกลุ่มโครงงาน',
                ),
                value: null,
                items:
                    groupProjects
                        .where((group) => group['id_group'] != 1)
                        .map<DropdownMenuItem<int>>((group) {
                          return DropdownMenuItem<int>(
                            value: group['id_group'],
                            child: Text(
                              group['group_name'] ?? '',
                              style: GoogleFonts.prompt(),
                            ),
                          );
                        })
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      selectedGroups = value;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  print('กลุ่มที่เลือก: $selectedGroups');
                  // update assigned_group ด้วยใน group_project
                  // id_status เป็น 2 (รออาจารย์ประสานงานยืนยัน)
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.topSlide,
                    title: 'ยืนยัน',
                    desc: 'ต้องการที่จะอัพเดทข้อมูลใช่ไหม ?',
                    btnOkOnPress: () {
                      updateAssignedGroup();
                    },
                    btnCancelOnPress: () {
                      print("ไม่อัพเดท");
                    },
                  ).show();
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
