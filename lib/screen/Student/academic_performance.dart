import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/modles/subject_model.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourse.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourseYear.dart';
import 'package:project/screen/home.dart';

class PerformanceForm extends StatefulWidget {
  const PerformanceForm({super.key});

  @override
  State<PerformanceForm> createState() => _PerformanceFormState();
}

class _PerformanceFormState extends State<PerformanceForm> {
  String? selectedCourse;
  String? selectedCourseYear;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController studentIdController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    studentIdController = TextEditingController();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    studentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "แบบตรวจสอบคุณสมบัติในการมีสิทธิ์ขอจัดทำโครงงานปริญญานิพนธ์",
            maxLines: 1,
          ),
        ),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: Homepage()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              DropDownContent(
                selectedCourse: selectedCourse,
                selectedCourseYear: selectedCourseYear,
                onCourseChanged: (value) {
                  setState(() {
                    selectedCourse = value;
                  });
                },
                onCourseYearChanged: (value) {
                  setState(() {
                    selectedCourseYear = value;
                  });
                },
                onResetFilters: () {
                  setState(() {
                    selectedCourse = null;
                    selectedCourseYear = null;
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
              TextFeildContent(
                firstNameController: firstNameController,
                lastNameController: lastNameController,
                studentIdController: studentIdController,
              ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
                indent: 20,
                endIndent: 20,
              ),
              Text(
                "หมายเหตุ : กรุณาแนบผลการศึกษาที่พิมพ์จากเว็บระบบบริการการศึกษาของมหาวิทยาลัยด้วย (reg.su.ac.th)",
                style: TextStyle(fontSize: 10, color: Colors.red[400]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              SubjectsTable(
                key: ValueKey(
                  '${selectedCourse ?? ''}-${selectedCourseYear ?? ''}',
                ),
                selectedCourse: selectedCourse,
                selectedCourseYear: selectedCourseYear,
                firstNameController: firstNameController,
                lastNameController: lastNameController,
                studentIdController: studentIdController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DropDownContent extends StatefulWidget {
  final String? selectedCourse;
  final String? selectedCourseYear;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<String?> onCourseYearChanged;
  final VoidCallback onResetFilters; // เพิ่มฟังก์ชันสำหรับรีเซ็ต
  const DropDownContent({
    super.key,
    required this.selectedCourse,
    required this.selectedCourseYear,
    required this.onCourseChanged,
    required this.onCourseYearChanged,
    required this.onResetFilters, // เพิ่มฟังก์ชันนี้
  });

  @override
  State<DropDownContent> createState() => _DropDownContentState();
}

class _DropDownContentState extends State<DropDownContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("เลือกแบบฟอร์ม"),
        SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("หลักสูตร :"),
            SizedBox(width: 10),
            CourseDropdown(
              value: widget.selectedCourse,
              onCourseChanged: (value) {
                widget.onCourseChanged(value);
              },
            ),
            SizedBox(width: 10),
            Text("ปีหลักสูตร :"),
            SizedBox(width: 10),
            CourseYearDropdown(
              value: widget.selectedCourseYear,
              onCourseYearChanged: (value) {
                widget.onCourseYearChanged(value);
              },
            ),
            SizedBox(width: 5),
            ElevatedButton(
              onPressed: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.warning,
                  animType: AnimType.topSlide,
                  title: 'ยืนยันการล้างข้อมูล',
                  titleTextStyle: GoogleFonts.prompt(fontSize: 16),
                  desc:
                      'คุณแน่ใจหรือไม่ว่าต้องการล้างค่า?\nข้อมูลที่คุณกรอกในตารางจะถูกลบทั้งหมด',
                  btnCancelOnPress: () {
                    // ไม่ทำอะไร ถ้ายกเลิก
                  },
                  btnOkOnPress: () {
                    widget
                        .onResetFilters(); // เรียกฟังก์ชันที่ได้รับจาก Parent widget
                  },
                  btnCancelText: 'ยกเลิก',
                  btnOkText: 'ยืนยัน',
                  btnCancelColor: Colors.grey,
                  btnOkColor: Colors.red,
                ).show();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // ขอบมน
                ),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                fixedSize: Size(20, 20), // ปรับขนาดให้พอดีกับ "X"
              ),
              child: const Text(
                "X",
                style: TextStyle(fontSize: 14),
              ), // ปรับขนาดตัวอักษรให้เหมาะสม
            ),
          ],
        ),
      ],
    );
  }
}

class TextFeildContent extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController studentIdController;

  const TextFeildContent({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.studentIdController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // เพิ่มการจัดแนวให้สวยขึ้น
      children: [
        const Text(
          "รายละเอียดนักศึกษา",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ), // เปลี่ยนขนาดตัวอักษรหัวข้อ
        const SizedBox(height: 10),
        TextFieldContainer(label: "ชื่อ", controller: firstNameController),
        const SizedBox(height: 10),
        TextFieldContainer(label: "นามสกุล", controller: lastNameController),
        const SizedBox(height: 10),
        TextFieldContainer(
          label: "รหัสนักศึกษา",
          controller: studentIdController,
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class TextFieldContainer extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const TextFieldContainer({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:
          MediaQuery.of(context).size.width *
          0.75, // ปรับความกว้างให้พอดีกับหน้าจอ
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14), // ลดขนาดตัวอักษรให้พอดี
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12), // ลดขนาดของข้อความ label
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ), // ลดความโค้งของมุม
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10, // ลดขนาด padding ในแนวตั้ง
            horizontal: 12, // ลดขนาด padding ในแนวนอน
          ),
        ),
      ),
    );
  }
}

