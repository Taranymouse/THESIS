import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/bloc/GetSubject/get_subject_bloc.dart';
import 'package:project/modles/subject_model.dart';

class SubjectTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetSubjectBloc, GetSubjectState>(
      builder: (context, state) {
        if (state is SubjectLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is SubjectError) {
          return Center(child: Text(state.message));
        } else if (state is SubjectsLoaded) {
          List<Subject> subjects = state.subjects;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('รหัสวิชา - ชื่อวิชา')),
                DataColumn(label: Text('ภาคการศึกษา')),
                DataColumn(label: Text('ปีการศึกษา')),
                DataColumn(label: Text('เกรด')),
              ],
              rows:
                  subjects.map((subject) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            "${subject.courseCode} - ${subject.name}",
                            overflow:
                                TextOverflow
                                    .ellipsis, // ถ้าข้อความยาวเกินจะตัดแสดง
                            maxLines: 2,
                          ),
                        ),
                        DataCell(
                          DropdownButton<String>(
                            items:
                                ['ต้น', 'ปลาย', 'ฤดูร้อน'].map((semester) {
                                  return DropdownMenuItem<String>(
                                    value: semester,
                                    child: Text(semester),
                                  );
                                }).toList(),
                            onChanged: (value) {},
                          ),
                        ),
                        DataCell(
                          DropdownButton<String>(
                            items:
                                ['2567', '2568', '2569'].map((year) {
                                  return DropdownMenuItem<String>(
                                    value: year,
                                    child: Text(year),
                                  );
                                }).toList(),
                            onChanged: (value) {},
                          ),
                        ),
                        DataCell(
                          DropdownButton<String>(
                            items:
                                ['A', 'B', 'C', 'D', 'F', 'I', 'W'].map((
                                  grade,
                                ) {
                                  return DropdownMenuItem<String>(
                                    value: grade,
                                    child: Text(grade),
                                  );
                                }).toList(),
                            onChanged: (value) {},
                          ),
                        ),
                      ],
                    );
                  }).toList(),
            ),
          );
        } else {
          return Center(child: Text("ไม่พบข้อมูลวิชา"));
        }
      },
    );
  }
}
