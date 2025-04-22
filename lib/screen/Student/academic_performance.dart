import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourse.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourseYear.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectPrefix.dart';
import 'package:project/screen/Form/Form_Options/dropdown/semester.dart';
import 'package:project/screen/Form/Form_Options/dropdown/stdyear.dart';
import 'package:project/screen/Student/document_router.dart';
import 'package:project/screen/Student/subject_table.dart';

class PerformanceForm extends StatefulWidget {
  const PerformanceForm({super.key});

  @override
  State<PerformanceForm> createState() => _PerformanceFormState();
}

class _PerformanceFormState extends State<PerformanceForm> {
  String? selectedCourse;
  String? selectedCourseYear;
  String? selectedPrefix;
  String? selectedSemester;
  String? selectedYear;
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController studentIdController;
  bool canSubmit = false;
  bool fileSelected = false;

  void checkCanSubmit() {
    setState(() {
      canSubmit =
          selectedPrefix != null &&
          selectedSemester != null &&
          selectedYear != null &&
          firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          fileSelected;
    });
  }

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    studentIdController = TextEditingController();
    firstNameController.addListener(checkCanSubmit);
    lastNameController.addListener(checkCanSubmit);
    studentIdController.addListener(checkCanSubmit);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    studentIdController.dispose();
    super.dispose();
  }

  void onGradeChanged(int index, String? grade) {
    checkCanSubmit();
  }

  void onFileSelected() {
    fileSelected = true;
    checkCanSubmit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "แบบตรวจสอบคุณสมบัติในการมีสิทธิ์ขอจัดทำโครงงานปริญญานิพนธ์",
          maxLines: 1,
        ),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: DocumentRouter()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              DropDownContent(
                selectedCourse: selectedCourse,
                selectedCourseYear: selectedCourseYear,
                onCourseChanged: (value) {
                  setState(() {
                    selectedCourse = value;
                  });
                  checkCanSubmit();
                },
                onCourseYearChanged: (value) {
                  setState(() {
                    selectedCourseYear = value;
                  });
                  checkCanSubmit();
                },
                onResetFilters: () {
                  setState(() {
                    selectedCourse = null;
                    selectedCourseYear = null;
                  });
                  checkCanSubmit();
                },
              ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
                indent: 20,
                endIndent: 20,
              ),
              TextFeildContent(
                firstNameController: firstNameController,
                lastNameController: lastNameController,
                studentIdController: studentIdController,
                selectedPrefix: selectedPrefix,
                onPrefixChanged: (value) {
                  setState(() {
                    selectedPrefix = value;
                  });
                  checkCanSubmit();
                },
                selectedSemester: selectedSemester,
                onSemesterChanged: (value) {
                  print("เลือกภาคการศึกษา: $value");
                  setState(() {
                    selectedSemester = value;
                  });
                  checkCanSubmit();
                },
                selectedYear: selectedYear,
                onYearChanged: (value) {
                  print("เลือกปีการศึกษา: $value");
                  setState(() {
                    selectedYear = value;
                  });
                  checkCanSubmit();
                },
              ),
              Divider(
                color: Colors.grey,
                thickness: 1,
                height: 20,
                indent: 20,
                endIndent: 20,
              ),
              SubjectsTable(
                key: ValueKey(
                  '${selectedCourse ?? ''}-${selectedCourseYear ?? ''}',
                ),
                selectedCourse: selectedCourse,
                selectedCourseYear: selectedCourseYear,
                firstNameController: firstNameController,
                lastNameController: lastNameController,
                studentIdController: studentIdController,
                selectedPrefix: selectedPrefix,
                selectedSemester: selectedSemester,
                selectedYear: selectedYear,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DropDownContent extends StatefulWidget {
  final String? selectedCourse;
  final String? selectedCourseYear;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<String?> onCourseYearChanged;
  final VoidCallback onResetFilters; // เพิ่มฟังก์ชันสำหรับรีเซ็ต

  const DropDownContent({
    super.key,
    required this.selectedCourse,
    required this.selectedCourseYear,
    required this.onCourseChanged,
    required this.onCourseYearChanged,
    required this.onResetFilters, // เพิ่มฟังก์ชันนี้
  });

  @override
  State<DropDownContent> createState() => _DropDownContentState();
}

class _DropDownContentState extends State<DropDownContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("เลือกแบบฟอร์ม"),
        const SizedBox(height: 10),
        const Text(
          "กรุณากรอกข้อมูลให้ครบถ้วน ถูกต้อง ตามลำดับ",
          style: TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("หลักสูตร :"),
            const SizedBox(width: 10),
            CourseDropdown(
              value: widget.selectedCourse,
              onCourseChanged: (value) {
                widget.onCourseChanged(value);
              },
            ),
            const SizedBox(width: 10),
            const Text("ปีหลักสูตร :"),
            const SizedBox(width: 10),
            CourseYearDropdown(
              value: widget.selectedCourseYear,
              onCourseYearChanged: (value) {
                widget.onCourseYearChanged(value);
              },
            ),
            const SizedBox(width: 5),
            ElevatedButton(
              onPressed: () {
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.warning,
                  animType: AnimType.topSlide,
                  title: 'ยืนยันการล้างข้อมูล',
                  titleTextStyle: GoogleFonts.prompt(fontSize: 16),
                  desc:
                      'คุณแน่ใจหรือไม่ว่าต้องการล้างค่า?\nข้อมูลที่คุณกรอกในตารางจะถูกลบทั้งหมด',
                  btnCancelOnPress: () {
                    // ไม่ทำอะไร ถ้ายกเลิก
                  },
                  btnOkOnPress: () {
                    widget
                        .onResetFilters(); // เรียกฟังก์ชันที่ได้รับจาก Parent widget
                  },
                  btnCancelText: 'ยกเลิก',
                  btnOkText: 'ยืนยัน',
                  btnCancelColor: Colors.grey,
                  btnOkColor: Colors.red,
                ).show();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // ขอบมน
                ),
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                fixedSize: Size(20, 20), // ปรับขนาดให้พอดีกับ "X"
              ),
              child: const Text(
                "X",
                style: TextStyle(fontSize: 14),
              ), // ปรับขนาดตัวอักษรให้เหมาะสม
            ),
          ],
        ),
      ],
    );
  }
}

