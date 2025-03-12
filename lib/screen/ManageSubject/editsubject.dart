import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project/screen/Form/TextFeild/customTextFeild.dart';

class Editsubject extends StatefulWidget {
  final int subjectId;
  final String courseCode;
  final String courseName;
  final String curriculumYear;
  final int department;

  const Editsubject({
    Key? key,
    required this.subjectId,
    required this.courseCode,
    required this.courseName,
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
    _courseNameController = TextEditingController(text: widget.courseName);
    selectedCourseYear = widget.curriculumYear;
    selectedDepartment = widget.department;
    _loadBranches();
  }

  Future<void> _updateSubject() async {
    final Map<String, dynamic> updatedData = {
      'courseCode': _courseCodeController.text,
      'curriculumYear': selectedCourseYear,
      'department': selectedDepartment,
      'courseName': _courseNameController.text,
    };

    final response = await http.put(
      Uri.parse("http://192.168.1.117:8000/subjects/${widget.subjectId}"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedData),
    );

    if (response.statusCode == 200) {
      print("Subject updated successfully");
      final Map<String, dynamic> responseData = json.decode(response.body);
      print("Updated subject data: $responseData");
      Navigator.pop(context);
    } else {
      print("Failed to update subject. Status: ${response.statusCode}");
    }
  }

  Future<void> _deleteSubject() async {
    final response = await http.delete(
      Uri.parse("http://192.168.1.117:8000/subjects/${widget.subjectId}"),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      print("Subject deleted successfully");
      Navigator.pop(context);
    } else {
      print("Failed to delete subject. Status: ${response.statusCode}");
    }
  }

  Future<void> _loadBranches() async {
    final response = await http.get(
      Uri.parse("http://192.168.1.117:8000/branches"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        branchMap = {
          for (var item in data) item['name_branch']: item['id_branch'],
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
          // mainAxisAlignment: MainAxisAlignment.center,
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

            // Dropdown สำหรับเลือกปีหลักสูตร
            DropdownButtonFormField<String>(
              value: selectedCourseYear,
              decoration: InputDecoration(labelText: "ปีหลักสูตร"),
              items:
                  courseYears.map((year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(year),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCourseYear = newValue;
                });
              },
            ),
            SizedBox(height: 20),

            // Dropdown สำหรับเลือกหลักสูตร
            DropdownButtonFormField<int>(
              value: selectedDepartment,
              decoration: InputDecoration(labelText: "หลักสูตร"),
              items:
                  branchMap.entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.value,
                      child: Text(entry.key),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedDepartment = newValue;
                });
              },
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
