import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/screen/Form/Form_Options/TextFeild/customTextFeild.dart';
import 'package:project/API/api_config.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourse.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourseYear.dart'; // ✅ เพิ่มบรรทัดนี้

class Editsubject extends StatefulWidget {
  final int id_subject;
  final String courseCode;
  final String name_subjects;
  final String curriculumYear;
  final int department;

  const Editsubject({
    Key? key,
    required this.id_subject,
    required this.courseCode,
    required this.name_subjects,
    required this.curriculumYear,
    required this.department,
  }) : super(key: key);

  @override
  _EditsubjectState createState() => _EditsubjectState();
}

class _EditsubjectState extends State<Editsubject> {
  late TextEditingController _courseCodeController;
  late TextEditingController _courseNameController;
  String? selectedCourseYear;
  int? selectedDepartment;
  Map<String, int> branchMap = {};
  List<String> courseYears = ["2560", "2565"];

  @override
  void initState() {
    super.initState();
    _courseCodeController = TextEditingController(text: widget.courseCode);
    _courseNameController = TextEditingController(text: widget.name_subjects);
    selectedCourseYear = widget.curriculumYear; // ตั้งค่าเริ่มต้นปีหลักสูตร
    selectedDepartment = widget.department; // ตั้งค่าเริ่มต้นหลักสูตร
    _loadBranches(); // โหลดข้อมูลหลักสูตร
  }

  Future<void> _updateSubject() async {
    final Map<String, dynamic> updatedData = {
      'id_subject': widget.id_subject, // สำคัญมาก ต้องส่งไปด้วย
      'course_code': _courseCodeController.text,
      'name_subjects': _courseNameController.text,
      'year_course_sub': selectedCourseYear,
      'id_branch': selectedDepartment,
    };

    final response = await http.put(
      Uri.parse("$baseUrl/api/subjects/${widget.id_subject}"), // ✅ แก้ URL
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );

    if (response.statusCode == 200) {
      print("Subject updated successfully");
      final Map<String, dynamic> responseData = json.decode(response.body);
      print("Updated subject data: $responseData");
      Navigator.pop(context, true);
    } else {
      print("Failed to update subject. Status: ${response.statusCode}");
    }
  }

  Future<void> _deleteSubject() async {
    final response = await http.delete(
      Uri.parse("$baseUrl/api/subjects/${widget.id_subject}"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("Subject deleted successfully");
      Navigator.pop(context, true);
    } else {
      print("Failed to delete subject. Status: ${response.statusCode}");
    }
  }

  Future<void> _loadBranches() async {
    final response = await http.get(Uri.parse("$baseUrl/api/branches"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        branchMap = {
          for (var item in data)
            item['id_branch'].toString(): item['name_branch'],
        };
      });
    } else {
      print("Failed to load branches. Status: ${response.statusCode}");
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text("ยืนยันการลบ"),
                content: Text("คุณแน่ใจหรือไม่ว่าต้องการลบรายวิชานี้?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("ยกเลิก"),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text("ลบ"),
                  ),
                ],
              ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("แก้ไขรายวิชา"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextField(
              controller: _courseCodeController,
              label: "รหัสวิชา",
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? "กรุณากรอกรหัสวิชา"
                          : null,
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: _courseNameController,
              label: "ชื่อวิชา",
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? "กรุณากรอกชื่อวิชา"
                          : null,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text("หลักสูตร :"),
                SizedBox(width: 10),
                // ใช้ CourseDropdown
                CourseDropdown(
                  onCourseChanged: (newBranch) {
                    setState(() {
                      selectedDepartment = int.tryParse(newBranch ?? '0');
                    });
                  },
                  value: selectedDepartment?.toString(), // ใช้ค่าเริ่มต้น
                ),
                Text("ปีหลักสูตร :"),
                SizedBox(width: 10),
                // ใช้ CourseYearDropdown
                CourseYearDropdown(
                  onCourseYearChanged: (newYear) {
                    setState(() {
                      selectedCourseYear = newYear;
                    });
                  },
                  value: selectedCourseYear, // ใช้ค่าเริ่มต้น
                ),
                SizedBox(height: 20),
              ],
            ),

            SizedBox(height: 20),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _updateSubject,
                    child: Text("Update Subject"),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () async {
                      bool confirmDelete =
                          await _showDeleteConfirmationDialog();
                      if (confirmDelete) {
                        _deleteSubject();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text("Delete"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