class TextFeildContent extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController studentIdController;
  final String? selectedPrefix;
  final String? selectedSemester;
  final String? selectedYear;
  final ValueChanged<String?> onPrefixChanged;
  final ValueChanged<String?> onSemesterChanged;
  final ValueChanged<String?> onYearChanged;

  const TextFeildContent({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.studentIdController,
    required this.selectedPrefix,
    required this.selectedSemester,
    required this.selectedYear,
    required this.onPrefixChanged,
    required this.onSemesterChanged,
    required this.onYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          " * สำคัญ",
          style: TextStyle(color: Colors.red, fontSize: 10),
        ),
        const Text(
          "รายละเอียดนักศึกษา",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            const Text("คำนำหน้า :"),
            const SizedBox(width: 10),
            SizedBox(
              width: 100,
              height: 50,
              child: PrefixDropdown(
                // Use the PrefixDropdown here
                onPrefixChanged: onPrefixChanged,
                value: selectedPrefix,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextFieldContainer(label: "ชื่อ", controller: firstNameController),
        const SizedBox(height: 10),
        TextFieldContainer(label: "นามสกุล", controller: lastNameController),
        const SizedBox(height: 10),
        TextFieldContainer(
          label: "รหัสนักศึกษา",
          controller: studentIdController,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text("ภาคการศึกษา :"),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
              height: 50,
              child: Semester(
                selectedValue: selectedSemester,
                onChanged: onSemesterChanged,
              ),
            ),
            const SizedBox(width: 10),
            const Text("ปีการศึกษา :"),
            const SizedBox(width: 10),
            SizedBox(
              width: 80,
              height: 50,
              child: Stdyear(
                selectedValue: selectedYear,
                onChanged: onYearChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TextFieldContainer extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const TextFieldContainer({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:
          MediaQuery.of(context).size.width *
          0.9, // ปรับความกว้างให้พอดีกับหน้าจอ
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14), // ลดขนาดตัวอักษรให้พอดี
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 12), // ลดขนาดของข้อความ label
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ), // ลดความโค้งของมุม
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10, // ลดขนาด padding ในแนวตั้ง
            horizontal: 12, // ลดขนาด padding ในแนวนอน
          ),
        ),
      ),
    );
  }
}
