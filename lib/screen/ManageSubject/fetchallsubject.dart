import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/bloc/Course/course_bloc.dart';

import 'package:project/bloc/GetSubject/get_subject_bloc.dart';

import 'package:project/screen/Admin/adminhome.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';

import 'package:project/screen/Form/Form_Options/dropdown/selectCourse.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourseYear.dart';

import 'package:project/screen/ManageSubject/editsubject.dart';

class AllSubjectsPage extends StatefulWidget {
  @override
  _AllSubjectsPageState createState() => _AllSubjectsPageState();
}

class _AllSubjectsPageState extends State<AllSubjectsPage> {
  String? course;
  String? courseYear;

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(LoadCourses());
  }

  void _fetchSubjects() {
    if (course != null && courseYear != null) {
      context.read<GetSubjectBloc>().add(
        FetchAllSubject(courseYear: courseYear!),
      );
    }
  }

  Future<void> _navigateToEdit(subject) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Editsubject(
              id_subject: subject.id_subject,
              courseCode: subject.courseCode,
              name_subjects: subject.name_subjects,
              curriculumYear: subject.year,
              department: subject.branchId,
            ),
      ),
    );
    if (result == true) {
      _fetchSubjects();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("จัดการรายวิชา"),
        centerTitle: true,
        leading: BackButtonWidget(targetPage: AdminHomepage()),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/createsubject',
                  );
                  if (result == true) {
                    _fetchSubjects(); // โหลดข้อมูลใหม่ถ้ามีการเพิ่มรายวิชา
                  }
                },
                child: Text(
                  "+ เพิ่มรายวิชา",
                  style: GoogleFonts.prompt(fontSize: 12),
                ),
              ),
            ),
            DropDownTopContent(
              onCourseChanged: (value) {
                setState(() {
                  course = value;
                });
                print("Selected course: $course");
              },
              onCourseYearChanged: (value) {
                setState(() {
                  courseYear = value;
                });
                print("Selected course year: $courseYear");
                _fetchSubjects();
              },
            ),
            const SizedBox(height: 20),
            if (course == null || courseYear == null)
              const Center(child: Text("กรุณาเลือกหลักสูตรและปีหลักสูตร"))
            else
              Expanded(child: GetSubjects(onEditSubject: _navigateToEdit)),
          ],
        ),
      ),
    );
  }
}

class DropDownTopContent extends StatefulWidget {
  final Function(String?) onCourseChanged;
  final Function(String?) onCourseYearChanged;

  const DropDownTopContent({
    Key? key,
    required this.onCourseChanged,
    required this.onCourseYearChanged,
  }) : super(key: key);

  @override
  State<DropDownTopContent> createState() => _DropDownTopContentState();
}

class _DropDownTopContentState extends State<DropDownTopContent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("หลักสูตร :"),
            const SizedBox(width: 10),
            CourseDropdown(
              onCourseChanged: widget.onCourseChanged, // ส่งค่ากลับไป
            ),
            const SizedBox(width: 20),
            const Text("ปีหลักสูตร :"),
            const SizedBox(width: 10),
            CourseYearDropdown(
              onCourseYearChanged: widget.onCourseYearChanged, // ส่งค่ากลับไป
            ),
          ],
        ),
      ],
    );
  }
}

class GetSubjects extends StatelessWidget {
  final Function(dynamic) onEditSubject;

  const GetSubjects({Key? key, required this.onEditSubject}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSubjectBloc, GetSubjectState>(
      builder: (context, state) {
        if (state is SubjectLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SubjectsLoaded) {
          return ListView.builder(
            itemCount: state.subjects.length, // จำนวนวิชาที่จะโชว์
            itemBuilder: (context, index) {
              final subject =
                  state.subjects[index]; // วิชาที่เลือกในแต่ละ index
              return ListTile(
                title: Text(subject.courseCode), // แสดงรหัสวิชา
                subtitle: Text(subject.name_subjects), // แสดงชื่อวิชา
                onTap:
                    () => onEditSubject(subject), // เมื่อคลิกจะไปที่หน้าแก้ไข
              );
            },
          );
        } else if (state is SubjectError) {
          return Center(child: Text("Error: ${state.message}"));
        }
        return const Center(child: Text("No data"));
      },
    );
  }
}
