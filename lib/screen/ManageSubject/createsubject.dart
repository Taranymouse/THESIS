import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/bloc/Course/course_bloc.dart';
import 'package:project/bloc/CourseYear/courseyear_bloc.dart';
import 'package:project/screen/Form/Form_Options/TextFeild/customTextFeild.dart';
import 'package:project/screen/Form/Form_Options/dropdown/course.dart';
import 'package:project/screen/Form/Form_Options/dropdown/courseyear.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourse.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourseYear.dart';

class Createsubject extends StatefulWidget {
  Createsubject({super.key});

  @override
  _CreatesubjectState createState() => _CreatesubjectState();
}

class _CreatesubjectState extends State<Createsubject> {
  final courseCode = TextEditingController();
  final courseName = TextEditingController();
  String? selectedCourse; // เก็บค่าหลักสูตรที่เลือก
  String? selectedCourseYear; // เก็บค่าปีหลักสูตรที่เลือก
  Map<String, int> branchMap = {}; // แผนที่เก็บชื่อสาขากับ id_branch


  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadBranches(); // เรียกข้อมูลสาขาเมื่อเริ่มต้น
  }

  Future<void> _loadBranches() async {
    final response = await http.get(Uri.parse("$baseUrl/api/branches"));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        branchMap = {
          for (var item in data)
            item['id_branch'].toString(): item['id_branch'],
        };
      });
    } else {
      print("Failed to load branches. Status: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("สร้างรายวิชา"), centerTitle: true),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: courseCode,
                  label: "รหัสวิชา",
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? "กรุณากรอกรหัสวิชา"
                              : null,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: courseName,
                  label: "ชื่อวิชา",
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? "กรุณากรอกชื่อวิชา"
                              : null,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("หลักสูตร :"),
                    SizedBox(width: 10),
                    Expanded(
                      child: CourseDropdown(
                        onCourseChanged: (newValue) {
                          setState(() {
                            selectedCourse =
                                newValue; // เก็บค่าหลักสูตรที่เลือก
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Text("ปีหลักสูตร :"),
                    Expanded(
                      child: CourseYearDropdown(
                        onCourseYearChanged: (newValue) {
                          setState(() {
                            selectedCourseYear =
                                newValue; // เก็บค่าปีหลักสูตรที่เลือก
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    print("Selected Course: $selectedCourse");
                    print("Selected Course Year: $selectedCourseYear");
                    print("Branch Map: $branchMap");

                    if (_formKey.currentState!.validate()) {
                      if (selectedCourse != null &&
                          selectedCourseYear != null &&
                          branchMap.containsKey(selectedCourse)) {
                        int departmentId = branchMap[selectedCourse!]!;
                        var payload = {
                          'courseCode': courseCode.text,
                          'courseName': courseName.text,
                          'curriculumYear': selectedCourseYear,
                          'department': departmentId,
                        };

                        print("📡 Payload: $payload");

                        final response = await http.post(
                          Uri.parse("$baseUrl/api/subjects"),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(payload),
                        );

                        if (response.statusCode == 200) {
                          print("✅ Subject created successfully!");
                          Navigator.pop(context, true);
                        } else {
                          print(
                            "❌ Failed to create subject. Status: ${response.statusCode}",
                          );
                        }
                      } else {
                        print("❌ Invalid branch or year selected.");
                      }
                    }
                  },
                  child: const Text("บันทึก"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
