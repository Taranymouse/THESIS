import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Semester extends StatelessWidget {
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const Semester({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    this.items = const ['ต้น', 'ปลาย', 'ฤดูร้อน'],
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButton<String>(
        hint: Text("ภาคการศึกษา", style: GoogleFonts.prompt(fontSize: 10)),
        value: selectedValue,
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item , style: GoogleFonts.prompt(fontSize: 16 , fontWeight: FontWeight.w600)));
            }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        alignment: Alignment.center,
        dropdownColor: Colors.white,
      ),
    );
  }
}
