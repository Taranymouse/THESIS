import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:project/bloc/GetSubject/get_subject_bloc.dart';
import 'package:project/bloc/Semester/semester_bloc.dart';
import 'package:project/bloc/StdYear/stdyear_bloc.dart';
import 'package:project/modles/subject_model.dart';
import 'package:project/screen/Form/CheckPerForm/Content.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Form/Form_Options/TextFeild/customTextFeild.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourse.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourseYear.dart';
import 'package:project/screen/Form/Form_Options/dropdown/semester.dart';
import 'package:project/screen/Form/Form_Options/dropdown/stdyear.dart';
import 'package:project/screen/home.dart';

class CheckPerform extends StatefulWidget {
  CheckPerform({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController stdidController = TextEditingController();

  @override
  State<CheckPerform> createState() => _CheckPerformState();
}

class _CheckPerformState extends State<CheckPerform> {
  String? selectedCourse;
  String? selectedCourseYear;
  String? selectedSemester;
  String? selectedStdYear;
  int passedSubjectsCount = 0;
  int failedSubjectsCount = 0;
  bool isTableValid = false;
  List<Map<String, dynamic>> subjectsData = [];

  void _fetchSubjects() {
    if (selectedCourse != null && selectedCourseYear != null) {
      context.read<GetSubjectBloc>().add(
        FetchAllSubject(courseYear: selectedCourseYear!),
      );
    }
  }

  Map<String, dynamic> formatData({
    required String course,
    required String semester,
    required String year,
    required String prefix,
    required String fname,
    required String lname,
    required String sId,
    required List<Map<String, dynamic>> subjects,
    required String overallGrade,
    required int branchId,
    required String branchName,
  }) {
    return {
      "course": int.tryParse(course) ?? 0,
      "semester": int.tryParse(semester) ?? 0,
      "year": int.tryParse(year) ?? 0,
      "student": [
        {
          "prefix": prefix,
          "fname": fname,
          "lname": lname,
          "s_id": sId,
          "subject": subjects,
          "overall_grade": overallGrade,
          "branch": {"id_branch": branchId, "name_branch": branchName},
        },
      ],
    };
  }

  void _submitForm() {
    if (!isTableValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("กรุณากรอกข้อมูลในตารางให้ครบถ้วน")),
      );
      return;
    }

    if (widget.nameController.text.isEmpty ||
        widget.lastnameController.text.isEmpty ||
        widget.stdidController.text.isEmpty ||
        selectedCourse == null ||
        selectedCourseYear == null ||
        selectedSemester == null ||
        selectedStdYear == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบถ้วน")));
      return;
    }

    Map<String, dynamic> formattedData = formatData(
      course: selectedCourse!,
      semester: selectedSemester!,
      year: selectedCourseYear!,
      prefix: "Mr./Ms.", // หรือเพิ่ม dropdown สำหรับเลือก prefix
      fname: widget.nameController.text,
      lname: widget.lastnameController.text,
      sId: widget.stdidController.text,
      subjects: subjectsData, // ใช้ข้อมูลจาก SubjectTable
      overallGrade: "A", // คำนวณเกรดรวมถ้าจำเป็น
      branchId: 101, // ตัวอย่าง branchId
      branchName: "Computer Science", // ตัวอย่าง branchName
    );

    print(formattedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("แบบฟอร์มตรวจคุณสมบัติ"),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: Homepage()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DropDownTopContent(
                onCourseChanged: (value) {
                  setState(() {
                    selectedCourse = value;
                  });
                  print("Selected course: $selectedCourse");
                },
                onCourseYearChanged: (value) {
                  setState(() {
                    selectedCourseYear = value;
                  });
                  print("Selected course year: $selectedCourseYear");
                  _fetchSubjects();
                },
                onSemesterChanged: (value) {
                  setState(() {
                    selectedSemester = value;
                  });
                },
                onStdYearChanged: (value) {
                  setState(() {
                    selectedStdYear = value;
                  });
                },
              ),
              SizedBox(height: 10),
              FormContentInput(
                nameController: widget.nameController,
                lastnameController: widget.lastnameController,
                stdidController: widget.stdidController,
              ),
              const SizedBox(height: 20),
              if (selectedCourse == null || selectedCourseYear == null)
                const Center(child: Text("กรุณาเลือกหลักสูตรและปีหลักสูตร"))
              else
                BlocBuilder<GetSubjectBloc, GetSubjectState>(
                  builder: (context, state) {
                    if (state is SubjectLoading) {
                      return Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.deepPurple,
                          size: 50,
                        ),
                      );
                    }
                    if (state is SubjectsLoaded) {
                      return Column(
                        children: [
                          SubjectTable(
                            subjects: state.subjects,
                            onPassedSubjectsChanged: (count) {
                              setState(() {
                                passedSubjectsCount = count;
                              });
                            },
                            onFailedSubjectsChanged: (count) {
                              setState(() {
                                failedSubjectsCount = count;
                              });
                            },
                            onValidationChanged: (isValid) {
                              setState(() {
                                isTableValid = isValid;
                              });
                            },
                            onSubjectsDataChanged: (data) {
                              setState(() {
                                subjectsData = data;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed:
                                    state.offset > 0
                                        ? () {
                                          context.read<GetSubjectBloc>().add(
                                            FetchAllSubject(
                                              offset:
                                                  state.offset - state.limit,
                                              limit: state.limit,
                                              courseYear: selectedCourseYear,
                                            ),
                                          );
                                        }
                                        : null,
                                child: const Text("ก่อนหน้า"),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                "หน้า ${(state.offset / state.limit).floor() + 1} จาก ${(state.total / state.limit).ceil()}",
                                style: GoogleFonts.prompt(fontSize: 12),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed:
                                    (state.offset + state.limit) < state.total
                                        ? () {
                                          context.read<GetSubjectBloc>().add(
                                            FetchAllSubject(
                                              offset:
                                                  state.offset + state.limit,
                                              limit: state.limit,
                                              courseYear: selectedCourseYear,
                                            ),
                                          );
                                        }
                                        : null,
                                child: const Text("ถัดไป"),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else if (state is SubjectError) {
                      return Center(child: Text("Error: ${state.message}"));
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("จำนวนรายวิชาที่ผ่าน : $passedSubjectsCount"),
                  SizedBox(width: 10),
                ],
              ),
              Row(
                children: [
                  Text(
                    "จำนวนรายวิชาที่ไม่ผ่าน / ยังไม่ลงทะเบียน : $failedSubjectsCount",
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (!isTableValid) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("กรุณากรอกข้อมูลในตารางให้ครบถ้วน"),
                      ),
                    );
                    return;
                  }

                  if (widget.nameController.text.isEmpty ||
                      widget.lastnameController.text.isEmpty ||
                      widget.stdidController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("กรุณากรอกข้อมูลให้ครบถ้วน")),
                    );
                  } else {
                    // Handle form submission
                    print("Form submitted with values:");
                    print("Name: ${widget.nameController.text}");
                    print("Lastname: ${widget.lastnameController.text}");
                    print("Student ID: ${widget.stdidController.text}");
                    _submitForm();
                  }
                },
                child: Text("Submit"),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class DropDownTopContent extends StatelessWidget {
  final Function(String?) onCourseChanged;
  final Function(String?) onCourseYearChanged;
  final Function(String?) onSemesterChanged;
  final Function(String?) onStdYearChanged;

  const DropDownTopContent({
    super.key,
    required this.onCourseChanged,
    required this.onCourseYearChanged,
    required this.onSemesterChanged,
    required this.onStdYearChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("หลักสูตร :"),
            SizedBox(width: 10),
            CourseDropdown(onCourseChanged: onCourseChanged),
            SizedBox(width: 20),
            Text("ปีหลักสูตร :"),
            SizedBox(width: 10),
            CourseYearDropdown(onCourseYearChanged: onCourseYearChanged),
          ],
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("ภาคการศึกษา :"),
            SizedBox(width: 10),
            BlocBuilder<SemesterBloc, SemesterState>(
              builder: (context, state) {
                String? selected =
                    (state is SemesterChanged) ? state.selectedSemester : null;
                return Semester(
                  selectedValue: selected,
                  onChanged: (newValue) {
                    onSemesterChanged(newValue);
                    context.read<SemesterBloc>().add(
                      SemesterSelected(newValue),
                    );
                  },
                );
              },
            ),
            SizedBox(width: 20),
            Text("ปีการศึกษา :"),
            SizedBox(width: 10),
            BlocBuilder<StdyearBloc, StdyearState>(
              builder: (context, state) {
                String? selected =
                    (state is StdyearChanged) ? state.selectedStdyear : null;
                return Stdyear(
                  selectedValue: selected,
                  onChanged: (newValue) {
                    onStdYearChanged(newValue);
                    context.read<StdyearBloc>().add(StdyearSelected(newValue));
                  },
                );
              },
            ),
          ],
        ),
        Text(
          "หมายเหตุ : กรุณาแนบผลการศึกษาที่พิมพ์จากเว็บระบบบริการการศึกษาของมหาวิทยาลัยด้วย (reg.su.ac.th)",
          style: TextStyle(fontSize: 10, color: Colors.red),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class FormContentInput extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController lastnameController;
  final TextEditingController stdidController;

  const FormContentInput({
    super.key,
    required this.nameController,
    required this.lastnameController,
    required this.stdidController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: "ชื่อจริง",
          controller: nameController,
          validator:
              (value) =>
                  value == null || value.isEmpty ? "กรุณากรอกชื่อจริง" : null,
        ),
        SizedBox(height: 10),
        CustomTextField(
          label: "นามสกุล",
          controller: lastnameController,
          validator:
              (value) =>
                  value == null || value.isEmpty ? "กรุณากรอกนามสกุล" : null,
        ),
        SizedBox(height: 10),
        CustomTextField(
          label: "รหัสนักศึกษา",
          controller: stdidController,
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? "กรุณากรอกรหัสนักศึกษา"
                      : null,
        ),
      ],
    );
  }
}
