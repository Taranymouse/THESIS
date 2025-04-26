import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/bloc/Course/course_bloc.dart';
import 'package:project/bloc/GetSubject/get_subject_bloc.dart';
import 'package:project/modles/subject_model.dart';
import 'package:project/screen/Admin/adminhome.dart';
import 'package:project/screen/Form/Form_Options/BackButton/backbttn.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourse.dart';
import 'package:project/screen/Form/Form_Options/dropdown/selectCourseYear.dart';
import 'package:project/screen/Admin/ManageSubject/editsubject.dart';

class AllSubjectsPage extends StatefulWidget {
  @override
  _AllSubjectsPageState createState() => _AllSubjectsPageState();
}

class _AllSubjectsPageState extends State<AllSubjectsPage> {
  String? course;
  String? courseYear;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    context.read<CourseBloc>().add(LoadCourses());
    _fetchSubjects(); // ดึงข้อมูลทั้งหมดตั้งแต่เริ่มต้น
  }

  void _fetchSubjects({bool resetPage = true}) {
    final subjectBloc = context.read<GetSubjectBloc>();
    final currentState = subjectBloc.state;

    if (currentState is! SubjectLoading) {
      if (resetPage) {
        setState(() {
          currentPage = 0;
        });
      }

      subjectBloc.add(
        FetchAllSubject(
          courseYear: courseYear,
          branchId: course,
          offset: resetPage ? 0 : currentPage * 10,
          limit: 10,
        ),
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
      _fetchSubjects(); // รีเฟรชข้อมูลหลังจากแก้ไข
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
      body: Padding(
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
                    _fetchSubjects(); // รีเฟรชข้อมูลหลังจากเพิ่มรายวิชา
                  }
                },
                child: Text(
                  "+ เพิ่มรายวิชา",
                  style: GoogleFonts.prompt(fontSize: 12),
                ),
              ),
            ),
            DropDownTopContent(
              selectedCourse: course,
              onCourseChanged: (value) {
                setState(() {
                  course = value;
                });
                _fetchSubjects(resetPage: true); // ✅ รีเซ็ตหน้า
              },
              onCourseYearChanged: (value) {
                setState(() {
                  courseYear = value;
                });
                _fetchSubjects(resetPage: true); // ✅ รีเซ็ตหน้า
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GetSubjects(
                onEditSubject: _navigateToEdit,
                course: course, // ส่งค่าตัวแปร course
                courseYear: courseYear, // ส่งค่าตัวแปร courseYear
                currentPage: currentPage, // ส่ง currentPage ที่อัพเดต
                onPageChange: (newPage) {
                  setState(() {
                    currentPage = newPage;
                  });
                  _fetchSubjects(resetPage: false); // ✅ ไม่รีเซ็ต
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DropDownTopContent extends StatefulWidget {
  final String? selectedCourse;
  final Function(String?) onCourseChanged;
  final Function(String?) onCourseYearChanged;

  const DropDownTopContent({
    Key? key,
    required this.onCourseChanged,
    required this.onCourseYearChanged,
    required this.selectedCourse,
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
              value: widget.selectedCourse,
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

class GetSubjects extends StatefulWidget {
  final Function(dynamic) onEditSubject;
  final String? course;
  final String? courseYear;
  final int currentPage; // Add currentPage
  final Function(int) onPageChange; // Add onPageChange

  const GetSubjects({
    Key? key,
    required this.onEditSubject,
    this.course,
    this.courseYear,
    required this.currentPage, // Add currentPage to constructor
    required this.onPageChange, // Add onPageChange to constructor
  }) : super(key: key);

  @override
  State<GetSubjects> createState() => _GetSubjectsState();
}

class _GetSubjectsState extends State<GetSubjects> {
  List<Subject> subjects = [];
  bool _isLoading = false;
  bool _hasNextPage = true;

  @override
  void initState() {
    super.initState();
  }

  void fetchSubjects() {
    setState(() => _isLoading = true);
    int offset = widget.currentPage * 10; // Use _currentPage for offset

    context.read<GetSubjectBloc>().add(
      FetchAllSubject(
        offset: offset,
        limit: 10,
        courseYear: widget.courseYear,
        branchId: widget.course, // Send this parameter as needed
      ),
    );
  }

  void loadPreviousPage() {
    if (widget.currentPage > 0) {
      widget.onPageChange(widget.currentPage - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetSubjectBloc, GetSubjectState>(
      listener: (context, state) {
        if (state is SubjectsLoaded) {
          setState(() {
            subjects = state.subjects;
            // ✅ คำนวณว่าเหลือหน้าต่อไปมั้ย
            int total = state.total;
            int maxPages = (total / state.limit).ceil();
            _hasNextPage = widget.currentPage + 1 < maxPages;
            _isLoading = false;
          });
        } else if (state is SubjectError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("เกิดข้อผิดพลาด: ${state.message}")),
          );
          setState(() => _isLoading = false);
        }
      },
      child: BlocBuilder<GetSubjectBloc, GetSubjectState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: subjects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      child: ListTile(
                        leading: const Icon(
                          Icons.book,
                          color: Colors.blueAccent,
                        ),
                        title: Text(
                          "${subject.courseCode} - ${subject.name_subjects}",
                          style: GoogleFonts.prompt(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          "ปีหลักสูตร: ${subject.year}",
                          style: GoogleFonts.prompt(),
                        ),
                        trailing: ElevatedButton.icon(
                          onPressed: () => widget.onEditSubject(subject),
                          icon: const Icon(Icons.edit, size: 18),
                          label: const Text("แก้ไข"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: widget.currentPage > 0 ? loadPreviousPage : null,
                    child: const Text("ก่อนหน้า"),
                  ),
                  Text("หน้าที่ ${widget.currentPage + 1}"),
                  ElevatedButton(
                    onPressed:
                        _hasNextPage
                            ? () => widget.onPageChange(widget.currentPage + 1)
                            : null,
                    child: const Text("ถัดไป"),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
