import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourse.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourseYear.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectPrefix.dart';
import 'package:project/screen/Form/Form_Options/dropdown/semester.dart';
import 'package:project/screen/Form/Form_Options/dropdown/stdyear.dart';
import 'package:project/screen/Student/document_router.dart';
import 'package:project/screen/Student/subject_table.dart';

class PerformanceForm extends StatefulWidget {
  const PerformanceForm({super.key});
  @override
  State<PerformanceForm> createState() => _PerformanceFormState();
}

class _PerformanceFormState extends State<PerformanceForm> {
  final List<MemberData> members = [MemberData()];

  @override
  void initState() {
    super.initState();
    for (var m in members) {
      m.ready.addListener(_onReadyChanged);
    }
  }

  bool get _canSubmitAll {
    // ตรวจว่าฟิลด์พื้นฐานครบ (ready) และ ตารางวิชาทุกคนกรอกครบ
    return members.every((m) {
      if (!m.ready.value) return false;
      // ตรวจ savedSubjectDetails ต้องมีเท่ากับ totalItems ของแต่ละคน
      if (m.savedSubjectDetails.length < m.totalItems) return false;
      // ทุก detail ต้องไม่มีค่า null
      for (final detail in m.savedSubjectDetails.values) {
        if (detail.values.any((v) => v == null)) return false;
      }
      // GPA ต้องกรอก
      if (m.gpaController.text.isEmpty) return false;
      return true;
    });
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
    for (var m in members) {
      // 1) อัพเดตข้อมูลนักศึกษา
      final updateBody = {
        "student": [
          {
            "s_id": m.studentIdController.text,
            "overall_grade": m.gpaController.text,
            "branch": int.parse(m.course!),
            "course": int.parse(m.courseYear!),
            "semester": getTermIdFromName(m.semester),
            "year": int.parse(m.year!),
          },
        ],
      };
      await http.put(
        Uri.parse('$baseUrl/api/student/update'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updateBody),
      );

      // 2) เพิ่มรายวิชา
      final subjectList =
          m.savedSubjectDetails.entries.map((e) {
            return {
              "subject_id": int.parse(e.key),
              "term_id": getTermIdFromName(e.value["semester"]),
              "year": int.parse(e.value["year"]),
              "grade": getGradeIdFromCode(e.value["grade"]),
            };
          }).toList();
      final createBody = {
        "student": [
          {"s_id": m.studentIdController.text, "subject": subjectList},
        ],
      };
      await http.post(
        Uri.parse('$baseUrl/api/student/create/subject'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(createBody),
      );
    }

    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: 'สำเร็จ',
      desc: 'ส่งข้อมูลสมาชิกทั้งหมดเรียบร้อยแล้ว',
      btnOkOnPress: () {},
      btnOkColor: Colors.green,
    ).show();
  }

  void _onReadyChanged() {
    // เรียก setState เพียงครั้งเดียว
    setState(() {});
  }

  void _addMember() {
    if (members.length >= 3) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.topSlide,
        title: 'ไม่สามารถเพิ่มได้',
        desc: 'เพิ่มสมาชิกได้สูงสุด 3 คน',
        btnOkOnPress: () {},
      ).show();
      return;
    }
    final m = MemberData();
    m.ready.addListener(_onReadyChanged);
    setState(() => members.add(m));
  }

  void _removeMember(int idx) {
    members[idx].ready.removeListener(_onReadyChanged);
    setState(() => members.removeAt(idx));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ฟอร์มหลายสมาชิก (สูงสุด 3 คน)"),
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
                  label: const Text("เพิ่มสมาชิก"),
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
                      MemberForm(data: d),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _canSubmitAll ? _submitAll : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSubmitAll ? Colors.green : Colors.grey,
              ),
              child: const Text("ส่งแบบฟอร์มทั้งหมด"),
            ),
          ],
        ),
      ),
    );
  }
}

class MemberData {
  String? course, courseYear, prefix, semester, year;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final studentIdController = TextEditingController();
  final ready = ValueNotifier<bool>(false);
  int currentOffset = 0;
  int totalItems = 0;
  Map<String, Map<String, dynamic>> savedSubjectDetails = {};
  final TextEditingController gpaController = TextEditingController();

  void dispose() {
    gpaController.dispose();
  }
}

class MemberForm extends StatefulWidget {
  final MemberData data;
  const MemberForm({super.key, required this.data});
  @override
  State<MemberForm> createState() => _MemberFormState();
}

class _MemberFormState extends State<MemberForm> {
  void _updateReady() {
    final d = widget.data;
    final valid =
        d.course != null &&
        d.courseYear != null &&
        d.prefix != null &&
        d.semester != null &&
        d.year != null &&
        d.firstNameController.text.isNotEmpty &&
        d.lastNameController.text.isNotEmpty &&
        d.studentIdController.text.isNotEmpty;
    widget.data.ready.value = valid;
  }

  @override
  void initState() {
    super.initState();
    // ฟังการเปลี่ยน text
    widget.data.firstNameController.addListener(_updateReady);
    widget.data.lastNameController.addListener(_updateReady);
    widget.data.studentIdController.addListener(_updateReady);
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
                setState(() => widget.data.course = v);
                print("Course: ${widget.data.course}");
                _updateReady();
              },
            ),
            const SizedBox(width: 20),
            const Text("ปีหลักสูตร:"),
            const SizedBox(width: 10),
            CourseYearDropdown(
              value: widget.data.courseYear,
              onCourseYearChanged: (v) {
                setState(() => widget.data.courseYear = v);
                _updateReady();
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
            Row(
              children: [
                const Text("คำนำหน้า: "),
                const SizedBox(width: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: PrefixDropdown(
                    value: widget.data.prefix,
                    onPrefixChanged: (v) {
                      setState(() => widget.data.prefix = v);
                      _updateReady();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: widget.data.firstNameController,
                decoration: InputDecoration(
                  labelText: 'ชื่อ',
                  labelStyle: GoogleFonts.prompt(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: widget.data.lastNameController,
                decoration: const InputDecoration(
                  labelText: 'นามสกุล',
                  labelStyle: TextStyle(fontSize: 12),
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: widget.data.studentIdController,
                decoration: const InputDecoration(
                  labelText: 'รหัสนักศึกษา',
                  labelStyle: TextStyle(fontSize: 12),
                ),
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
                  setState(() => widget.data.semester = v);
                  _updateReady();
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
                  setState(() => widget.data.year = v);
                  _updateReady();
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
          selectedPrefix: widget.data.prefix,
          selectedSemester: widget.data.semester,
          selectedYear: widget.data.year,
          onGradeValidationChanged: (valid) {
            _updateReady();
          },
          memberData: widget.data,
        ),
      ],
    );
  }
}
