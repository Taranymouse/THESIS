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

class ProfRequestGroup extends StatefulWidget {
  final List<int> studentIds;

  const ProfRequestGroup({super.key, required this.studentIds});

  @override
  State<ProfRequestGroup> createState() => _ProfRequestGroupState();
}

class _ProfRequestGroupState extends State<ProfRequestGroup> {
  List<PlatformFile> selectedFiles = [];
  List<Map<String, dynamic>> groupProjects = []; // สำหรับ groups/members
  List<Map<String, dynamic>> priorities = [];
  final SessionService sessionService = SessionService();
  String? advisorName;
  int? idGroupProject;
  List<Map<String, dynamic>> studentData = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await fetchStudentInfo();
    await getProfessorName();
    await fetchPriorities();
  }

  Future<void> fetchStudentInfo() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/check/group-all-subjects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(widget.studentIds),
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
      body: jsonEncode(widget.studentIds),
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

  Future<void> getProfessorName() async {
    advisorName = await sessionService.getNameProfessor();
    print("TEST advisorName => $advisorName");
  }

  Future<void> fetchPriorities() async {
    final int? idGroup = await sessionService.getProjectGroupId();
    print(
      "### From coordinator_request_group ###\n id_group_project : $idGroup",
    );
    try {
      if (idGroup != 0) {
        final response = await http.get(
          Uri.parse('$baseUrl/api/check/$idGroup'),
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

  Future<void> updateMemberApprove() async {
    final int? idGroup = await sessionService.getProjectGroupId();
    if (idGroup != null) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/check/professor-update-approve'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'id_group_project': idGroup}),
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
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.topSlide,
        title: 'แจ้งเตือน',
        desc: 'ไม่ทราบกลุ่มของอาจารย์',
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
              GroupSubjectTable(studentIds: widget.studentIds),
              const SizedBox(height: 10),
              const Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(height: 10),
              const Text("ผลการพิจารณาของอาจารย์"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  // update coordinator_confirmed เป็น 1 ด้วยใน group_project
                  // id_status เป็น 3 (มีอาจารย์รับกลุ่มแล้ว)
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.warning,
                    animType: AnimType.topSlide,
                    title: 'ยืนยัน',
                    desc: 'ต้องการที่จะรับนักศึกษาหรือไม่ ?',
                    btnOkOnPress: () {
                      updateMemberApprove();
                    },
                    btnCancelOnPress: () {
                      print("ไม่รับ");
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
