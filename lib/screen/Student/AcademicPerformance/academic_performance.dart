import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourse.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourseYear.dart';
import 'package:project/screen/Form/Form_Options/dropdown/semester.dart';
import 'package:project/screen/Form/Form_Options/dropdown/stdyear.dart';
import 'package:project/screen/Student/document_router.dart';
import 'package:project/screen/Student/AcademicPerformance/subject_table.dart';

class PerformanceForm extends StatefulWidget {
  const PerformanceForm({super.key});
  @override
  State<PerformanceForm> createState() => _PerformanceFormState();
}

class _PerformanceFormState extends State<PerformanceForm> {
  final List<MemberData> members = [MemberData()];
  final SessionService _sessionService = SessionService();

  final ValueNotifier<bool> canSubmitAllNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    // กำหนดข้อมูลนักศึกษาคนแรกจาก SessionService
    _initializeFirstMember();
    // ฟังการเปลี่ยนแปลงของสมาชิกแต่ละคน
    for (var m in members) {
      m.ready.addListener(_onReadyChanged);
    }
  }

  Future<void> _initializeFirstMember() async {
    final SessionService sessionService = SessionService();
    final firstMember = members.first;

    // ใช้ await เพื่อรอผลลัพธ์จาก Future
    final userName = await sessionService.getUserName();
    final userLastName = await sessionService.getUserLastName();
    final studentId = await sessionService.getStudentId();
    print("First: $userName");
    print("Lastname: $userLastName");
    print("studentId: $studentId");

    // ตั้งค่าข้อมูลใน TextEditingController
    setState(() {
      firstMember.firstNameController.text = userName ?? '';
      firstMember.lastNameController.text = userLastName ?? '';
      firstMember.studentIdController.text = studentId ?? '';
    });
  }

  void _updateCanSubmitAll() {
    final result = members.every((m) {
      if (!m.ready.value) return false;
      if (m.savedSubjectDetails.length < m.totalItems) return false;
      for (final detail in m.savedSubjectDetails.values) {
        if (detail.values.any((v) => v == null)) return false;
      }
      if (m.gpaController.text.isEmpty) return false;
      if (m.fileSelected = false) return false;
      return true;
    });
    canSubmitAllNotifier.value = result;
  }

  bool get _canSubmitAll {
    final result = members.every((m) {
      if (!m.ready.value) {
        return false;
      }
      if (m.savedSubjectDetails.length < m.totalItems) {
        return false;
      }
      for (final detail in m.savedSubjectDetails.values) {
        if (detail.values.any((v) => v == null)) {
          return false;
        }
      }
      if (m.gpaController.text.isEmpty) {
        return false;
      }
      return true;
    });
    return result;
  }

  int getTermIdFromName(String? name) {
    switch (name?.trim()) {
      case "ต้น":
      case "ภาคต้น":
        return 1;
      case "ปลาย":
      case "ภาคปลาย":
        return 2;
      case "ฤดูร้อน":
        return 3;
      default:
        return 0;
    }
  }

  int getGradeIdFromCode(String? code) {
    const gradeMap = {
      "A": 1,
      "B+": 2,
      "B": 3,
      "C+": 4,
      "C": 5,
      "D+": 6,
      "D": 7,
      "F": 8,
      "I": 9,
      "W": 10,
      "T": 11,
    };
    return gradeMap[code?.toUpperCase()] ?? 0;
  }

  Future<void> _submitAll() async {
    // ตรวจสอบก่อนส่ง: ใครมีวิชาไม่ผ่าน >1
    final badStudents =
        members.where((m) {
          final failed =
              m.savedSubjectDetails.values.where((d) {
                final g = d['grade'];
                return g == 'F' || g == 'I' || g == 'W';
              }).length;
          return failed > 1;
        }).toList();

    if (badStudents.isNotEmpty) {
      final ids = badStudents
          .map((m) => m.studentIdController.text)
          .join(' , ');
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.topSlide,
        title: 'ไม่ผ่านเงื่อนไข',
        titleTextStyle: GoogleFonts.prompt(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
        desc:
            'นักศึกษาที่มีวิชาที่ไม่ผ่าน / ยังไม่ลงทะเบียน\nมากกว่า 1 วิชา\nรหัสนักศึกษา $ids',
        btnOkOnPress: () {},
        btnOkText: 'รับทราบ',
        buttonsTextStyle: GoogleFonts.prompt(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ).show();
      return; // หยุด ไม่ส่งข้อมูล
    }

    // 1) อัพเดตข้อมูลนักศึกษา
    final updateBody = {
      "student":
          members.map((m) {
            return {
              "s_id": m.studentIdController.text,
              "overall_grade": m.gpaController.text,
              "branch": int.parse(m.course!),
              "course": int.parse(m.courseYear!),
              "semester": getTermIdFromName(m.semester),
              "year": int.parse(m.year!),
            };
          }).toList(),
    };

    final updateResponse = await http.put(
      Uri.parse('$baseUrl/api/student/update'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(updateBody),
    );

    final responseBody = jsonDecode(utf8.decode(updateResponse.bodyBytes));
    if (updateResponse.statusCode == 200 && responseBody['resCode'] == 200) {
      final List<int> studentIds = List<int>.from(responseBody['code_student']);
      await _sessionService.saveUpdatedStudentIds(studentIds);
      print("✅ บันทึก id_student ที่อัปเดต: $studentIds");
    } else {
      print("X บันทึก id_student ไม่ได้: ${responseBody['resCode']}");
    }

    if (updateResponse.statusCode != 200) {
      final failedIds = members
          .map((m) => m.studentIdController.text)
          .join(', ');
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        title: 'ไม่พบข้อมูลนักศึกษา',
        titleTextStyle: GoogleFonts.prompt(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
        desc: 'กรุณาตรวจสอบ รหัสนักศึกษา: $failedIds',
        btnOkOnPress: () {},
        btnOkText: 'รับทราบ',
        buttonsTextStyle: GoogleFonts.prompt(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ).show();
      return; // หยุด ไม่ส่งข้อมูล
    }

    // 2) เพิ่มรายวิชา
    final createBody = {
      "student":
          members.map((m) {
            final subjectList =
                m.savedSubjectDetails.entries.map((e) {
                  return {
                    "subject_id": int.parse(e.key),
                    "term_id": getTermIdFromName(e.value["semester"]),
                    "year": int.parse(e.value["year"]),
                    "grade": getGradeIdFromCode(e.value["grade"]),
                  };
                }).toList();
            return {"s_id": m.studentIdController.text, "subject": subjectList};
          }).toList(),
    };

    final createResponse = await http.post(
      Uri.parse('$baseUrl/api/student/create/subject'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(createBody),
    );

    if (createResponse.statusCode != 200) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        title: 'ไม่สามารถเพิ่มข้อมูลได้',
        titleTextStyle: GoogleFonts.prompt(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
        desc: 'ไม่สามารถเพิ่มข้อมูลได้ : \nเนื่องจากมีเข้ามูลในระบบแล้ว',
        btnOkOnPress: () {},
        btnOkText: 'รับทราบ',
        buttonsTextStyle: GoogleFonts.prompt(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ).show();
      return; // หยุด ไม่ส่งข้อมูล
    }

    // 3) Upload transcript
    final List<String> codeStudents = [];
    final List<PlatformFile> transcriptFiles = [];

    for (final m in members) {
      if (m.selectedFiles != null && m.selectedFiles.isNotEmpty) {
        // สมมติให้เลือกได้ไฟล์เดียว/คน (ถ้าเลือกหลายไฟล์/คน ให้วนลูปเพิ่ม)
        codeStudents.add(m.studentIdController.text);
        transcriptFiles.add(m.selectedFiles.first);
      }
    }

    if (codeStudents.isNotEmpty && transcriptFiles.isNotEmpty) {
      final uri = Uri.parse('$baseUrl/api/upload/student/upload-transcripts');

      final dio = Dio();
      final formData = FormData();

      for (final code in codeStudents) {
        formData.fields.add(MapEntry('code_students', code));
      }
      for (final file in transcriptFiles) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              file.path!,
              filename: path.basename(file.path!),
              contentType: MediaType('application', 'pdf'),
            ),
          ),
        );
      }
      final response = await dio.post(
        '$baseUrl/api/upload/student/upload-transcripts',
        data: formData,
      );

      if (response.statusCode == 200) {
        print('✅ Upload transcript success');
      } else {
        print('❌ Upload transcript failed: ${response.data}');
        // แจ้งเตือนผู้ใช้ด้วย AwesomeDialog หรืออื่น ๆ ได้
      }
    } else {
      print('ไม่มีไฟล์ transcript ที่ต้องอัปโหลด');
    }

    // แสดงข้อความสำเร็จ
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'สำเร็จ',
      titleTextStyle: GoogleFonts.prompt(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
      desc: 'ส่งข้อมูลสมาชิกทั้งหมดเรียบร้อยแล้ว',
      btnOkOnPress: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DocumentRouter()),
        );
      },
      btnOkText: 'รับทราบ',
      buttonsTextStyle: GoogleFonts.prompt(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ).show();
  }

  void _onReadyChanged() {
    setState(() {
      // _updateCanSubmitAll();
    });
  }

  void _addMember() {
    if (members.length >= 3) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.topSlide,
        title: 'ไม่สามารถเพิ่มได้',
        titleTextStyle: GoogleFonts.prompt(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.yellow[800],
        ),
        desc: 'สามารถเพิ่มสมาชิกได้สูงสุด 3 คน',
        btnOkOnPress: () {},
        btnOkText: 'รับทราบ',
        buttonsTextStyle: GoogleFonts.prompt(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ).show();
      return;
    }
    final m = MemberData();
    m.ready.addListener(_onReadyChanged);
    setState(() => members.add(m));
  }

  void _removeMember(int idx) {
    if (idx == 0) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.topSlide,
        title: 'คำแนะนำ',
        titleTextStyle: GoogleFonts.prompt(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
        desc: 'ไม่สามารถลบนักศึกษาคนแรกได้',
        btnOkOnPress: () {},
      ).show();
      return;
    }
    members[idx].ready.removeListener(_onReadyChanged);
    setState(() => members.removeAt(idx));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "แบบขอตรวจคุณสมบัติในการมีสิทธิขอจัดทำโครงงานปริญญานิพนธ์",
        ),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: DocumentRouter()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _addMember,
                  icon: const Icon(Icons.add),
                  label: Text("เพิ่มสมาชิก", style: GoogleFonts.prompt()),
                ),
                const Spacer(),
                Text("(${members.length}/3)"),
              ],
            ),
            const SizedBox(height: 10),
            ...members.asMap().entries.map((e) {
              final i = e.key;
              final d = e.value;
              return Card(
                key: ValueKey(i),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "สมาชิก ${i + 1}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          if (members.length > 1)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeMember(i),
                            ),
                        ],
                      ),
                      MemberForm(
                        data: d,
                        onGradesChanged: _updateCanSubmitAll,
                        onFilesChanged: _updateCanSubmitAll,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: canSubmitAllNotifier,
              builder: (context, canSubmit, child) {
                return ElevatedButton(
                  onPressed: _canSubmitAll ? _submitAll : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canSubmitAll ? Colors.green : Colors.grey,
                  ),
                  child: Text(
                    "ส่งแบบฟอร์ม",
                    style: GoogleFonts.prompt(color: Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MemberData {
  String? course, courseYear, semester, year;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final studentIdController = TextEditingController();
  final ready = ValueNotifier<bool>(false);
  int currentOffset = 0;
  int totalItems = 0;
  Map<String, Map<String, dynamic>> savedSubjectDetails = {};
  final TextEditingController gpaController = TextEditingController();
  bool fileSelected = false;
  List<PlatformFile> selectedFiles = [];

  void dispose() {
    gpaController.dispose();
  }
}

class MemberForm extends StatefulWidget {
  final MemberData data;
  final VoidCallback onGradesChanged;
  final VoidCallback onFilesChanged;
  const MemberForm({
    super.key,
    required this.data,
    required this.onGradesChanged,
    required this.onFilesChanged,
  });
  @override
  State<MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends State<MemberForm> {
  void _updateReady() {
    final d = widget.data;
    final valid =
        d.course != null &&
        d.courseYear != null &&
        d.semester != null &&
        d.year != null &&
        d.firstNameController.text.isNotEmpty &&
        d.lastNameController.text.isNotEmpty &&
        d.studentIdController.text.isNotEmpty &&
        d.fileSelected;
    print("จากไฟล์ academic_performance.dart");
    print("สถานะพร้อมส่งของ ${d.studentIdController.text}: $valid");
    d.ready.value = valid;
    print("สามารถส่งได้หรือยัง? : ${d.ready.value}");
  }

  @override
  void initState() {
    super.initState();
    // ฟังการเปลี่ยน text
    widget.data.firstNameController.addListener(_updateReady);
    widget.data.lastNameController.addListener(_updateReady);
    widget.data.studentIdController.addListener(_updateReady);
    // onFileSelected();
  }

  void onFileSelected() {
    widget.data.fileSelected = true;
    _updateReady();
  }

  @override
  Widget build(BuildContext ctx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // หลักสูตร+ปีหลักสูตร
        Row(
          children: [
            const Text("หลักสูตร:"),
            const SizedBox(width: 10),
            CourseDropdown(
              value: widget.data.course,
              onCourseChanged: (v) {
                setState(() {
                  widget.data.course = v;
                  print("Course: ${widget.data.course}");
                  _updateReady();
                });
              },
            ),
            const SizedBox(width: 20),
            const Text("ปีหลักสูตร:"),
            const SizedBox(width: 10),
            CourseYearDropdown(
              value: widget.data.courseYear,
              onCourseYearChanged: (v) {
                setState(() {
                  widget.data.courseYear = v;
                  print("CourseYear: ${widget.data.course}");
                  _updateReady();
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        // prefix+ชื่อ+นามสกุล
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: TextField(
                controller: widget.data.firstNameController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: "ชื่อ",
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 14,
                  ),
                ),
                onChanged: (value) {},
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: TextField(
                controller: widget.data.lastNameController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: "นามสกุล",
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 14,
                  ),
                ),
                onChanged: (value) {},
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 1,
              child: TextField(
                controller: widget.data.studentIdController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: "รหัสนักศึกษา",
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 14,
                  ),
                ),
                onChanged: (value) {},
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // ภาค+ปีการศึกษา
        Row(
          children: [
            const Text("ภาคการศึกษา: "),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
              child: Semester(
                selectedValue: widget.data.semester,
                onChanged: (v) {
                  setState(() {
                    widget.data.semester = v;
                    print("Semester: ${widget.data.semester}");
                    _updateReady();
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            const Text("ปีการศึกษา: "),
            const SizedBox(width: 10),
            SizedBox(
              width: 60,
              child: Stdyear(
                selectedValue: widget.data.year,
                onChanged: (v) {
                  setState(() {
                    widget.data.year = v;
                    print("Semester: ${widget.data.semester}");
                    _updateReady();
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // ตารางวิชา
        SubjectsTable(
          selectedCourse: widget.data.course,
          selectedCourseYear: widget.data.courseYear,
          firstNameController: widget.data.firstNameController,
          lastNameController: widget.data.lastNameController,
          studentIdController: widget.data.studentIdController,
          selectedSemester: widget.data.semester,
          selectedYear: widget.data.year,
          onGradeValidationChanged: (_) => widget.onGradesChanged(),
          memberData: widget.data,
          onFilesChanged: (memberData, files) {
            setState(() {
              memberData.selectedFiles = files;
              onFileSelected();
            });
          },
        ),
      ],
    );
  }
}
