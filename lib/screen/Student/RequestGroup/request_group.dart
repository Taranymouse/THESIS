import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/student_performance.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Form/Form_Options/File/fileupload.dart';
import 'package:project/screen/Student/RequestGroup/group_subject_table.dart';
import 'package:project/screen/Student/document_router.dart';

class RequestGroup extends StatefulWidget {
  final List<int> studentIds;

  const RequestGroup({super.key, required this.studentIds});

  @override
  State<RequestGroup> createState() => _RequestGroupState();
}

class _RequestGroupState extends State<RequestGroup> {
  late List<int> studentIds;
  List<PlatformFile> selectedFiles = [];

  List<String> availableSemesters = [];
  List<String> availableYears = [];

  @override
  void initState() {
    super.initState();
    studentIds = widget.studentIds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "แบบคำร้องขอเข้ารับการจัดสรรกลุ่มสำหรับการจัดทำโครงงานปริญญานิพนธ์",
        ),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: DocumentRouter()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              GroupSubjectTable(studentIds: studentIds),
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              const Text(
                "แนบไฟล์เอกสาร",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              FileUploadWidget(
                initialFiles: selectedFiles,
                onFilesPicked: (files) {
                  setState(() {
                    selectedFiles = files;
                  });
                },
              ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(height: 10),
              const Text(
                "* กรณีนักศึกษามีอาจารย์ที่ปรึกษาโครงงานแล้วเท่านั้น",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "ชื่ออาจารย์ที่ปรึกษา :",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              const SizedBox(height: 10),
              Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
                indent: 20,
                endIndent: 20,
              ),
              const SizedBox(height: 10),
              const Text(
                "* กรณีนักศึกษายัง ไม่มี อาจารย์ที่ปรึกษาโครงงานเท่านั้น",
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
              const SizedBox(height: 10),
              const Text(
                "ระบุอันดับกลุ่มที่ประสงค์จะเลือก :",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("A กลุ่มดอกมะลิ"),
                  const Text("B กลุ่มดอกแก้ว"),
                  const Text("C กลุ่มดอกพุทธรักษา"),
                  const Text("D กลุ่มดอกเข็ม"),
                  const Text("E กลุ่มดอกดารารัตน์"),
                ],
              ),
              // .. Table สำหรับเลือกกลุ่มโปรเจค
              DataTable(
                columns: [
                  DataColumn(
                    label: Center(
                      child: Text(
                        'อันดับที่',
                        style: GoogleFonts.prompt(fontSize: 10),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Center(
                      child: Text(
                        'กลุ่ม',
                        style: GoogleFonts.prompt(fontSize: 10),
                      ),
                    ),
                  ),
                ],
                rows: [
                  DataRow(
                    cells: [
                      DataCell(
                        Center(
                          child: Text(
                            "1",
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(
                            "A",
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(
                        Center(
                          child: Text(
                            "2",
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(
                            "B",
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(
                        Center(
                          child: Text(
                            "3",
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(
                            "C",
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(
                        Center(
                          child: Text(
                            "4",
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(
                            "D",
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: [
                      DataCell(
                        Center(
                          child: Text(
                            "5",
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                      ),
                      DataCell(
                        Center(
                          child: Text(
                            "E",
                            style: GoogleFonts.prompt(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // ข้อมูลแถวอื่น ๆ ก็ทำแบบเดียวกัน
                ],
              ),

              const SizedBox(height: 20),
              ElevatedButton(onPressed: () {}, child: Text("ส่งแบบฟอร์ม")),
            ],
          ),
        ),
      ),
    );
  }
}
