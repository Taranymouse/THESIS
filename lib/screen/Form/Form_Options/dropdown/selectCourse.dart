import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:project/API/api_config.dart';

class CourseDropdown extends StatefulWidget {
  final Function(String?) onCourseChanged;
  final String? value;

  const CourseDropdown({Key? key, required this.onCourseChanged, this.value})
    : super(key: key);

  @override
  _CourseDropdownState createState() => _CourseDropdownState();
}

class _CourseDropdownState extends State<CourseDropdown> {
  String? selectedCourse;
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;

  @override
  void didUpdateWidget(covariant CourseDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        selectedCourse = widget.value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedCourse = widget.value; // ตั้งค่าเริ่มต้น
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/branches"),
    ); // ✅ ใช้ baseUrl

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        courses =
            data
                .map(
                  (item) => {
                    'name_branch': item['name_branch'],
                    'id_branch': item['id_branch'],
                  },
                )
                .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // TODO: แสดง error message ถ้าต้องการ
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          if (isLoading)
            LoadingAnimationWidget.progressiveDots(
              color: Colors.deepPurple,
              size: 10,
            )
          else if (courses.isEmpty)
            Text("ไม่มีข้อมูลหลักสูตร", style: GoogleFonts.prompt(fontSize: 10))
          else
            DropdownButton<String>(
              hint: Text(
                "- เลือก -",
                style: GoogleFonts.prompt(fontSize: 10),
              ),
              value: widget.value, // ใช้ค่าเริ่มต้น
              isExpanded: true,
              items:
                  courses.map((course) {
                    return DropdownMenuItem<String>(
                      value: course['id_branch'].toString(),
                      child: Text(
                        course['name_branch'],
                        style: GoogleFonts.prompt(fontSize: 16),
                      ),
                    );
                  }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCourse = newValue;
                });
                widget.onCourseChanged(newValue);
              },
            ),
        ],
      ),
    );
  }
}
