import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';

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

  List<String> availableSemesters = [];
  List<String> availableYears = [];

  List<GroupInfo> groupList = []; // กลุ่มที่จะ map
  List<String?> selectedGroups = [];

  List<Professor> professorList = [];
  int? selectedProfessorId;

  @override
  void initState() {
    super.initState();
    studentIds = widget.studentIds;
    initailize(); // เรียกใช้ฟังก์ชัน initailize
  }

  Future<void> initailize() async {
    await fetchGroups();
    await fetchProfessors();
  }

  Future<void> fetchGroups() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/groups/members'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        final filteredData =
            data.where((item) => item['id_group'] != 1).toList();
        filteredData.sort((a, b) => a['id_group'].compareTo(b['id_group']));

        List<String> alphabet = List.generate(
          26,
          (index) => String.fromCharCode(65 + index),
        );

        setState(() {
          groupList = List<GroupInfo>.generate(filteredData.length, (index) {
            final item = filteredData[index];
            final memberList = item['member'] ?? [];
            final hasProfessor = memberList.isNotEmpty;

            return GroupInfo(
              idGroup: item['id_group'],
              groupName:
                  '${alphabet[index]} ${item['group_name']}'
                  '${hasProfessor ? ' (${memberList[0]['professor_name']})' : ' (ยังไม่มีอาจารย์ที่ปรึกษา)'}',
              letter: alphabet[index],
            );
          });

          // ➡️ เพิ่มตรงนี้ เพื่อให้ selectedGroups มีขนาดเท่า groupList
          selectedGroups = List<String?>.filled(groupList.length, null);
        });
      } else {
        print('Failed to fetch groups: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching groups: $e');
    }
  }

  Future<void> fetchProfessors() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/groups/professors'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        setState(() {
          professorList = data.map((item) => Professor.fromJson(item)).toList();
        });
      } else {
        print('Failed to fetch professors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching professors: $e');
    }
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
                  Expanded(
                    child: DropdownButton<int>(
                      value: selectedProfessorId,
                      hint: Text(
                        'เลือกอาจารย์ที่ปรึกษา',
                        style: GoogleFonts.prompt(fontSize: 14),
                      ),
                      isExpanded: true,
                      items:
                          professorList.map((professor) {
                            return DropdownMenuItem<int>(
                              value: professor.idMember,
                              child: Text(
                                professor.fullName,
                                style: GoogleFonts.prompt(fontSize: 12),
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProfessorId = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

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
              // ส่วนตารางเลือกกลุ่ม
              const Text(
                "ระบุอันดับกลุ่มที่ประสงค์จะเลือก :",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              if (groupList.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      groupList.map((group) {
                        return Text(
                          group.groupName,
                          style: GoogleFonts.prompt(fontSize: 14),
                        );
                      }).toList(),
                ),

              const SizedBox(height: 20),
              // ตาราง
              if (groupList.isNotEmpty)
                DataTable(
                  columns: [
                    DataColumn(
                      label: Text('อันดับที่', style: GoogleFonts.prompt()),
                    ),
                    DataColumn(
                      label: Text('กลุ่ม', style: GoogleFonts.prompt()),
                    ),
                  ],
                  rows: List.generate(selectedGroups.length, (index) {
                    return DataRow(
                      cells: [
                        DataCell(Center(child: Text('${index + 1}'))),
                        DataCell(
                          DropdownButton<String>(
                            value: selectedGroups[index],
                            hint: Text(
                              'เลือกกลุ่ม',
                              style: GoogleFonts.prompt(fontSize: 14),
                            ),
                            isExpanded: true,
                            items:
                                groupList.map((group) {
                                  return DropdownMenuItem<String>(
                                    value:
                                        group.letter, // เก็บแค่ตัว A, B, C, D
                                    child: Center(
                                      child: Text('${group.letter}'),
                                    ),
                                  );
                                }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedGroups[index] = value;
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  // TODO: กดส่งแบบฟอร์ม
                },
                child: const Text("ส่งแบบฟอร์ม"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupInfo {
  final int idGroup;
  final String groupName;
  final String letter;

  GroupInfo({
    required this.idGroup,
    required this.groupName,
    required this.letter,
  });
}

class Professor {
  final int idMember;
  final String fullName;

  Professor({required this.idMember, required this.fullName});

  factory Professor.fromJson(Map<String, dynamic> json) {
    return Professor(
      idMember: json['id_member'],
      fullName: '${json['fname']} ${json['lname']}',
    );
  }
}
