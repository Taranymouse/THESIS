import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/bloc/GetSubject/get_subject_bloc.dart';
import 'package:project/modles/subject_model.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectTable extends StatefulWidget {
  final List<Subject> subjects;
  final Function(int) onPassedSubjectsChanged;
  final Function(int) onFailedSubjectsChanged;
  final Function(bool) onValidationChanged;
  final Function(List<Map<String, dynamic>>)
  onSubjectsDataChanged; // เพิ่ม callback

  const SubjectTable({
    Key? key,
    required this.subjects,
    required this.onPassedSubjectsChanged,
    required this.onFailedSubjectsChanged,
    required this.onValidationChanged,
    required this.onSubjectsDataChanged, // เพิ่ม callback
  }) : super(key: key);

  @override
  _SubjectTableState createState() => _SubjectTableState();
}

class _SubjectTableState extends State<SubjectTable> {
  Map<int, String> selectedSemesters = {};
  Map<int, String> selectedYears = {};
  Map<int, String> selectedGrades = {};

  int countPassedSubjects() {
    return selectedGrades.values.where((grade) {
      return grade != null && grade != 'F' && grade != 'W' && grade != 'I';
    }).length;
  }

  int countFailedSubjects() {
    return selectedGrades.values.where((grade) {
      return grade == 'F' || grade == 'I' || grade == 'W';
    }).length;
  }

  bool isAllDataFilled() {
    return selectedSemesters.length == widget.subjects.length &&
        selectedYears.length == widget.subjects.length &&
        selectedGrades.length == widget.subjects.length &&
        !selectedSemesters.values.contains(null) &&
        !selectedYears.values.contains(null) &&
        !selectedGrades.values.contains(null);
  }

  void _updateSubjectsData() {
    List<Map<String, dynamic>> subjectsData =
        widget.subjects.asMap().entries.map((entry) {
          int index = entry.key;
          Subject subject = entry.value;

          return {
            "subject_code": subject.courseCode,
            "subject_name": subject.nameSubjects,
            "subject_semester":
                int.tryParse(selectedSemesters[index] ?? "0") ?? 0,
            "subject_year": int.tryParse(selectedYears[index] ?? "0") ?? 0,
            "subject_grade": selectedGrades[index] ?? "",
          };
        }).toList();

    widget.onSubjectsDataChanged(
      subjectsData,
    ); // ส่งข้อมูลกลับไปยัง parent widget
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 30,
          columns: [
            DataColumn(
              label: Text(
                'รหัสวิชา - ชื่อวิชา',
                style: GoogleFonts.prompt(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'ภาคการศึกษา',
                style: GoogleFonts.prompt(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'ปีการศึกษา',
                style: GoogleFonts.prompt(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'เกรด',
                style: GoogleFonts.prompt(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          rows:
              widget.subjects.asMap().entries.map((entry) {
                int index = entry.key;
                Subject subject = entry.value;

                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        "${subject.courseCode} - ${subject.nameSubjects}",
                        style: GoogleFonts.prompt(fontSize: 8),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    DataCell(
                      DropdownButton<String>(
                        value: selectedSemesters[index],
                        items:
                            ['ต้น', 'ปลาย', 'ฤดูร้อน'].map((semester) {
                              return DropdownMenuItem<String>(
                                value: semester,
                                child: Text(
                                  semester,
                                  style: GoogleFonts.prompt(fontSize: 8),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSemesters[index] = value!;
                          });
                          _updateSubjectsData(); // อัปเดตข้อมูลเมื่อมีการเปลี่ยนแปลง
                          widget.onValidationChanged(isAllDataFilled());
                        },
                      ),
                    ),
                    DataCell(
                      DropdownButton<String>(
                        value: selectedYears[index],
                        items:
                            ['2567', '2568', '2569'].map((year) {
                              return DropdownMenuItem<String>(
                                value: year,
                                child: Text(
                                  year,
                                  style: GoogleFonts.prompt(fontSize: 8),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedYears[index] = value!;
                          });
                          _updateSubjectsData();
                          widget.onValidationChanged(isAllDataFilled());
                        },
                      ),
                    ),
                    DataCell(
                      DropdownButton<String>(
                        value: selectedGrades[index],
                        items:
                            [
                              'A',
                              'B+',
                              'B',
                              'C+',
                              'C',
                              'D+',
                              'D',
                              'F',
                              'I',
                              'W',
                            ].map((grade) {
                              return DropdownMenuItem<String>(
                                value: grade,
                                child: Text(
                                  grade,
                                  style: GoogleFonts.prompt(fontSize: 8),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGrades[index] = value!;
                          });
                          _updateSubjectsData();
                          widget.onPassedSubjectsChanged(countPassedSubjects());
                          widget.onFailedSubjectsChanged(countFailedSubjects());
                          widget.onValidationChanged(isAllDataFilled());
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
        ),
      ),
    );
  }
}
