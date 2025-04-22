import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:project/API/api_config.dart';
import 'package:project/modles/grade_model.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/modles/subject_model.dart';
import 'package:project/screen/Form/Form_Options/File/fileupload.dart';
import 'package:project/screen/Form/Form_Options/dropdown/semester.dart';
import 'package:project/screen/Student/document_router.dart';

class SubjectsTable extends StatefulWidget {
  final String? selectedCourse;
  final String? selectedCourseYear;
  final String? selectedPrefix;
  final String? selectedSemester;
  final String? selectedYear;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController studentIdController;
  final ValueChanged<bool>? onGradeValidationChanged;

  const SubjectsTable({
    super.key,
    required this.selectedCourse,
    required this.selectedCourseYear,
    required this.selectedPrefix,
    required this.selectedSemester,
    required this.selectedYear,
    required this.firstNameController,
    required this.lastNameController,
    required this.studentIdController,
    this.onGradeValidationChanged,
  });

  @override
  State<SubjectsTable> createState() => _SubjectsTableState();
}

class _SubjectsTableState extends State<SubjectsTable> {
  List<Subject> subjects = [];
  List<Grade> grades = [];
  PlatformFile? selectedFile;
  bool isLoading = true;
  int currentOffset = 0;
  int totalItems = 0;
  Map<String, Map<String, dynamic>> savedSubjectDetails = {};
  final TextEditingController gpaController = TextEditingController();
  bool isSubmitEnabled = false;
  List<AcademicTerm> academicTerms = []; // เพิ่มรายการภาคการศึกษา
  String? selectedCourse;
  String? selectedCourseYear;
  String? selectedPrefix;
  String? selectedSemester;
  String? selectedYear;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController studentIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSubjects(currentOffset);
    fetchAcademicTerms();
    fetchGrades();
  }

  @override
  void dispose() {
    gpaController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    studentIdController.dispose();

    super.dispose();
  }

  Future<void> fetchAcademicTerms() async {
    final response = await http.get(Uri.parse('$baseUrl/api/academic_terms'));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      setState(() {
        academicTerms = jsonList.map((e) => AcademicTerm.fromJson(e)).toList();
      });
    } else {
      throw Exception('Failed to load academic terms');
    }
  }

  Future<List<Subject>> fetchSubjects(int offset) async {
    if (widget.selectedCourse == null || widget.selectedCourseYear == null) {
      setState(() {
        subjects = [];
        isLoading = false;
      });

      // ✅ ตรวจสอบสถานะอีกครั้ง แม้ไม่มีข้อมูล
      checkIfAllFieldsFilled();

      return [];
    }

    final token = await SessionService().getAuthToken();
    final response = await http.get(
      Uri.parse(
        '$baseUrl/api/subjects?offset=$offset&limit=10&course=${widget.selectedCourse}&course_year=${widget.selectedCourseYear}',
      ),
      headers: {"Authorization": "$token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> subjectData = data['data'];
      final pagination = data['pagination'];
      List<Subject> fetchedSubjects =
          subjectData.map((item) => Subject.fromJson(item)).toList();

      setState(() {
        subjects = fetchedSubjects;
        totalItems = pagination['total'];
        isLoading = false;
      });

      // ✅ เรียกหลังโหลดเสร็จ
      checkIfAllFieldsFilled();

      return fetchedSubjects;
    } else {
      setState(() {
        isLoading = false;
      });

      // ✅ เรียกแม้โหลดไม่สำเร็จ
      checkIfAllFieldsFilled();

      throw Exception('ไม่มีข้อมูลวิชา');
    }
  }

  Future<void> fetchGrades() async {
    final response = await http.get(Uri.parse('$baseUrl/api/grades'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      setState(() {
        grades = jsonList.map((e) => Grade.fromJson(e)).toList();
      });
    } else {
      throw Exception('ไม่มีข้อมูลเกรด');
    }
  }

  List<String> _getAvailableCourseYears() {
    final currentYear = DateTime.now().year + 543; // พ.ศ.
    return List.generate(5, (index) => (currentYear - index).toString());
  }

  @override
  void didUpdateWidget(SubjectsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCourse != widget.selectedCourse ||
        oldWidget.selectedCourseYear != widget.selectedCourseYear ||
        oldWidget.selectedPrefix != widget.selectedPrefix ||
        oldWidget.selectedSemester != widget.selectedSemester ||
        oldWidget.selectedYear != widget.selectedYear ||
        oldWidget.firstNameController.text != widget.firstNameController.text ||
        oldWidget.lastNameController.text != widget.lastNameController.text ||
        oldWidget.studentIdController.text != widget.studentIdController.text) {
      checkIfAllFieldsFilled(); // 🔥 เพิ่มตรงนี้
    }

    if (oldWidget.selectedCourse != widget.selectedCourse ||
        oldWidget.selectedCourseYear != widget.selectedCourseYear) {
      currentOffset = 0;
      isLoading = true;
      fetchSubjects(currentOffset);
    }
  }

  void _updateSubjectDetail(String idSubject, String field, dynamic value) {
    setState(() {
      if (!savedSubjectDetails.containsKey(idSubject)) {
        savedSubjectDetails[idSubject] = {
          'semester': null,
          'year': null,
          'grade': null,
        };
      }
      savedSubjectDetails[idSubject]![field] = value;
      print("Updated $field for $idSubject: $value");
      print("Current savedSubjectDetails: $savedSubjectDetails");
      checkIfAllFieldsFilled();
    });
  }

  bool _validateAllFields() {
    if (gpaController.text.isEmpty) return false;
    if (widget.selectedPrefix == null) return false;
    if (widget.firstNameController.text.isEmpty) return false;
    if (widget.lastNameController.text.isEmpty) return false;
    if (widget.studentIdController.text.isEmpty) return false;
    if (widget.selectedSemester == null) return false;
    if (widget.selectedYear == null) return false;
    if (selectedFile == null) return false;

    if (savedSubjectDetails.length < totalItems) return false;

    // เช็ครายละเอียดวิชา
    for (var detail in savedSubjectDetails.values) {
      if (detail['semester'] == null ||
          detail['year'] == null ||
          detail['grade'] == null) {
        return false;
      }
    }

    return true;
  }

  void checkIfAllFieldsFilled() {
    bool allFilled = _validateAllFields();
    setState(() {
      isSubmitEnabled = allFilled;
    });

    // 🔥 ส่งค่าออกไปยังฟอร์มหลัก
    widget.onGradeValidationChanged?.call(allFilled);
  }

  int countPassedSubjects() {
    int count = 0;
    savedSubjectDetails.forEach((key, detail) {
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
    savedSubjectDetails.forEach((key, detail) {
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

      savedSubjectDetails.forEach((subjectIdStr, detail) {
        // แปลงปี พ.ศ. เป็น ค.ศ. ก่อนส่ง เพราะ schema Subject.year เป็นปี ค.ศ.
        int yearBuddhist = int.parse(detail["year"].toString());
        int yearGregorian = yearBuddhist - 543;

        // ตรวจสอบปี Subject.year ให้อยู่ในช่วง ±10 ปี จากปีปัจจุบัน (ค.ศ.)
        final currentYearAD = DateTime.now().year;
        if (yearGregorian < currentYearAD - 10 ||
            yearGregorian > currentYearAD + 10) {
          throw Exception(
            'ปีวิชาไม่อยู่ในช่วงที่อนุญาต: ${currentYearAD - 10} - ${currentYearAD + 10}',
          );
        }

        subjectList.add({
          "subject_id": int.parse(subjectIdStr),
          "term_id": getTermIdFromName(detail["semester"]),
          "year": yearGregorian, // ส่งเป็น ค.ศ.
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
        const Text(
          "* กรุณาอัปโหลดเอกสารใบรับรองผลการศึกษา \n(สามารถดูได้จาก reg.su.ac.th)",
          style: TextStyle(fontSize: 14, color: Colors.red),
          textAlign: TextAlign.center,
        ),
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
              checkIfAllFieldsFilled();
            });
          },
        ),

        const SizedBox(height: 20),
        DataTable(
          columnSpacing: 30,
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
                    savedSubjectDetails[id] ??
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
                            academicTerms.map((term) {
                              return DropdownMenuItem<String>(
                                value: term.nameTerm,
                                child: Text(
                                  term.nameTerm,
                                  style: GoogleFonts.prompt(fontSize: 10),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          _updateSubjectDetail(id, 'semester', value);
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
                          _updateSubjectDetail(id, 'year', value);
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
                          _updateSubjectDetail(id, 'grade', value);
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
        const SizedBox(height: 10),
        Text(
          "หมายเหตุ : กรุณาตรวจสอบผลการศึกษาจากเว็บระบบบริการการศึกษาของมหาวิทยาลัยด้วย (reg.su.ac.th)",
          style: TextStyle(fontSize: 10, color: Colors.red[400]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed:
                  currentOffset > 0
                      ? () {
                        setState(() {
                          currentOffset -= 10;
                          isLoading = true;
                        });
                        fetchSubjects(currentOffset);
                      }
                      : null,
              child: Text('ก่อนหน้า', style: GoogleFonts.prompt(fontSize: 12)),
            ),
            Text(
              "แสดง ${currentOffset + 1} - ${currentOffset + subjects.length} จาก $totalItems",
              style: GoogleFonts.prompt(fontSize: 12),
            ),
            ElevatedButton(
              onPressed:
                  currentOffset + 10 < totalItems
                      ? () {
                        setState(() {
                          currentOffset += 10;
                          isLoading = true;
                        });
                        fetchSubjects(currentOffset);
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
                controller: gpaController,
                style: TextStyle(fontSize: 16),
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
          ],
        ),
        const SizedBox(height: 20),
        if (!isLoading && subjects.isNotEmpty) ...[
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final failedSubjects = countFailedOrNotRegisteredSubjects();

              if (!_validateAllFields()) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("กรุณาเพิ่มข้อมูลให้ครบก่อนส่ง"),
                    action: SnackBarAction(
                      label: "Undo",
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
                return;
              }

              if (!isSubmitEnabled || failedSubjects > 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("คุณมีคุณสมบัติที่ไม่ตรงกับข้อกำหนด"),
                  ),
                );
                Future.delayed(const Duration(seconds: 1), () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                });
                return;
              }

              await submitStudentData(
                studentId: widget.studentIdController.text,
                overallGrade: gpaController.text,
                branchId: int.parse(widget.selectedCourse!),
                courseYear: int.parse(widget.selectedCourseYear!),
                semesterId: getTermIdFromName(widget.selectedSemester),
                academicYear: int.parse(widget.selectedYear!),
                savedSubjectDetails: savedSubjectDetails,
              );

              // ✅ ส่งข้อมูลได้แล้ว
              print("ส่งข้อมูลแล้วจ้า 🎉");
              print("Submit pressed!");
              print(
                "ข้อมูลนักศึกษา: ${widget.selectedPrefix}, ${widget.firstNameController.text} ${widget.lastNameController.text}, ${widget.studentIdController.text}",
              );
              print("ภาคการศึกษา: ${widget.selectedSemester}");
              print("ปีการศึกษา: ${widget.selectedYear}");
              print("เกรดเฉลี่ยรวม : ${gpaController.text}");
              print("รายละเอียดวิชา: $savedSubjectDetails");
              print("ไฟล์ที่แนบ: ${selectedFile?.name}");

              // แทนที่การแสดง SnackBar ด้วย AwesomeDialog
              AwesomeDialog(
                context: context,
                dialogType: DialogType.success,
                animType: AnimType.scale,
                title: 'สำเร็จ',
                titleTextStyle: GoogleFonts.prompt(),
                desc: 'ส่งข้อมูลเรียบร้อยแล้ว',
                btnOkOnPress: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DocumentRouter()),
                  );
                },
                btnOkText: 'ตกลง',
                btnOkColor: Colors.green,
              ).show();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSubmitEnabled ? Colors.green : Colors.grey,
              foregroundColor: Colors.white,
            ),
            child: Text("ส่งแบบฟอร์ม", style: GoogleFonts.prompt(fontSize: 16)),
          ),
        ],
      ],
    );
  }
}
