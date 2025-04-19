import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Stdyear extends StatefulWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const Stdyear({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  State<Stdyear> createState() => _StdyearState();
}

class _StdyearState extends State<Stdyear> {
  late List<String> items;

  @override
  void initState() {
    super.initState();
    items = generateYears();
  }

  List<String> generateYears({int range = 2}) {
    final currentYearAD = DateTime.now().year; // ปี ค.ศ. ปัจจุบัน
    final currentYearBE = currentYearAD + 543; // แปลงเป็น พ.ศ.
    // สร้างลิสต์ปี พ.ศ. ตั้งแต่ปีปัจจุบัน ถึง ปีปัจจุบัน + range
    return List.generate(range + 1, (index) => (currentYearBE + index).toString());
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: Text("-เลือก-", style: GoogleFonts.prompt(fontSize: 8)),
      value: widget.selectedValue,
      items: items.map((year) {
        return DropdownMenuItem<String>(
          value: year,
          child: Text(year, style: GoogleFonts.prompt(fontSize: 12,)),
        );
      }).toList(),
      onChanged: widget.onChanged,
      isExpanded: true,
      alignment: Alignment.center,
      dropdownColor: Colors.white,
    );
  }
}
