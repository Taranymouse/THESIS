import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:project/API/api_config.dart';
import 'package:project/modles/grade_model.dart';
import 'package:project/modles/subject_model.dart';
import 'package:project/screen/Form/Form_Options/File/fileupload.dart';
import 'package:project/screen/Form/Form_Options/dropdown/semester.dart';
import 'package:project/screen/Student/AcademicPerformance/academic_performance.dart';

class SubjectsTable extends StatefulWidget {
  final String? selectedCourse;
  final String? selectedCourseYear;
  final String? selectedSemester;
  final String? selectedYear;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController studentIdController;
  final ValueChanged<bool>? onGradeValidationChanged;
  final MemberData memberData;

  const SubjectsTable({
    super.key,
    required this.selectedCourse,
    required this.selectedCourseYear,
    required this.selectedSemester,
    required this.selectedYear,
    required this.firstNameController,
    required this.lastNameController,
    required this.studentIdController,
    this.onGradeValidationChanged,
    required this.memberData,
  });

  @override
  State<SubjectsTable> createState() => _SubjectsTableState();
}

class _SubjectsTableState extends State<SubjectsTable> {
  List<Subject> subjects = [];
  List<Grade> grades = [];
  List<AcademicTerm> terms = [];
  bool isLoading = true;
  bool isSubmitEnabled = false;
  List<PlatformFile> selectedFiles = [];

  @override
  void initState() {
    super.initState();
    fetchAll();
  }

  Future<void> fetchAll() async {
    await Future.wait([
      fetchSubjects(widget.memberData.currentOffset),
      fetchAcademicTerms(),
      fetchGrades(),
    ]);
    setState(() => isLoading = false);
  }

  Future<void> fetchAcademicTerms() async {
    final res = await http.get(Uri.parse('$baseUrl/api/academic_terms'));
    if (res.statusCode == 200) {
      final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
      terms = list.map((e) => AcademicTerm.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load terms');
    }
  }

  Future<void> fetchGrades() async {
    final res = await http.get(Uri.parse('$baseUrl/api/grades'));
    if (res.statusCode == 200) {
      final list = jsonDecode(utf8.decode(res.bodyBytes)) as List;
      grades = list.map((e) => Grade.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load grades');
    }
  }

  Future<void> fetchSubjects(int offset) async {
    final course = widget.memberData.course;
    final courseYear = widget.memberData.courseYear;
    if (course == null || courseYear == null) {
      setState(() {
        subjects = [];
        isLoading = false;
      });
      checkIfAllFieldsFilled();
      return;
    }
    final res = await http.get(
      Uri.parse(
        '$baseUrl/api/subjects?offset=$offset&limit=10&course=$course&course_year=$courseYear',
      ),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(utf8.decode(res.bodyBytes));
      setState(() {
        subjects =
            (data['data'] as List).map((e) => Subject.fromJson(e)).toList();
        widget.memberData.currentOffset = offset;
        widget.memberData.totalItems = data['pagination']['total'];
        isLoading = false; // 🔥 อัปเดตสถานะ Loading
      });
    } else {
      throw Exception('Failed to load subjects');
    }
    checkIfAllFieldsFilled();
  }

  List<String> _getAvailableCourseYears() {
    final currentYear = DateTime.now().year + 543; // พ.ศ.
    return List.generate(5, (index) => (currentYear - index).toString());
  }

  void _updateSubjectDetail(String id, String field, dynamic val) {
    final map = widget.memberData.savedSubjectDetails;
    map[id] ??= {'semester': null, 'year': null, 'grade': null};
    map[id]![field] = val;
    print("Updated $field for subject $id: $val");
    checkIfAllFieldsFilled();
  }

  bool _validateAllFields() {
    final d = widget.memberData;
    if (d.gpaController.text.isEmpty) return false;
    if (d.savedSubjectDetails.length < widget.memberData.totalItems)
      return false;
    print("จากไฟล์ SubjectTable.dart");
    print("จำนวนรายวิชาที่กรอก: ${d.savedSubjectDetails.length}");
    print("จำนวนรายวิชาทั้งหมด : ${widget.memberData.totalItems}");
    print("เกรดเฉลี่ยรวมที่กรอก : ${d.gpaController.text}");
    for (final detail in d.savedSubjectDetails.values) {
      if (detail.values.any((v) => v == null)) return false;
    }

    return true;
  }

  void checkIfAllFieldsFilled() {
    final isValid = _validateAllFields();
    print("จากไฟล์ SubjectTable.dart");
    print("กรอกข้อมูลครบแล้วใช่ไหม? : $isValid");
    if (isValid != isSubmitEnabled) {
      setState(() {
        isSubmitEnabled = isValid;
        print(" บอกว่ากรอกข้อมูลครบแล้วได้ไหม? : $isSubmitEnabled");
        widget.onGradeValidationChanged?.call(isValid);
      });
    } else {
      widget.onGradeValidationChanged?.call(isSubmitEnabled);
    }
  }

  int countPassedSubjects() {
    int count = 0;
    widget.memberData.savedSubjectDetails.forEach((key, detail) {
      final grade = detail['grade'];
      if (grade != null && grade.isNotEmpty) {
        if (!(grade == 'F' || grade == 'I' || grade == 'W' || grade == 'T')) {
          count++;
        }
      }
    });
    return count;
  }

  int countFailedOrNotRegisteredSubjects() {
    int count = 0;
    widget.memberData.savedSubjectDetails.forEach((key, detail) {
      final grade = detail['grade'];
      if (grade == null ||
          grade.isEmpty ||
          grade == 'F' ||
          grade == 'I' ||
          grade == 'W' ||
          grade == 'T') {
        count++;
      }
    });
    return count;
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

  Future<void> submitStudentData({
    required String studentId,
    required String overallGrade,
    required int branchId,
    required int courseYear, // พ.ศ.
    required int semesterId,
    required int academicYear, // พ.ศ.
    required Map<String, Map<String, dynamic>> savedSubjectDetails,
  }) async {
    try {
      // ---------- 1) ส่งข้อมูลนักศึกษา ----------
      final updateResponse = await http.put(
        Uri.parse('$baseUrl/api/student/update'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student": [
            {
              "s_id": studentId,
              "overall_grade": overallGrade,
              "branch": branchId,
              "course": courseYear, // ส่งเป็น พ.ศ.
              "semester": semesterId,
              "year": academicYear, // ส่งเป็น พ.ศ.
            },
          ],
        }),
      );

      if (updateResponse.statusCode == 200) {
        print("✅ อัปเดตข้อมูลนักศึกษาเรียบร้อยแล้ว");
      } else {
        throw Exception("❌ update ไม่สำเร็จ: ${updateResponse.body}");
      }

      // ---------- 2) สร้างข้อมูลรายวิชา ----------
      final List<Map<String, dynamic>> subjectList = [];

      widget.memberData.savedSubjectDetails.forEach((subjectIdStr, detail) {
        // แปลงปี พ.ศ. เป็น ค.ศ. ก่อนส่ง เพราะ schema Subject.year เป็นปี ค.ศ.
        int yearBuddhist = int.parse(detail["year"].toString());
        int yearGregorian = yearBuddhist;

        subjectList.add({
          "subject_id": int.parse(subjectIdStr),
          "term_id": getTermIdFromName(detail["semester"]),
          "year": yearGregorian,
          "grade": getGradeIdFromCode(detail["grade"]),
        });
      });

      final createSubjectResponse = await http.post(
        Uri.parse('$baseUrl/api/student/create/subject'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "student": [
            {"s_id": studentId, "subject": subjectList},
          ],
        }),
      );

      if (createSubjectResponse.statusCode == 200) {
        print("✅ เพิ่มรายวิชานักศึกษาเรียบร้อยแล้ว");
      } else {
        throw Exception(
          "❌ สร้าง subject ไม่สำเร็จ: ${createSubjectResponse.body}",
        );
      }
    } catch (e) {
      print("❌ เกิดข้อผิดพลาดในการส่งข้อมูล: $e");
    }
  }