class SubjectsTable extends StatefulWidget {
  final String? selectedCourse;
  final String? selectedCourseYear;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController studentIdController;
  const SubjectsTable({
    super.key,
    required this.selectedCourse,
    required this.selectedCourseYear,
    required this.firstNameController,
    required this.lastNameController,
    required this.studentIdController,
  });

  @override
  State<SubjectsTable> createState() => _SubjectsTableState();
}

class _SubjectsTableState extends State<SubjectsTable> {
  List<Subject> subjects = [];
  bool isLoading = true;
  int currentOffset = 0;
  int totalItems = 0;

  Map<String, Map<String, dynamic>> savedSubjectDetails = {};
  final TextEditingController gpaController = TextEditingController();
  bool isSubmitEnabled = false;

  Future<void> fetchSubjects(int offset) async {
    if (widget.selectedCourse == null || widget.selectedCourseYear == null) {
      setState(() {
        subjects = [];
        isLoading = false;
      });
      return;
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
      final List subjectData = data['data'];
      final pagination = data['pagination'];
      List<Subject> fetchedSubjects =
          subjectData.map((item) => Subject.fromJson(item)).toList();
      setState(() {
        subjects = fetchedSubjects;
        totalItems = pagination['total'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
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
        oldWidget.selectedCourseYear != widget.selectedCourseYear) {
      currentOffset = 0;
      isLoading = true;
      fetchSubjects(currentOffset);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSubjects(currentOffset);
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
  }

  int countPassedSubjects() {
    int count = 0;
    savedSubjectDetails.forEach((key, detail) {
      final grade = detail['grade'];
      if (grade != null && grade.isNotEmpty) {
        if (!(grade == 'F' || grade == 'I' || grade == 'W')) {
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
          grade == 'W') {
        count++;
      }
    });
    return count;
  }

  @override
  void dispose() {
    gpaController.dispose();
    super.dispose();
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

    return SizedBox(
      height: 1000,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
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
                  label: Text('ภาคการศึกษา', style: GoogleFonts.prompt(fontSize: 10),),
                ),
                DataColumn(
                  label: Text('ปีการศึกษา', style: GoogleFonts.prompt(fontSize: 10),),
                ),
                DataColumn(label: Text('เกรด', style: GoogleFonts.prompt(fontSize: 10),)),
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
                      if (grade == 'F' || grade == 'I' || grade == 'W') {
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
                            width: 100,
                            child: Text(
                              "${subject.courseCode} - ${subject.name_subjects}",
                              style: GoogleFonts.prompt(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        DataCell(
                          DropdownButton<String>(
                            value: detail['semester'],
                            hint: Text(
                              "-เลือก-",
                              style: TextStyle(fontSize: 10),
                            ),
                            items:
                                ['ต้น', 'ปลาย', 'ฤดูร้อน'].map((semester) {
                                  return DropdownMenuItem(
                                    value: semester,
                                    child: Text(
                                      semester,
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
                          DropdownButton<String>(
                            value: detail['year'],
                            hint: Text(
                              "-เลือก-",
                              style: TextStyle(fontSize: 10),
                            ),
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
                            hint: Text(
                              "-เลือก-",
                              style: TextStyle(fontSize: 10),
                            ),
                            items:
                                [
                                  'A',
                                  'B+',
                                  'B',
                                  'C+',
                                  'C',
                                  'D+',
                                  'D',
                                  'F',
                                  'W',
                                  'I',
                                ].map((grade) {
                                  return DropdownMenuItem(
                                    value: grade,
                                    child: Text(
                                      grade,
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
            SizedBox(height: 20),
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
                  child: Text(
                    'ก่อนหน้า',
                    style: GoogleFonts.prompt(fontSize: 12),
                  ),
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
            SizedBox(height: 20),
            Column(
              children: [
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
                SizedBox(height: 20),
                Text("จำนวนวิชาที่ผ่าน : ${countPassedSubjects()}"),
                Text(
                  "จำนวนวิชาที่ไม่ผ่านผ่าน / ยังไม่ลงทะเบียน : ${countFailedOrNotRegisteredSubjects()}",
                  style: TextStyle(color: Colors.red[400]),
                ),
              ],
            ),
            SizedBox(height: 20),

            if (!isLoading && subjects.isNotEmpty) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final firstName = widget.firstNameController.text.trim();
                  final lastName = widget.lastNameController.text.trim();
                  final studentId = widget.studentIdController.text.trim();
                  final failedSubjects = countFailedOrNotRegisteredSubjects();

                  if (!_validateAllFields()) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                          "กรุณากรอกข้อมูลให้ครบทุกช่องก่อนส่ง",
                        ),
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
                    return;
                  }

                  // ✅ ส่งข้อมูลได้แล้ว
                  print("ส่งข้อมูลแล้วจ้า 🎉");
                  print("Submit pressed!");
                  print("ชื่อ : ${firstName}");
                  print("นามสกุล : ${lastName}");
                  print("รหัสนักศึกษา : ${studentId}");
                  print("เกรดเฉลี่ยรวม : ${gpaController.text}");
                  print("รายละเอียดวิชา: $savedSubjectDetails");
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("ส่งข้อมูลเรียบร้อยแล้ว")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSubmitEnabled ? Colors.blue : Colors.grey,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  "ส่งแบบฟอร์ม",
                  style: GoogleFonts.prompt(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
