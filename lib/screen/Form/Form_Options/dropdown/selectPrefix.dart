import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';

class PrefixDropdown extends StatefulWidget {
  final Function(String?) onPrefixChanged;
  final String? value;

  const PrefixDropdown({Key? key, required this.onPrefixChanged, this.value})
    : super(key: key);

  @override
  _PrefixDropdownState createState() => _PrefixDropdownState();
}

class _PrefixDropdownState extends State<PrefixDropdown> {
  String? selectPrefix;
  List<Map<String, dynamic>> prefix = [];
  bool isLoading = true;
  final SessionService sessionService = SessionService();

  @override
  void initState() {
    super.initState();
    _loadSavedPrefix(); // โหลดค่าที่บันทึกไว้
    _fetchPrefix(); // ดึงข้อมูลจาก API
  }

  Future<void> _loadSavedPrefix() async {
    // 1) รออ่าน int? จริง ๆ มาก่อน
    final int? prefixInt = await sessionService.getPrefix();
    // 2) แปลงเป็น String ถ้ามีค่า
    final String? savedPrefix = prefixInt?.toString();
    setState(() {
      selectPrefix = savedPrefix;
    });
  }

  @override
  void didUpdateWidget(covariant PrefixDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      setState(() {
        selectPrefix = widget.value;
      });
    }
  }

  Future<void> _fetchPrefix() async {
    final response = await http.get(Uri.parse("$baseUrl/api/prefix"));

    if (response.statusCode == 200) {
      final String decodedBody = utf8.decode(response.bodyBytes);
      final List<dynamic> data = jsonDecode(decodedBody);

      setState(() {
        prefix =
            data
                .map(
                  (item) => {
                    'id_prefix': item['id_prefix'],
                    'name_prefix': item['name_prefix'],
                  },
                )
                .toList();
        isLoading = false;

        // ถ้า selectPrefix ไม่มีใน prefix ให้ตั้งเป็น null
        if (!prefix.any((p) => p['id_prefix'].toString() == selectPrefix)) {
          selectPrefix = null;
          widget.onPrefixChanged(null);
        }
      });
    } else {
      throw Exception('Failed to load prefix');
    }
  }

  @override
  Widget build(BuildContext context) {
    // กำหนดค่า value ให้ DropdownButton ให้ตรงกับ items หรือ null
    String? dropdownValue =
        (selectPrefix != null &&
                prefix.any((p) => p['id_prefix'].toString() == selectPrefix))
            ? selectPrefix
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
        else if (prefix.isEmpty)
          Text("ไม่มีข้อมูล", style: GoogleFonts.prompt(fontSize: 10))
        else
          DropdownButton<String>(
            hint: Text(
              "เลือกคำนำหน้า",
              style: GoogleFonts.prompt(fontSize: 10),
            ),
            value: dropdownValue,
            isExpanded: true,
            items:
                prefix.map((p) {
                  return DropdownMenuItem<String>(
                    value: p['id_prefix'].toString(),
                    child: Text(
                      p['name_prefix'],
                      style: GoogleFonts.prompt(fontSize: 16),
                    ),
                  );
                }).toList(),
            onChanged: (newValue) {
              setState(() {
                selectPrefix = newValue;
              });
              widget.onPrefixChanged(newValue);
            },
          ),
      ],
    );
  }
}
