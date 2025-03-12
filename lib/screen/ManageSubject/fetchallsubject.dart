import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/bloc/Course/course_bloc.dart';
import 'package:project/bloc/CourseYear/courseyear_bloc.dart';
import 'package:project/bloc/GetSubject/get_subject_bloc.dart';
import 'package:project/bloc/Semester/semester_bloc.dart';
import 'package:project/bloc/StdYear/stdyear_bloc.dart';
import 'package:project/screen/Form/dropdown/course.dart';
import 'package:project/screen/Form/dropdown/courseyear.dart';
import 'package:project/screen/Form/dropdown/semester.dart';
import 'package:project/screen/Form/dropdown/stdyear.dart';
import 'package:project/screen/ManageSubject/editsubject.dart';

class AllSubjectsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("จัดการรายวิชา"), centerTitle: true,),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // ใช้ DropDownTopContent แทน Row เดิม
            DropDownTopContent(),
            SizedBox(height: 20),
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
                      context.read<GetSubjectBloc>().add(
                        FetchAllSubject(courseYear: courseYear),
                      );
                    }

                    if (course == "IT" && courseYear == "2560") {
                      return Expanded(
                        child: BlocBuilder<
                          GetSubjectBloc,
                          GetSubjectState
                        >(
                          builder: (context, state) {
                            if (state is SubjectLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is SubjectsLoaded) {
                              return ListView.builder(
                                itemCount: state.subjects.length,
                                itemBuilder: (context, index) {
                                  final subject = state.subjects[index];
                                  return ListTile(
                                    title: Text(subject.courseCode),
                                    subtitle: Text(subject.name),
                                    onTap: () {
                                      Navigator.push(
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
                                    },
                                  );
                                },
                              );
                            } else if (state is SubjectError) {
                              return Center(
                                child: Text("Error: ${state.message}"),
                              );
                            }
                            return const Center(child: Text("No data"));
                          },
                        ),
                      );
                    } else if (course == "IT" && courseYear == "2565") {
                      return Expanded(
                        child: BlocBuilder<
                          GetSubjectBloc,
                          GetSubjectState
                        >(
                          builder: (context, state) {
                            if (state is SubjectLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is SubjectsLoaded) {
                              return ListView.builder(
                                itemCount: state.subjects.length,
                                itemBuilder: (context, index) {
                                  final subject = state.subjects[index];
                                  return ListTile(
                                    title: Text(subject.courseCode),
                                    subtitle: Text(subject.name),
                                    onTap: () {
                                      Navigator.push(
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
                                    },
                                  );
                                },
                              );
                            }
                            return const Center(child: Text("No data"));
                          },
                        ),
                      );
                    } else if (course == "CS" && courseYear == "2560") {
                      return const Center(child: Text("Coming Soon.."));
                    } else if (course == "CS" && courseYear == "2565") {
                      return const Center(child: Text("Coming Soon.."));
                    } else {
                      return const Center(
                        child: Text("กรุณาเลือกหลักสูตรและปีหลักสูตร"),
                      );
                    }
                  },
                );
              },
            ),
          ],
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
        ],
      ),
    );
  }
}