import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart'; // เพิ่มการใช้งาน Google Fonts

class CourseDropdown extends StatefulWidget {
  final Function(String?) onCourseChanged; // เพิ่มตัวแปรนี้เพื่อส่งค่ากลับไป

  const CourseDropdown({Key? key, required this.onCourseChanged}) : super(key: key);

  @override
  _CourseDropdownState createState() => _CourseDropdownState();
}

class _CourseDropdownState extends State<CourseDropdown> {
  String? selectedCourse;
  List<Map<String, dynamic>> courses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    final response = await http.get(Uri.parse("http://192.168.1.117:8000/branches"));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        courses = data
            .map((item) => {
                  'name_branch': item['name_branch'],
                  'id_branch': item['id_branch'],
                })
            .toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error (e.g. show a message)
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
            Text(
              "ไม่มีข้อมูลหลักสูตร",
              style: GoogleFonts.prompt(fontSize: 10), // ใช้ฟอนต์ GoogleFonts.prompt
            )
          else
            DropdownButton<String>(
              hint: Text(
                "เลือกหลักสูตร",
                style: GoogleFonts.prompt(fontSize: 10), // ใช้ฟอนต์ GoogleFonts.prompt
              ),
              value: selectedCourse,
              isExpanded: true,
              items: courses.map((course) {
                return DropdownMenuItem<String>(
                  value: course['id_branch'].toString(),
                  child: Text(
                    course['name_branch'],
                    style: GoogleFonts.prompt(fontSize: 16), // ใช้ฟอนต์ GoogleFonts.prompt
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedCourse = newValue;
                });
                widget.onCourseChanged(newValue); // ส่งค่ากลับ
              },
            ),
        ],
      ),
    );
  }
}
