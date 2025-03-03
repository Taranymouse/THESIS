import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Course extends StatelessWidget {
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  const Course({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    this.items = const ['IT', 'CS'],
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButton(
        hint: Text("หลักสูตร",style: TextStyle(fontSize: 10),),
        value: selectedValue,
        items:
            items.map((String item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        alignment: Alignment.center,
        dropdownColor: Colors.white,
      ),
    );
  }
}
