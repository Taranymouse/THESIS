import 'package:flutter/material.dart';

class Stdyear extends StatelessWidget {
  final List<String> items;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  const Stdyear({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    this.items = const ['2567', '2568'],
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButton(
        hint: Text("ปีการศึกษา",style: TextStyle(fontSize: 10),),
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
