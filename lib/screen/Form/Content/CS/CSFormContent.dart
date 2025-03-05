import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/ColorPlate/color.dart';
import 'package:project/bloc/Subject/CS/subject_cs_bloc.dart';
import 'package:project/screen/Form/TextFeild/customTextFeild.dart';

class CSFormContent extends StatelessWidget {
  const CSFormContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: ColorPlate.colors[2].color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "ผลการเรียนรายวิชาบังคับของหลักสูตรในชั้นปีที่ 1-3 ที่เป็นหลักสูตรของภาควิชาฯ (รายวิชาที่ขึ้นต้นรหัสด้วย 517 และ 520)",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
              ),

              BlocBuilder<SubjectCsBloc, SubjectCsState>(
                builder: (context, state) {
                  if (state is SubjectCsLoaded) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: state.subjects.length,
                      itemBuilder: (context, index) {
                        String subject = state.subjects[index];
                        Map<String, String> selectedValues =
                            state.selectedValues[subject] ??
                            {}; // ดึงค่าที่เลือก

                        return ExpansionTile(
                          title: Text(subject),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children:
                                  ['ภาคการศึกษา', 'ปีการศึกษา', 'เกรด'].map((
                                    label,
                                  ) {
                                    List<String> items =
                                        label == 'ภาคการศึกษา'
                                            ? ['ต้น', 'ปลาย', 'ฤดูร้อน']
                                            : label == 'ปีการศึกษา'
                                            ? ['2567', '2568']
                                            : [
                                              'A',
                                              'B+',
                                              'B',
                                              'C+',
                                              'C',
                                              'D+',
                                              'D',
                                              'F',
                                            ];

                                    return DropdownButton<String>(
                                      value:
                                          selectedValues[label], // ใช้ค่าจาก state
                                      hint: Text(label),
                                      items:
                                          items.map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                      onChanged: (value) {
                                        if (value != null) {
                                          context.read<SubjectCsBloc>().add(
                                            UpdateSubjectSelectionCS(
                                              subject,
                                              label,
                                              value,
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  }).toList(),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    return Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"));
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
