import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/group_subject_table.dart';
import 'package:project/screen/student_detailpage.dart';

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
  int? selectedGroups;
  List<Map<String, dynamic>> priorities = [];
  final SessionService sessionService = SessionService();
  List<Professor> professorList = [];
  List<Map<String, dynamic>> studentData = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    studentIds = widget.studentIds;
    await fetchStudentInfo();
    await fetchGroupProject();
    await fetchPriorities();
  }

  Future<void> fetchStudentInfo() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/check/group-all-subjects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(studentIds),
    );

    List<Map<String, dynamic>> studentList = [];

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      studentList = List<Map<String, dynamic>>.from(data);
    } else {
      print('Failed to fetch student info: ${response.statusCode}');
      return;
    }

    // ดึง transcript
    final responseTranscript = await http.post(
      Uri.parse('$baseUrl/api/check/get-transcript-group'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(studentIds),
    );

    if (responseTranscript.statusCode == 200) {
      final transcriptData = jsonDecode(
        utf8.decode(responseTranscript.bodyBytes),
      );
      final transcriptMap = {
        for (var item in transcriptData)
          item['id_student']: mapTranscriptUrl(
            item['transcript_file'],
            baseUrl,
          ),
      };

      // รวม transcript เข้ากับ studentList
      for (var student in studentList) {
        final id = student['id_student'];
        student['transcript_file'] = transcriptMap[id]; // ใส่ transcript เข้าไป
      }

      setState(() {
        studentData = studentList;
      });
    } else {
      print(
        'Failed to fetch student transcript: ${responseTranscript.statusCode}',
      );
    }
  }

  // ✅ ฟังก์ชันแปลง localhost เป็น baseUrl
  String mapTranscriptUrl(String? url, String baseUrl) {
    if (url == null) return '';
    if (url.contains('localhost')) {
      return url.replaceFirst('http://localhost:8000', baseUrl);
    }
    return url;
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
              // Card ที่กดไปดูรายละเอียดของนักศึกษาแต่ละคน
              if (studentData.isNotEmpty)
                Column(
                  children:
                      studentData.map((student) {
                        final head = student['head_info'];
                        final code = head['code_student'];
                        final firstName = head['first_name'];
                        final lastName = head['last_name'];
                        final branchId = head['id_branch'];
                        final prefix = branchId == 1 ? 'IT00G' : 'CS00G';

                        return Card(
                          child: ListTile(
                            title: Text(
                              '$prefix-$code-$firstName-$lastName',
                              style: GoogleFonts.prompt(fontSize: 14),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => StudentDetailpage(
                                        student: student,
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                )
              else
                const Text("ไม่มีข้อมูลนักศึกษา"),
              const SizedBox(height: 10),
              const Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(height: 10),
              GroupSubjectTable(studentIds: studentIds),
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
                "อันดับกลุ่มที่นักศึกษาทำการเลือกมา",
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
