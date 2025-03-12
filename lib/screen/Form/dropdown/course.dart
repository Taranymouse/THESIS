import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class Course extends StatefulWidget {
  final String? selectedValue;
  final ValueChanged<String?> onChanged;

  const Course({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  _CourseState createState() => _CourseState();
}

class _CourseState extends State<Course> {
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _loadBranch();
  }

  Future<void> _loadBranch() async {
    print("📡 Fetching branches...");

    final response = await http.get(
      Uri.parse("http://192.168.1.117:8000/branches"),
    );

    print("Api response : ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        items =
            data
                .map(
                  (item) => {
                    'name_branch': item['name_branch'],
                    'id_branch': item['id_branch'],
                  },
                )
                .toList();
      });

      print("✅ Branches Loaded: $items");
    } else {
      print("❌ Failed to load branches. Status: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownButton<String>(
        hint: Text("หลักสูตร", style: GoogleFonts.prompt(fontSize: 12)),
        value: widget.selectedValue,
        items:
            items.isNotEmpty
                ? items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item['name_branch'],
                    child: Text(
                      item['name_branch'],
                      style: GoogleFonts.prompt(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList()
                : [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(
                      "ไม่พบข้อมูลหลักสูตร",
                      style: GoogleFonts.prompt(fontSize: 16),
                    ),
                  ),
                ],
        onChanged: (newValue) {
          widget.onChanged(newValue);
        },
        isExpanded: true,
        alignment: Alignment.center,
        dropdownColor: Colors.white,
      ),
    );
  }
}
