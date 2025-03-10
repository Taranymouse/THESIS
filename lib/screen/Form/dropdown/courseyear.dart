import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Courseyear extends StatelessWidget {
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  const Courseyear({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    this.items = const ['2560', '2565'],
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButton(
        hint: Text("ปีหลักสูตร", style: GoogleFonts.prompt(fontSize: 10)),
        value: selectedValue,
        items:
            items.map((String item) {
              return DropdownMenuItem(value: item, child: Text(item , style: GoogleFonts.prompt(fontSize: 16 , fontWeight: FontWeight.w600)));
            }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        alignment: Alignment.center,
        dropdownColor: Colors.white,
      ),
    );
  }
}