  @override
  void didUpdateWidget(SubjectsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCourse != widget.selectedCourse ||
        oldWidget.selectedCourseYear != widget.selectedCourseYear ||
        oldWidget.selectedSemester != widget.selectedSemester ||
        oldWidget.selectedYear != widget.selectedYear ||
        oldWidget.firstNameController.text != widget.firstNameController.text ||
        oldWidget.lastNameController.text != widget.lastNameController.text ||
        oldWidget.studentIdController.text != widget.studentIdController.text) {
      checkIfAllFieldsFilled(); // 🔥 เพิ่มตรงนี้
    }

    if (oldWidget.selectedCourse != widget.selectedCourse ||
        oldWidget.selectedCourseYear != widget.selectedCourseYear) {
      widget.memberData.currentOffset = 0;
      isLoading = true;
      fetchSubjects(widget.memberData.currentOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: LoadingAnimationWidget.horizontalRotatingDots(
          color: Colors.deepPurple,
          size: 50,
        ),
      );
    }

    if (subjects.isEmpty) {
      return Center(child: Text("กรุณาเลือกหลักสูตรและปีหลักสูตร"));
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          "หมายเหตุ : กรุณาตรวจสอบผลการศึกษาจากเว็บระบบบริการการศึกษาของมหาวิทยาลัยด้วย (reg.su.ac.th)",
          style: TextStyle(fontSize: 10, color: Colors.red[400]),
          textAlign: TextAlign.center,
        ),
        DataTable(
          columnSpacing: 25,
          dataRowMinHeight: 40,
          dataRowMaxHeight: 60,
          columns: [
            DataColumn(
              label: Text(
                'รหัสวิชา - ชื่อวิชา',
                style: GoogleFonts.prompt(fontSize: 10),
              ),
            ),
            DataColumn(
              label: Text(
                'ภาคการศึกษา',
                style: GoogleFonts.prompt(fontSize: 10),
              ),
            ),
            DataColumn(
              label: Text(
                'ปีการศึกษา',
                style: GoogleFonts.prompt(fontSize: 10),
              ),
            ),
            DataColumn(
              label: Text('เกรด', style: GoogleFonts.prompt(fontSize: 10)),
            ),
          ],
          rows:
              subjects.map((subject) {
                final id = subject.id_subject.toString();
                final detail =
                    widget.memberData.savedSubjectDetails[id] ??
                    {'semester': null, 'year': null, 'grade': null};
                final isRowFilled =
                    detail['semester'] != null &&
                    detail['year'] != null &&
                    detail['grade'] != null;
                final grade = detail['grade']?.toString() ?? '';
                Color? rowColor;
                if (isRowFilled) {
                  if (grade == 'F' ||
                      grade == 'I' ||
                      grade == 'W' ||
                      grade == 'T') {
                    rowColor = Colors.red[100];
                  } else {
                    rowColor = Colors.green[100];
                  }
                }
                return DataRow(
                  color:
                      rowColor != null
                          ? MaterialStateProperty.all(rowColor)
                          : null,
                  cells: [
                    DataCell(
                      Container(
                        width: 90,
                        child: Text(
                          "${subject.courseCode} - ${subject.name_subjects}",
                          style: GoogleFonts.prompt(fontSize: 8),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    ),
                    DataCell(
                      DropdownButton<String>(
                        value: detail['semester'],
                        hint: Text("-เลือก-", style: TextStyle(fontSize: 10)),
                        items:
                            terms.map((term) {
                              return DropdownMenuItem<String>(
                                value: term.nameTerm,
                                child: Text(
                                  term.nameTerm,
                                  style: GoogleFonts.prompt(fontSize: 10),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _updateSubjectDetail(id, 'semester', value);
                            checkIfAllFieldsFilled();
                          });
                        },
                      ),
                    ),
                    DataCell(
                      DropdownButton(
                        value: detail['year'],
                        hint: Text("-เลือก-", style: TextStyle(fontSize: 10)),
                        items:
                            _getAvailableCourseYears().map((year) {
                              return DropdownMenuItem(
                                value: year,
                                child: Text(
                                  year,
                                  style: GoogleFonts.prompt(fontSize: 10),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _updateSubjectDetail(id, 'year', value);
                            checkIfAllFieldsFilled();
                          });
                        },
                      ),
                    ),
                    DataCell(
                      DropdownButton<String>(
                        value: detail['grade'],
                        hint: Text("-เลือก-", style: TextStyle(fontSize: 10)),
                        items:
                            grades.map((grade) {
                              return DropdownMenuItem(
                                value: grade.code,
                                child: Text(
                                  grade.code,
                                  style: TextStyle(fontSize: 10),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _updateSubjectDetail(id, 'grade', value);
                            checkIfAllFieldsFilled();
                          });
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),

        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed:
                  widget.memberData.currentOffset > 0
                      ? () {
                        setState(() {
                          widget.memberData.currentOffset -= 10;
                          isLoading = true;
                        });
                        fetchSubjects(widget.memberData.currentOffset);
                      }
                      : null,
              child: Text('ก่อนหน้า', style: GoogleFonts.prompt(fontSize: 12)),
            ),
            Text(
              "แสดง ${widget.memberData.currentOffset + 1} - ${widget.memberData.currentOffset + subjects.length} จาก ${widget.memberData.totalItems}",
              style: GoogleFonts.prompt(fontSize: 12),
            ),
            ElevatedButton(
              onPressed:
                  widget.memberData.currentOffset + 10 <
                          widget.memberData.totalItems
                      ? () {
                        setState(() {
                          widget.memberData.currentOffset += 10;
                          isLoading = true;
                        });
                        fetchSubjects(widget.memberData.currentOffset);
                      }
                      : null,
              child: Text('ถัดไป', style: GoogleFonts.prompt(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Column(
          children: [
            const Text(
              " * สำคัญ",
              style: TextStyle(color: Colors.red, fontSize: 8),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                controller: widget.memberData.gpaController,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: "เกรดเฉลี่ยรวม",
                  labelStyle: TextStyle(fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 14,
                  ),
                ),
                onChanged: (value) {
                  checkIfAllFieldsFilled();
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("จำนวนวิชาที่สอบผ่าน :"),
                const SizedBox(width: 10),
                Text(
                  "${countPassedSubjects()}",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("จำนวนวิชาที่สอบผ่านไม่ผ่าน / ยังไม่ลงทะเบียน :"),
                const SizedBox(width: 10),
                Text(
                  "${countFailedOrNotRegisteredSubjects()}",
                  style: TextStyle(
                    color: Colors.red[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "* กรุณา Upload เอกสารผลการศึกษา (transcript)",
              style: TextStyle(fontSize: 12, color: Colors.red[600]),
            ),
            const SizedBox(height: 10),
            FileUploadWidget(
              initialFiles: selectedFiles,
              onFilesPicked: (files) {
                setState(() {
                  selectedFiles = files;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
