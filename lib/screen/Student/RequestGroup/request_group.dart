import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:project/API/api_config.dart';
import 'package:project/ColorPlate/color.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Student/document_router.dart';
import 'package:project/screen/group_subject_table.dart';
import 'package:project/screen/student_detailpage.dart';

class RequestGroup extends StatefulWidget {
  final List<int> studentIds;

  const RequestGroup({super.key, required this.studentIds});

  @override
  State<RequestGroup> createState() => _RequestGroupState();
}

class _RequestGroupState extends State<RequestGroup> {
  late List<int> studentIds;
  List<String> availableSemesters = [];
  List<String> availableYears = [];
  List<GroupInfo> groupList = [];
  List<String?> selectedGroups = [];
  List<Professor> professorList = [];
  int? selectedProfessorId;
  List<Map<String, dynamic>> studentData = [];
  bool? isDoG;
  bool isLoading = true;
  bool isStudentDataLoaded = false;

  @override
  void initState() {
    super.initState();
    studentIds = widget.studentIds;
    initializeAll(); // เรียกใช้ฟังก์ชัน initailize
  }

  Future<void> initializeAll() async {
    await isDoneFromG();
    if (isDoG == true) {
      await fetchStudentInfo();
      await fetchGroups();
      await fetchProfessors();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> isDoneFromG() async {
    final SessionService sessionService = SessionService();
    final bool dofromg = await sessionService.isDoneFromG();
    isDoG = dofromg;
    print(" isDone : $isDoG");
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
        isStudentDataLoaded = true;
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

  Future<void> fetchGroups() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/groups/members'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        final filteredData =
            data.where((item) => item['id_group'] != 1).toList();
        filteredData.sort((a, b) => a['id_group'].compareTo(b['id_group']));

        List<String> alphabet = List.generate(
          26,
          (index) => String.fromCharCode(65 + index),
        );

        setState(() {
          groupList = List<GroupInfo>.generate(filteredData.length, (index) {
            final item = filteredData[index];
            final memberList = item['member'] ?? [];
            final hasProfessor = memberList.isNotEmpty;

            return GroupInfo(
              idGroup: item['id_group'],
              groupName:
                  '${alphabet[index]} ${item['group_name']}'
                  '${hasProfessor ? ' (${memberList[0]['professor_name']})' : ' (ยังไม่มีอาจารย์ที่ปรึกษา)'}',
              letter: alphabet[index],
            );
          });

          // ➡️ เพิ่มตรงนี้ เพื่อให้ selectedGroups มีขนาดเท่า groupList
          selectedGroups = List<String?>.filled(groupList.length, null);
        });
      } else {
        print('Failed to fetch groups: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching groups: $e');
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

  Future<void> submitRequest() async {
    final url = Uri.parse('$baseUrl/api/check/update');
    final SessionService sessionService = SessionService();
    final idGroupProject = await sessionService.getProjectGroupId();
    print("Test id_group_project => $idGroupProject");

    // ตรวจสอบว่าผู้ใช้เลือกอาจารย์ที่ปรึกษาหรือไม่
    bool hasProfessor = selectedProfessorId != null;

    // กรณีเลือกอาจารย์ที่ปรึกษา (ส่ง id_member)
    if (hasProfessor) {
      final requestBody = {
        "id_group_project": idGroupProject,
        "id_member": selectedProfessorId,
        "group_request": null,
      };

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.topSlide,
            title: 'สำเร็จ',
            desc: 'ส่งข้อมูลสำเร็จแล้ว',
            btnOkOnPress: () {},
          ).show();
        } else {
          print('Error: ${response.statusCode}');
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.topSlide,
            title: 'ผิดพลาด',
            desc: 'เกิดข้อผิดพลาดในการส่งข้อมูล กรุณาลองใหม่',
            btnOkOnPress: () {},
          ).show();
        }
      } catch (e) {
        print('Error sending request: $e');
      }
    }
    // กรณีไม่มีอาจารย์ที่ปรึกษา → ส่งอันดับกลุ่ม (group_request)
    else {
      // แปลง selectedGroups ที่เป็นตัวอักษร (A, B, C) → เป็น idGroup
      List<Map<String, dynamic>> groupRequest = [];

      for (int i = 0; i < selectedGroups.length; i++) {
        String? letter = selectedGroups[i];
        if (letter != null) {
          final matchedGroup = groupList.firstWhere((g) => g.letter == letter);
          groupRequest.add({
            "request_group": matchedGroup.idGroup,
            "priority": i + 1,
          });
        }
      }

      if (groupRequest.isEmpty) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.topSlide,
          title: 'แจ้งเตือน',
          desc: 'กรุณาเลือกอันดับกลุ่มอย่างน้อย 1 อันดับ',
          btnOkOnPress: () {},
        ).show();
        return;
      }

      final requestBody = {
        "id_group_project": idGroupProject,
        "id_member": 0,
        "group_request": groupRequest,
      };

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('ส่งข้อมูลสำเร็จ')));
        } else {
          print('Error: ${response.statusCode}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาดในการส่งข้อมูล')),
          );
        }
      } catch (e) {
        print('Error sending request: $e');
      }
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
        leading: BackButtonWidget(targetPage: DocumentRouter()),
      ),
      body:
          isLoading
              ? Center(
                child: LoadingAnimationWidget.hexagonDots(
                  color: ColorPlate.colors[6].color,
                  size: 30,
                ),
              )
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    children: [
                      if (isDoG == true) ...[
                        // Card ที่กดไปดูรายละเอียดของนักศึกษาแต่ละคน
                        if (!isStudentDataLoaded)
                          Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: ColorPlate.colors[6].color,
                              size: 30,
                            ),
                          )
                        else if (studentData.isNotEmpty)
                          Column(
                            children:
                                studentData.map((student) {
                                  final head = student['head_info'];
                                  final code = head['code_student'];
                                  final firstName = head['first_name'];
                                  final lastName = head['last_name'];
                                  final branchId = head['id_branch'];
                                  final prefix =
                                      branchId == 1 ? 'IT00G' : 'CS00G';

                                  return Card(
                                    child: ListTile(
                                      title: Text(
                                        '$prefix-$code-$firstName-$lastName',
                                        style: GoogleFonts.prompt(fontSize: 14),
                                      ),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                      ),
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
                        const SizedBox(height: 10),
                        Divider(
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "ชื่ออาจารย์ที่ปรึกษา :",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: DropdownButton<int>(
                                value: selectedProfessorId,
                                hint: Text(
                                  'เลือกอาจารย์ที่ปรึกษา',
                                  style: GoogleFonts.prompt(fontSize: 14),
                                ),
                                isExpanded: true,
                                items:
                                    professorList.map((professor) {
                                      return DropdownMenuItem<int>(
                                        value: professor.idMember,
                                        child: Text(
                                          professor.fullName,
                                          style: GoogleFonts.prompt(
                                            fontSize: 12,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedProfessorId = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        const SizedBox(height: 10),
                        Divider(
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
                        // ส่วนตารางเลือกกลุ่ม
                        const Text(
                          "ระบุอันดับกลุ่มที่ประสงค์จะเลือก :",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        if (groupList.isEmpty)
                          const Center(child: CircularProgressIndicator())
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children:
                                groupList.map((group) {
                                  return Text(
                                    group.groupName,
                                    style: GoogleFonts.prompt(fontSize: 14),
                                  );
                                }).toList(),
                          ),

                        const SizedBox(height: 20),
                        // ตาราง
                        if (groupList.isNotEmpty)
                          DataTable(
                            columns: [
                              DataColumn(
                                label: Text(
                                  'อันดับที่',
                                  style: GoogleFonts.prompt(),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'กลุ่ม',
                                  style: GoogleFonts.prompt(),
                                ),
                              ),
                            ],
                            rows: List.generate(selectedGroups.length, (index) {
                              return DataRow(
                                cells: [
                                  DataCell(Center(child: Text('${index + 1}'))),
                                  DataCell(
                                    DropdownButton<String>(
                                      value: selectedGroups[index],
                                      hint: Text(
                                        'เลือกกลุ่ม',
                                        style: GoogleFonts.prompt(fontSize: 14),
                                      ),
                                      isExpanded: true,
                                      items:
                                          groupList.map((group) {
                                            return DropdownMenuItem<String>(
                                              value:
                                                  group
                                                      .letter, // เก็บแค่ตัว A, B, C, D
                                              child: Center(
                                                child: Text('${group.letter}'),
                                              ),
                                            );
                                          }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedGroups[index] = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: () {
                            // TODO: กดส่งแบบฟอร์ม

                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.warning,
                              animType: AnimType.topSlide,
                              title: 'ยืนยัน',
                              desc: 'ยืนยันที่จะส่งข้อมูลหรือไม่',
                              btnOkOnPress: () {
                                submitRequest();
                              },
                              btnCancelOnPress: () {
                                print("ไม่ส่งข้อมูล");
                              },
                            ).show();
                          },
                          child: const Text("ส่งแบบฟอร์ม"),
                        ),
                      ] else ...[
                        Center(
                          child: Text(
                            "* กรุณาทำส่งแบบฟอร์มขอตรวจสอบคุณสมบัติก่อน \n(IT00G/CS00G)",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
    );
  }
}

class GroupInfo {
  final int idGroup;
  final String groupName;
  final String letter;

  GroupInfo({
    required this.idGroup,
    required this.groupName,
    required this.letter,
  });
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
