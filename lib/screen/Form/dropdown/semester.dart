import 'package:flutter/material.dart';

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
        value: selectedValue,
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }
}
