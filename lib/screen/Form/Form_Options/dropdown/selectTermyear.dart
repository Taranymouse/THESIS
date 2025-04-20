import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class YearDropdown extends StatefulWidget {
  final Function(String?) onYearChanged;
  final String? value;

  const YearDropdown({Key? key, required this.onYearChanged, this.value})
    : super(key: key);

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
    final currentYear = DateTime.now().year + 543; // ปี พ.ศ.
    years = List.generate(5, (index) => (currentYear - index).toString());

    if (selectedYear != null) {
      // selectedYear เป็นปี ค.ศ. ต้องแปลงเป็น พ.ศ. เพื่อตรวจสอบใน years
      int selectedYearBuddhist = int.parse(selectedYear!) + 543;
      if (!years.contains(selectedYearBuddhist.toString())) {
        selectedYear = null;
        widget.onYearChanged(null);
      }
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
          Text("ไม่มีข้อมูลปี", style: GoogleFonts.prompt(fontSize: 10))
        else
          DropdownButton<String>(
            hint: Text(
              "- เลือกปีการศึกษา -",
              style: GoogleFonts.prompt(fontSize: 14),
            ),
            value: selectedYear,
            isExpanded: true,
            items:
                years.map((buddhistYear) {
                  // แปลงปี พ.ศ. เป็น ค.ศ.
                  int yearBuddhist = int.parse(buddhistYear);
                  int yearGregorian = yearBuddhist - 543;
                  return DropdownMenuItem<String>(
                    value: yearGregorian.toString(), // ส่งปี ค.ศ.
                    child: Text(
                      buddhistYear, // แสดงปี พ.ศ.
                      style: GoogleFonts.prompt(fontSize: 16),
                    ),
                  );
                }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedYear = newValue;
              });
              widget.onYearChanged(newValue); // ส่งปี ค.ศ.
            },
          ),
      ],
    );
  }
}
