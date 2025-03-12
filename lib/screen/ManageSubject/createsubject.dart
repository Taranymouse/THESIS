import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:project/bloc/Course/course_bloc.dart';
import 'package:project/bloc/CourseYear/courseyear_bloc.dart';
import 'package:project/screen/Form/TextFeild/customTextFeild.dart';
import 'package:project/screen/Form/dropdown/course.dart';
import 'package:project/screen/Form/dropdown/courseyear.dart';

class Createsubject extends StatefulWidget {
  Createsubject({super.key});

  @override
  _CreatesubjectState createState() => _CreatesubjectState();
}

class _CreatesubjectState extends State<Createsubject> {
  final courseCode = TextEditingController();
  final courseName = TextEditingController();
  String? courseYear;
  String? idBranch;
  Map<String, int> branchMap = {}; // แผนที่เก็บชื่อสาขากับ id_branch

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadBranches(); // เรียกข้อมูลสาขาเมื่อเริ่มต้น
  }

  Future<void> _loadBranches() async {
    final response = await http.get(
      Uri.parse("http://192.168.1.117:8000/branches"),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        // สร้างแผนที่ของชื่อสาขา (name_branch) และ id_branch
        branchMap = {
          for (var item in data) item['name_branch']: item['id_branch'],
        };
        // print("Branches loaded: $branchMap");
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

                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("หลักสูตร :"),
                    SizedBox(width: 10),
                    Expanded(
                      child: BlocBuilder<CourseBloc, CourseState>(
                        builder: (context, state) {
                          String? selected =
                              (state is CourseChanged)
                                  ? state.selectedCourse
                                  : null;
                          return Course(
                            selectedValue: selected,
                            onChanged: (newValue) {
                              setState(() {
                                idBranch = newValue;
                              });
                              context.read<CourseBloc>().add(
                                CourseSelected(newValue),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    Text("ปีหลักสูตร :"),
                    Expanded(
                      child: BlocBuilder<CourseyearBloc, CourseyearState>(
                        builder: (context, state) {
                          String? selected =
                              (state is CourseyearChanged)
                                  ? state.selectedCourseyear
                                  : null;
                          return Courseyear(
                            selectedValue: selected,
                            onChanged: (newValue) {
                              setState(() {
                                courseYear = newValue; // เก็บปีหลักสูตร
                              });
                              context.read<CourseyearBloc>().add(
                                CourseyearSelected(newValue),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // ตรวจสอบว่า idBranch ไม่เป็น null
                      if (idBranch != null &&
                          courseYear != null &&
                          branchMap.containsKey(idBranch)) {
                        // หา id_branch จาก name_branch
                        int departmentId = branchMap[idBranch!]!;

                        // สร้าง payload สำหรับส่งไปที่ API
                        var payload = {
                          'courseCode': courseCode.text, // course_code
                          'courseName': courseName.text, // course_name
                          'curriculumYear': courseYear, // curriculum_year
                          'department':
                              departmentId, // ใช้ id_branch ที่แปลงแล้ว
                        };

                        print("📡 Payload: $payload");

                        // ตัวอย่างการเรียก API
                        final response = await http.post(
                          Uri.parse('http://192.168.1.117:8000/subjects'),
                          headers: {'Content-Type': 'application/json'},
                          body: jsonEncode(payload),
                        );

                        if (response.statusCode == 200) {
                          // แสดงผลเมื่อสร้างสำเร็จ
                          print("✅ Subject created successfully!");
                        } else {
                          // แสดงผลเมื่อเกิดข้อผิดพลาด
                          print(
                            "❌ Failed to create subject. Status: ${response.statusCode}",
                          );
                        }
                      } else {
                        print("❌ Invalid branch selected.");
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
