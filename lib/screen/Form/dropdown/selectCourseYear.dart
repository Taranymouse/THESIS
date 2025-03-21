import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseYearDropdown extends StatefulWidget {
  final Function(String?) onCourseYearChanged; // เพิ่มตัวแปรนี้เพื่อส่งค่ากลับไป

  const CourseYearDropdown({Key? key, required this.onCourseYearChanged}) : super(key: key);

  @override
  _CourseYearDropdownState createState() => _CourseYearDropdownState();
}

class _CourseYearDropdownState extends State<CourseYearDropdown> {
  String? selectedCourseYear;

  List<String> _getAvailableCourseYears() {
    return ["2560", "2565"];  // ปีที่มีในฐานข้อมูล
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          DropdownButton<String>(
            hint: Text(
              "เลือกปีหลักสูตร",
              style: GoogleFonts.prompt(fontSize: 10),
            ),
            value: selectedCourseYear,
            isExpanded: true,
            items: _getAvailableCourseYears().map((year) {
              return DropdownMenuItem<String>(
                value: year,
                child: Text(
                  year,
                  style: GoogleFonts.prompt(fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedCourseYear = newValue;
              });
              widget.onCourseYearChanged(newValue); // ส่งค่ากลับ
            },
          ),
        ],
      ),
    );
  }
}
