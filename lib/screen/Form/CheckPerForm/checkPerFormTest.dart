import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:project/bloc/Semester/semester_bloc.dart';
import 'package:project/bloc/StdYear/stdyear_bloc.dart';
import 'package:project/bloc/Subject/IT/subject_bloc.dart';
import 'package:project/modles/subject_model.dart';
import 'package:project/screen/Form/CheckPerForm/Content.dart';
import 'package:project/screen/Form/Form_Options/TextFeild/customTextFeild.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourse.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourseYear.dart';
import 'package:project/screen/Form/Form_Options/dropdown/semester.dart';
import 'package:project/screen/Form/Form_Options/dropdown/stdyear.dart';

class TestCheckPerform extends StatefulWidget {
  TestCheckPerform({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController stdidController = TextEditingController();

  @override
  State<TestCheckPerform> createState() => _TestCheckPerformformState();
}

class _TestCheckPerformformState extends State<TestCheckPerform> {
  String? selectedCourse;
  String? selectedCourseYear;
  int passedSubjectsCount = 0;
  bool isTableValid = false;
  List<Map<String, dynamic>> subjectsData = [];

  int currentOffset = 0;
  final int limit = 10;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  void _fetchSubjects() {
    if (selectedCourse != null && selectedCourseYear != null) {
      context.read<SubjectBloc>().add(
        LoadSubjectsEvent(offset: currentOffset, limit: limit),
      );
    }
  }

  void loadNextPage() {
    setState(() {
      currentOffset += limit;
    });
    _fetchSubjects();
  }

  void loadPreviousPage() {
    if (currentOffset >= limit) {
      setState(() {
        currentOffset -= limit;
      });
      _fetchSubjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("แบบฟอร์มตรวจคุณสมบัติ"), centerTitle: true),
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
                  _fetchSubjects();
                },
                onCourseYearChanged: (value) {
                  setState(() {
                    selectedCourseYear = value;
                  });
                  _fetchSubjects();
                },
                onSemesterChanged: (value) {
                  // Handle semester change if necessary
                },
                onStdYearChanged: (value) {
                  // Handle student year change if necessary
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
                BlocBuilder<SubjectBloc, SubjectState>(
                  builder: (context, state) {
                    if (state is SubjectLoading) {
                      return Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.deepPurple,
                          size: 50,
                        ),
                      );
                    } else if (state is SubjectLoaded) {
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
                              // คุณสามารถจัดการค่าที่ตกไม่ผ่านได้ตรงนี้ เช่น พิมพ์หรือเก็บไว้ในตัวแปร
                              print("จำนวนวิชาที่ตก: $count");
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
                                onPressed: loadPreviousPage,
                                child: const Text("ก่อนหน้า"),
                              ),
                              const SizedBox(width: 20),
                              Text(
                                "หน้า ${(currentOffset / limit).floor() + 1}",
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: loadNextPage,
                                child: const Text("ถัดไป"),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else if (state is SubjectError) {
                      return Center(child: Text("Error: ${state.message}"));
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text("จำนวนรายวิชาที่ผ่าน : $passedSubjectsCount"),
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
                    // Call the submission function
                  }
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
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
