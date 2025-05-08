import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:project/API/api_config.dart';
import 'package:project/ColorPlate/color.dart';
import 'package:project/modles/session_service.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Form/Form_Options/File/fileupload.dart';
import 'package:project/screen/Student/document_router.dart';

class ProposalExaminationForm extends StatefulWidget {
  const ProposalExaminationForm({super.key});

  @override
  State<ProposalExaminationForm> createState() =>
      _ProposalExaminationFormState();
}

class _ProposalExaminationFormState extends State<ProposalExaminationForm> {
  final SessionService sessionService = SessionService();
  List<Map<String, dynamic>> studentList = [];
  String? termName;
  String? year;
  final TextEditingController thaiTitleController = TextEditingController();
  final TextEditingController engTitleController = TextEditingController();
  List<PlatformFile> uploadedFiles = [];
  String? professor;
  int? selectedAttempt;
  String? selectedChairman;
  String? selectedCommittee1;
  String? selectedCommittee2;
  // final List<String> professors = [];
  // จำลองรายชื่ออาจารย์ (อาจต้องโหลดจาก API จริง)
  final List<String> professors = [
    'ผศ.ดร. ก',
    'ดร. ข',
    'อ. ค',
    'อ. ง',
    'ผศ. จ',
  ];
  bool? isDoCP00R;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeAll();
  }

  @override
  void dispose() {
    thaiTitleController.dispose();
    engTitleController.dispose();
    super.dispose();
  }

  Future<void> initializeAll() async {
    await isDoneFromCP00R();
    if (isDoCP00R == true) {
      await getinfo();
      await getHead();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> isDoneFromCP00R() async {
    final bool dofromg = await sessionService.isDoneFromCP00R();
    isDoCP00R = dofromg;
    print(" isDone : $isDoCP00R");
  }

  Future<void> getHead() async {
    final id_student = await sessionService.getUpdatedStudentIds();

    final response = await http.post(
      Uri.parse('$baseUrl/api/check/group-head-calculate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(id_student),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      print("Data : => $data");

      setState(() {
        studentList = List<Map<String, dynamic>>.from(data);
        if (studentList.isNotEmpty) {
          final headInfo = studentList[0]['head_info'];
          termName = headInfo['term_name'];
          year = headInfo['year'].toString(); // แปลงให้แน่ใจว่าเป็น String
        }
      });
    }
  }

  Future<void> getinfo() async {
    final groupproject = await sessionService.getProjectGroupId();
    final response = await http.get(
      Uri.parse('$baseUrl/api/student/get-group-project-info/$groupproject'),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      print("decode => $decoded");

      final Map<String, dynamic> data = decoded['data'];

      if (data.isNotEmpty) {
        setState(() {
          thaiTitleController.text = data['name_project_th'] ?? '';
          engTitleController.text = data['name_project_en'] ?? '';
          professor = data['professor_name'] ?? '';
        });
      }
    }
  }

  // ฟังชันส่งข้อมูล
  Future<void> submitForm() async {
    if (studentList.isEmpty || uploadedFiles.isEmpty
    // ||
    // selectedAttempt == null ||
    // selectedChairman == null ||
    // selectedCommittee1 == null ||
    // selectedCommittee2 == null
    ) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'แจ้งเตือน',
        desc: 'กรุณากรอกข้อมูลให้ครบถ้วน',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    final groupId = studentList[0]['head_info']['id_group_project'];
    final nameTh = thaiTitleController.text.trim();
    final nameEn = engTitleController.text.trim();

    try {
      // STEP 1: PUT ชื่อโครงงาน
      final nameResponse = await http.put(
        Uri.parse('$baseUrl/api/upload/student/upload-01s'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'id_group_project': groupId.toString(),
          'name_th': nameTh,
          'name_en': nameEn,
        },
      );

      if (nameResponse.statusCode != 200) {
        throw Exception('ไม่สามารถอัปเดตชื่อโครงงานได้');
      }

      // STEP 2: POST ไฟล์ IT01D/CS01D
      final file = uploadedFiles.first;
      final fileBytes = File(file.path!).readAsBytesSync();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/upload/student/upload-02d'),
      );

      request.fields['id_group_project'] = groupId.toString();
      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: file.name),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.rightSlide,
          title: 'สำเร็จ',
          desc: 'ส่งข้อมูลสำเร็จ',
          btnOkOnPress: () {},
        ).show();
      } else {
        throw Exception('อัปโหลดไฟล์ไม่สำเร็จ');
      }
    } catch (e) {
      print('Error: $e');
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.leftSlide,
        title: 'เกิดข้อผิดพลาด',
        desc: 'ไม่สามารถส่งข้อมูลได้',
        btnOkOnPress: () {},
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("แบบคำร้องขอสอบข้อเสนอหัวข้อโครงงานปริญญานิพนธ์"),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: DocumentRouter()),
      ),
      body:
          isLoading
              ? Center(
                child: LoadingAnimationWidget.hexagonDots(
                  color: ColorPlate.colors[6].color,
                  size: 30,
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDoCP00R == true) ...[
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "📋 รายชื่อสมาชิก",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...studentList.asMap().entries.map((entry) {
                                final index = entry.key + 1;
                                final student = entry.value;
                                final info = student['head_info'];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 8,
                                  ), // 👈 เพิ่ม horizontal
                                  child: Container(
                                    width:
                                        double
                                            .infinity, // 👈 ให้ขยายเต็มความกว้าง
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "$index) ${info['first_name']} ${info['last_name']} \nรหัสนักศึกษา ${info['code_student']}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.prompt(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      "มีความประสงค์ที่จะสอบข้อเสนอหัวข้อโครงงาน\nในภาคการศึกษา ",
                                ),
                                TextSpan(
                                  text: termName ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorPlate.colors[6].color,
                                  ),
                                ),
                                const TextSpan(text: " ปีการศึกษา "),
                                TextSpan(
                                  text: year ?? '',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: ColorPlate.colors[6].color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text("โดยการสอบครั้งนี้เป็นการสอบ ครั้งที่ : "),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              decoration: InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                              ),
                              value: selectedAttempt,
                              isExpanded: true,
                              items:
                                  [1, 2, 3, 4, 5].map((int attempt) {
                                    return DropdownMenuItem<int>(
                                      value: attempt,
                                      child: Text(
                                        "$attempt",
                                        style: labelStyle,
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedAttempt = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text("ชื่อโครงงานภาษาไทย", style: labelStyle),
                      const SizedBox(height: 5),
                      _buildTextInput(thaiTitleController, "กรอกชื่อภาษาไทย"),
                      const SizedBox(height: 15),
                      Text("ชื่อโครงงานภาษาอังกฤษ", style: labelStyle),
                      const SizedBox(height: 5),
                      _buildTextInput(engTitleController, "กรอกชื่อภาษาอังกฤษ"),
                      const SizedBox(height: 15),
                      Text("ประธานกรรมการสอบ", style: labelStyle),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedChairman,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        items:
                            professors.map((String name) {
                              return DropdownMenuItem<String>(
                                value: name,
                                child: Text(name, style: labelStyle),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedChairman = value;
                          });
                        },
                      ),

                      const SizedBox(height: 10),
                      Text("กรรมการสอบ คนที่ 1", style: labelStyle),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedCommittee1,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        items:
                            professors.map((String name) {
                              return DropdownMenuItem<String>(
                                value: name,
                                child: Text(name, style: labelStyle),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCommittee1 = value;
                          });
                        },
                      ),

                      const SizedBox(height: 10),
                      Text("กรรมการสอบ คนที่ 2", style: labelStyle),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: selectedCommittee2,
                        decoration: InputDecoration(
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        items:
                            professors.map((String name) {
                              return DropdownMenuItem<String>(
                                value: name,
                                child: Text(name, style: labelStyle),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCommittee2 = value;
                          });
                        },
                      ),

                      const SizedBox(height: 20),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("อาจารย์ที่ปรึกษา :", style: labelStyle),
                              const SizedBox(height: 10),
                              Text(
                                professor != null && professor!.isNotEmpty
                                    ? professor!
                                    : 'ไม่พบอาจารย์ที่ปรึกษา',
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      professor != null && professor!.isNotEmpty
                                          ? ColorPlate.colors[6].color
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text("อัพโหลดไฟล์ IT02D / CS02D", style: labelStyle),
                      const SizedBox(height: 10),
                      Center(
                        child: FileUploadWidget(
                          onFilesPicked: (files) {
                            setState(() {
                              uploadedFiles = files;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.warning,
                                animType: AnimType.topSlide,
                                title: 'ยืนยันการส่ง',
                                desc: 'คุณต้องการบันทึกข้อมูลหรือไม่?',
                                btnOkOnPress: () {
                                  submitForm();
                                },
                                btnCancelOnPress: () {},
                              ).show();
                            },
                            icon: const Icon(Icons.send, color: Colors.white),
                            label: Text(
                              "ส่งแบบฟอร์ม",
                              style: GoogleFonts.prompt(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              textStyle: const TextStyle(fontSize: 16),
                              backgroundColor: ColorPlate.colors[6].color,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Center(
                        child: Text(
                          "* กรุณาทำส่งแบบฟอร์มขอจัดสรรกลุ่มก่อน \n(CP00R)",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildTextInput(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }

  final labelStyle = GoogleFonts.prompt(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
}
