import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/student_performance.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Form/Form_Options/File/fileupload.dart';
import 'package:project/screen/Form/Form_Options/dropdown/semester.dart';
import 'package:project/screen/Form/Form_Options/dropdown/stdyear.dart';
import 'package:project/screen/Student/document_router.dart';

class RequestGroup extends StatefulWidget {
  final List<int> studentIds;

  const RequestGroup({super.key, required this.studentIds});

  @override
  State<RequestGroup> createState() => _RequestGroupState();
}

class _RequestGroupState extends State<RequestGroup> {
  String? selectedSemester;
  String? selectedYear;
  late List<int> studentIds;
  PlatformFile? selectedFile;

  List<String> availableSemesters = [];
  List<String> availableYears = [];

  @override
  void initState() {
    super.initState();
    studentIds = widget.studentIds;
    _fetchAndSetSemesterYearFromStudent();
  }

  Future<void> _fetchAndSetSemesterYearFromStudent() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/check/group-all-subjects'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(studentIds), // ส่ง List<int> ตรงๆ
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as List;

        // เก็บ semester/year ที่พบทั้งหมด
        Set<String> semesters = {};
        Set<String> years = {};

        for (var student in decoded) {
          final headInfo = student['head_info'];
          if (headInfo != null) {
            semesters.add(headInfo['term_name'] ?? '');
            years.add(headInfo['year']?.toString() ?? '');
          }
        }

        setState(() {
          availableSemesters = semesters.where((e) => e.isNotEmpty).toList();
          availableYears = years.where((e) => e.isNotEmpty).toList();

          // กำหนดค่าเริ่มต้นเป็นค่าแรกถ้ามี
          if (availableSemesters.isNotEmpty)
            selectedSemester = availableSemesters[0];
          if (availableYears.isNotEmpty) selectedYear = availableYears[0];
        });
      } else {
        throw Exception("โหลดข้อมูลนักศึกษาไม่สำเร็จ");
      }
    } catch (e) {
      print("เกิดข้อผิดพลาดในการดึงข้อมูล semester/year: $e");
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                children: [
                  const Text("ภาคการศึกษา :"),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedSemester,
                      isExpanded:
                          true, // เพิ่มค่านี้เพื่อให้ dropdown ขยายเต็มพื้นที่
                      items:
                          availableSemesters
                              .map(
                                (sem) => DropdownMenuItem(
                                  value: sem,
                                  child: Text(
                                    sem,
                                    style: GoogleFonts.prompt(fontSize: 14),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSemester = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20), // เพิ่มพื้นที่ว่างระหว่าง dropdown
                  const Text("ปีการศึกษา :"),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      value: selectedYear,
                      isExpanded: true,
                      items:
                          availableYears.map((year) {
                            return DropdownMenuItem<String>(
                              value: year,
                              child: Text(
                                year,
                                style: GoogleFonts.prompt(fontSize: 14),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
                indent: 20,
                endIndent: 20,
              ),
              GroupSubjectTable(studentIds: studentIds),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              const Text(
                "แนบไฟล์เอกสาร",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              FileUploadWidget(
                initialFile: selectedFile,
                onFilePicked: (file) {
                  setState(() {
                    selectedFile = file;
                  });
                },
              ),

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
                style: TextStyle(color: Colors.red, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupSubjectTable extends StatefulWidget {
  final List<int> studentIds;

  const GroupSubjectTable({super.key, required this.studentIds});

  @override
  State<GroupSubjectTable> createState() => _GroupSubjectTableState();
}

class _GroupSubjectTableState extends State<GroupSubjectTable> {
  late Future<void> _loadingFuture;
  List<StudentGradeGroup> studentGrades = [];
  Map<String, double> gradeMap = {}; // grade_code -> grade_point

  @override
  void initState() {
    super.initState();
    _loadingFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    final gradesResponse = await http.get(Uri.parse('$baseUrl/api/grades'));
    final studentResponse = await http.post(
      Uri.parse('$baseUrl/api/check/group-all-subjects'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(widget.studentIds),
    );

    if (gradesResponse.statusCode == 200 && studentResponse.statusCode == 200) {
      final gradesJson =
          jsonDecode(utf8.decode(gradesResponse.bodyBytes)) as List;
      final studentJson =
          jsonDecode(utf8.decode(studentResponse.bodyBytes)) as List;

      gradeMap = {
        for (var g in gradesJson)
          g['grade_code']: (g['grade_point'] as num).toDouble(),
      };

      studentGrades =
          studentJson
              .where(
                (e) =>
                    e['subject_grades'] != null &&
                    (e['subject_grades'] as List).isNotEmpty &&
                    e['head_info'] != null &&
                    (e['head_info'] as Map).isNotEmpty,
              )
              .map((e) => StudentGradeGroup.fromJson(e))
              .toList();
    } else {
      throw Exception('โหลดข้อมูลไม่สำเร็จ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadingFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        } else if (studentGrades.isEmpty) {
          return Center(
            child: Text(
              '* กรุณาทำ แบบตรวจสอบคุณสมบัติในการมีสิทธิ์ขอจัดทำโครงงานปริญญานิพนธ์ (IT00G / CS00G) ก่อน',
              style: GoogleFonts.prompt(fontSize: 14, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          );
        }

        // ✅ คำนวณคะแนนรวมแต่ละคน และเฉลี่ยกลุ่ม
        final List<double> individualScores = [];

        for (var student in studentGrades) {
          final totalScore = student.subjectGrades.fold<double>(0.0, (
            sum,
            subject,
          ) {
            final gradePoint = gradeMap[subject.gradeCode] ?? 0.0;
            const credit = 4.0; // ยังไม่มี field จริง
            return sum + (gradePoint * credit);
          });
          individualScores.add(totalScore);
        }

        final totalAll = individualScores.fold(0.0, (a, b) => a + b);
        final averageGroupScore = totalAll / individualScores.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ แสดงคะแนนเฉลี่ยของกลุ่ม
            Card(
              color: Colors.lightBlue[50],
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "คะแนนเฉลี่ยของกลุ่ม: ${averageGroupScore.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // ✅ แสดงรายคนนักศึกษา
            ...List.generate(studentGrades.length, (index) {
              final student = studentGrades[index];
              final totalScore = individualScores[index];

              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${student.firstName} ${student.lastName} (${student.codeStudent})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'คะแนนรวม: ${totalScore.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    ' ภาคเรียน ${student.termName} ปีการศึกษา ${student.year}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  children: [
                    DataTable(
                      columns: [
                        DataColumn(
                          label: Text(
                            'รหัสวิชา - ชื่อวิชา',
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'คะแนน',
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                      ],
                      rows:
                          student.subjectGrades.map((subject) {
                            final gradePoint =
                                gradeMap[subject.gradeCode] ?? 0.0;
                            return DataRow(
                              cells: [
                                DataCell(
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: Text(
                                      subject.subjectName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 8),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text((gradePoint * 4).toStringAsFixed(2)),
                                ),
                              ],
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
