import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:project/API/api_config.dart'; // ต้องมี baseUrl อยู่ในนี้

class TermDropdown extends StatefulWidget {
  final Function(String?) onTermChanged;
  final String? value;

  const TermDropdown({Key? key, required this.onTermChanged, this.value})
    : super(key: key);

  @override
  _TermDropdownState createState() => _TermDropdownState();
}

class _TermDropdownState extends State<TermDropdown> {
  String? selectedTerm;
  List<Map<String, dynamic>> terms = [];
  bool isLoading = true;

  @override
  void didUpdateWidget(covariant TermDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        selectedTerm = widget.value;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selectedTerm = widget.value;
    _fetchTerms();
  }

  Future<void> _fetchTerms() async {
    final response = await http.get(Uri.parse("$baseUrl/api/academic_terms"));

    if (response.statusCode == 200) {
      // Decode response.bodyBytes ด้วย utf8.decode เพื่อรองรับภาษาไทย
      final String decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(decodedBody);

      setState(() {
        terms =
            data
                .map(
                  (item) => {
                    'id_term': item['id_term'],
                    'name_term': item['name_term'],
                  },
                )
                .toList();
        isLoading = false;

        // ถ้า selectedTerm ไม่มีใน terms ให้ตั้งเป็น null
        if (!terms.any((term) => term['id_term'].toString() == selectedTerm)) {
          selectedTerm = null;
          widget.onTermChanged(null);
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // TODO: แจ้ง error ถ้าต้องการ
    }
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดค่า value ให้ DropdownButton ให้ตรงกับ items หรือ null
    String? dropdownValue =
        (terms.any((term) => term['id_term'].toString() == selectedTerm))
            ? selectedTerm
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading)
          Center(
            child: LoadingAnimationWidget.progressiveDots(
              color: Colors.deepPurple,
              size: 20,
            ),
          )
        else if (terms.isEmpty)
          Text(
            "ไม่มีข้อมูล",
            style: GoogleFonts.prompt(fontSize: 10),
          )
        else
          DropdownButton<String>(
            hint: Text(
              "- เลือก -",
              style: GoogleFonts.prompt(fontSize: 10),
            ),
            value: dropdownValue,
            isExpanded: true,
            items:
                terms.map((term) {
                  return DropdownMenuItem<String>(
                    value: term['id_term'].toString(),
                    child: Text(
                      term['name_term'],
                      style: GoogleFonts.prompt(fontSize: 16),
                    ),
                  );
                }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectedTerm = newValue;
              });
              widget.onTermChanged(newValue);
            },
          ),
      ],
    );
  }
}
