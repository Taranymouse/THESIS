import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/bloc/Course/course_bloc.dart';
import 'package:project/bloc/CourseYear/courseyear_bloc.dart';
import 'package:project/bloc/Semester/semester_bloc.dart';
import 'package:project/bloc/StdYear/stdyear_bloc.dart';
import 'package:project/bloc/Subject/IT/subject_bloc.dart';
import 'package:project/screen/Form/Content/CS/CSFormContent.dart';
import 'package:project/screen/Form/Content/IT/ITFormContent.dart';
import 'package:project/screen/Form/TextFeild/customTextFeild.dart';
import 'package:project/screen/Form/dropdown/course.dart';
import 'package:project/screen/Form/dropdown/courseyear.dart';
import 'package:project/screen/Form/dropdown/semester.dart';
import 'package:project/screen/Form/dropdown/stdyear.dart';

class Checkform extends StatefulWidget {
  Checkform({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController stdidController = TextEditingController();

  @override
  State<Checkform> createState() => _CheckformState();
}

class _CheckformState extends State<Checkform> {
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
              DropDownTopContent(),
              SizedBox(height: 10),
              FormContentInput(
                nameController: widget.nameController,
                lastnameController: widget.lastnameController,
                stdidController: widget.stdidController,
              ),
              SizedBox(height: 10),
              BlocBuilder<CourseBloc, CourseState>(
                builder: (context, courseState) {
                  String? course =
                      (courseState is CourseChanged)
                          ? courseState.selectedCourse
                          : null;

                  return BlocBuilder<CourseyearBloc, CourseyearState>(
                    builder: (context, yearState) {
                      String? courseYear =
                          (yearState is CourseyearChanged)
                              ? yearState.selectedCourseyear
                              : null;

                      if (courseYear != null) {
                        context.read<SubjectBloc>().add(
                          LoadSubjects(courseYear),
                        );
                      }

                      if (course == "IT" && courseYear == "2560") {
                        return ITFormContent();
                      } else if (course == "IT" && courseYear == "2565") {
                        return ITFormContent();
                      } else if (course == "CS" && courseYear == "2560") {
                        return CSFormContent();
                      } else if (course == "CS" && courseYear == "2565") {
                        return CSFormContent();
                      } else {
                        return Center(
                          child: Text("กรุณาเลือกหลักสูตรและปีหลักสูตร"),
                        );
                      }
                    },
                  );
                },
              ),
              SizedBox(height: 10),

              
            ],
          ),
        ),
      ),
    );
  }
}

class DropDownTopContent extends StatefulWidget {
  const DropDownTopContent({super.key});

  @override
  State<DropDownTopContent> createState() => _DropDownTopContentState();
}

class _DropDownTopContentState extends State<DropDownTopContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("หลักสูตร :"),
              SizedBox(width: 10),
              BlocBuilder<CourseBloc, CourseState>(
                builder: (context, state) {
                  String? selected =
                      (state is CourseChanged) ? state.selectedCourse : null;
                  return Course(
                    selectedValue: selected,
                    onChanged: (newValue) {
                      context.read<CourseBloc>().add(CourseSelected(newValue));
                    },
                  );
                },
              ),
              SizedBox(width: 20),
              Text("ปีหลักสูตร :"),
              SizedBox(width: 10),
              BlocBuilder<CourseyearBloc, CourseyearState>(
                builder: (context, state) {
                  String? selected =
                      (state is CourseyearChanged)
                          ? state.selectedCourseyear
                          : null;
                  return Courseyear(
                    selectedValue: selected,
                    onChanged: (newValue) {
                      context.read<CourseyearBloc>().add(
                        CourseyearSelected(newValue),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 20),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("ภาคการศึกษา :"),
              SizedBox(width: 10),
              BlocBuilder<SemesterBloc, SemesterState>(
                builder: (context, state) {
                  String? selected =
                      (state is SemesterChanged)
                          ? state.selectedSemester
                          : null;
                  return Semester(
                    selectedValue: selected,
                    onChanged: (newValue) {
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
                      context.read<StdyearBloc>().add(
                        StdyearSelected(newValue),
                      );
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
    return Container(
      child: Column(
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
      ),
    );
  }
}
