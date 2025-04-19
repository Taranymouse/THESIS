import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class YearDropdown extends StatefulWidget {
  final Function(String?) onYearChanged;
  final String? value;

  const YearDropdown({Key? key, required this.onYearChanged, this.value}) : super(key: key);

  @override
  _YearDropdownState createState() => _YearDropdownState();
}

class _YearDropdownState extends State<YearDropdown> {
  String? selectedYear;
  List<String> years = [];

  @override
  void initState() {
    super.initState();
    selectedYear = widget.value;
    _generateYears();
  }

  void _generateYears() {
    final currentYear = DateTime.now().year + 543; // แปลงเป็นปี พ.ศ.
    // สร้าง list ปี พ.ศ. ย้อนหลัง 4 ปี รวมปีปัจจุบัน (5 ปีรวมกัน)
    years = List.generate(5, (index) => (currentYear - index).toString());
    // ถ้า selectedYear ไม่มีใน list ให้รีเซ็ตเป็น null
    if (!years.contains(selectedYear)) {
      selectedYear = null;
      widget.onYearChanged(null);
    }
  }

  @override
  void didUpdateWidget(covariant YearDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        selectedYear = widget.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (years.isEmpty)
          Text(
            "ไม่มีข้อมูลปี",
            style: GoogleFonts.prompt(fontSize: 10),
          )
        else
          DropdownButton<String>(
            hint: Text(
              "- เลือกปีการศึกษา -",
              style: GoogleFonts.prompt(fontSize: 14),
            ),
            value: selectedYear,
            isExpanded: true,
            items: years.map((year) {
              return DropdownMenuItem<String>(
                value: year,
                child: Text(
                  year,
                  style: GoogleFonts.prompt(fontSize: 16),
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedYear = newValue;
              });
              widget.onYearChanged(newValue);
            },
          ),
      ],
    );
  }
}
