import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CourseYearDropdown extends StatefulWidget {
  final Function(String?) onCourseYearChanged;
  final String? value; // เพิ่มพารามิเตอร์สำหรับค่าเริ่มต้น

  const CourseYearDropdown({
    Key? key,
    required this.onCourseYearChanged,
    this.value,
  }) : super(key: key);

  @override
  _CourseYearDropdownState createState() => _CourseYearDropdownState();
}

class _CourseYearDropdownState extends State<CourseYearDropdown> {
  String? selectedCourseYear;

  @override
  void didUpdateWidget(covariant CourseYearDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        selectedCourseYear = widget.value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedCourseYear = widget.value; // ตั้งค่าเริ่มต้น
  }

  List<String> _getAvailableCourseYears() {
    return ["2560", "2565"]; // ปีที่มีในฐานข้อมูล
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          DropdownButton<String>(
            hint: Text(" - เลือก -", style: GoogleFonts.prompt(fontSize: 10)),
            value: selectedCourseYear,
            isExpanded: true,
            items:
                _getAvailableCourseYears().map((year) {
                  return DropdownMenuItem<String>(
                    value: year,
                    child: Text(year, style: GoogleFonts.prompt(fontSize: 15)),
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
