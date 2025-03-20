import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/bloc/Course/course_bloc.dart';
import 'package:project/bloc/CourseYear/courseyear_bloc.dart';
import 'package:project/bloc/GetSubject/get_subject_bloc.dart';
import 'package:project/bloc/Semester/semester_bloc.dart';
import 'package:project/bloc/StdYear/stdyear_bloc.dart';
import 'package:project/screen/Admin/adminhome.dart';
import 'package:project/screen/Form/BackButton/backbttn.dart';
import 'package:project/screen/Form/dropdown/course.dart';
import 'package:project/screen/Form/dropdown/courseyear.dart';
import 'package:project/screen/Form/dropdown/semester.dart';
import 'package:project/screen/Form/dropdown/stdyear.dart';
import 'package:project/screen/ManageSubject/editsubject.dart';

class AllSubjectsPage extends StatefulWidget {
  @override
  _AllSubjectsPageState createState() => _AllSubjectsPageState();
}

class _AllSubjectsPageState extends State<AllSubjectsPage> {
  String? course;
  String? courseYear;

  void _fetchSubjects() {
    if (courseYear != null) {
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
              subjectId: subject.id,
              courseCode: subject.courseCode,
              courseName: subject.name,
              curriculumYear: subject.year,
              department: subject.branchId,
            ),
      ),
    );
    // ถ้ามีการเปลี่ยนแปลงให้โหลดใหม่
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
              },
              onCourseYearChanged: (value) {
                setState(() {
                  courseYear = value;
                  _fetchSubjects(); // โหลดรายวิชาใหม่เมื่อเลือกปีหลักสูตร
                });
              },
            ),
            const SizedBox(height: 20),
            if (course == "IT" &&
                (courseYear == "2560" || courseYear == "2565"))
              Expanded(child: GetSubjects(onEditSubject: _navigateToEdit))
            else if (course == "CS" &&
                (courseYear == "2560" || courseYear == "2565"))
              const Center(child: Text("Coming Soon.."))
            else
              const Center(child: Text("กรุณาเลือกหลักสูตรและปีหลักสูตร")),
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
            BlocBuilder<CourseBloc, CourseState>(
              builder: (context, state) {
                String? selected =
                    (state is CourseChanged) ? state.selectedCourse : null;
                return Course(
                  selectedValue: selected,
                  onChanged: (newValue) {
                    context.read<CourseBloc>().add(CourseSelected(newValue));
                    widget.onCourseChanged(newValue); // แจ้ง parent
                  },
                );
              },
            ),
            const SizedBox(width: 20),
            const Text("ปีหลักสูตร :"),
            const SizedBox(width: 10),
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
                    widget.onCourseYearChanged(newValue); // แจ้ง parent
                  },
                );
              },
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
            itemCount: state.subjects.length,
            itemBuilder: (context, index) {
              final subject = state.subjects[index];
              return ListTile(
                title: Text(subject.courseCode),
                subtitle: Text(subject.name),
                onTap: () => onEditSubject(subject),
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
