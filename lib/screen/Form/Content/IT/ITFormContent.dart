import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:project/ColorPlate/color.dart';
import 'package:project/bloc/Subject/IT/subject_bloc.dart';

class ITFormContent extends StatelessWidget {
  final TextEditingController gpaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ITFormContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      color: ColorPlate.colors[5].color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "ผลการเรียนรายวิชาบังคับของหลักสูตรในชั้นปีที่ 1-3 ที่เป็นหลักสูตรของภาควิชาฯ (รายวิชาที่ขึ้นต้นรหัสด้วย 517 และ 520)",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          BlocBuilder<SubjectBloc, SubjectState>(
            builder: (context, state) {
              if (state is SubjectLoading) {
                return Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: Colors.deepPurple,
                    size: 50,
                  ),
                );
              } else if (state is SubjectError) {
                return Center(
                  child: Text(
                    "เกิดข้อผิดพลาด: ${state.message}",
                    style: GoogleFonts.prompt(fontSize: 12),
                  ),
                );
              } else if (state is SubjectLoaded) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: DataTable(
                          columnSpacing: 5,
                          dataRowMinHeight: 40,
                          dataRowMaxHeight: 60,
                          columns: [
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  "รหัส - ชื่อวิชา",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.prompt(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  "ภาค",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.prompt(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  "ปี",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.prompt(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Expanded(
                                child: Text(
                                  "เกรด",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.prompt(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          rows:
                              state.subjects.map((subject) {
                                Map<String, String> selectedValues =
                                    state.selectedValues[subject] ?? {};
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      SizedBox(
                                        width:
                                            constraints.maxWidth *
                                            0.35, // ปรับให้ช่องชื่อวิชากว้างขึ้น
                                        child: Text(
                                          subject,
                                          style: GoogleFonts.prompt(
                                            fontSize: 10,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: constraints.maxWidth * 0.20,
                                        child: _buildDropdown(
                                          context,
                                          subject,
                                          'ภาคการศึกษา',
                                          ['ต้น', 'ปลาย', 'ฤดูร้อน'],
                                          selectedValues,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: constraints.maxWidth * 0.18,
                                        child: _buildDropdown(
                                          context,
                                          subject,
                                          'ปีการศึกษา',
                                          ['2567', '2568'],
                                          selectedValues,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: constraints.maxWidth * 0.15,
                                        child: _buildDropdown(
                                          context,
                                          subject,
                                          'เกรด',
                                          [
                                            'A',
                                            'B+',
                                            'B',
                                            'C+',
                                            'C',
                                            'D+',
                                            'D',
                                            'F',
                                            'W',
                                            'I',
                                          ],
                                          selectedValues,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(child: Text("ไม่มีข้อมูล"));
              }
            },
          ),
          SizedBox(height: 10),
          BlocBuilder<SubjectBloc, SubjectState>(
            builder: (context, state) {
              if (state is SubjectLoaded) {
                //ตรวจสอบว่าผู้ใช้เลือก 3 ค่าแล้ว
                int passedSubjects =
                    state.selectedValues.values
                        .where(
                          (selected) =>
                              selected['ภาคการศึกษา'] != null &&
                              selected['ปีการศึกษา'] != null &&
                              selected['เกรด'] != null &&
                              !['F', 'W', 'I'].contains(selected['เกรด']),
                        )
                        .length;

                int failedOrNotRegisteredSubjects =
                    state.selectedValues.values
                        .where(
                          (selected) =>
                              selected['ภาคการศึกษา'] == null ||
                              selected['ปีการศึกษา'] == null ||
                              selected['เกรด'] == null ||
                              ['F', 'W', 'I'].contains(selected['เกรด']),
                        )
                        .length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "รวมจำนวนวิชาที่สอบผ่าน: $passedSubjects",
                          style: GoogleFonts.prompt(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "รวมจำนวนวิชาที่สอบไม่ผ่าน / ยังไม่ลงทะเบียน: $failedOrNotRegisteredSubjects",
                          style: GoogleFonts.prompt(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              return SizedBox();
            },
          ),
          SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Row(
              children: [
                Text(
                  "เกรดเฉลี่ยสะสม (GPA): ",
                  style: GoogleFonts.prompt(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    width: 80, // กำหนดความกว้างของช่อง
                    height: 40, // กำหนดความสูงของช่อง
                    child: TextFormField(
                      controller: gpaController,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.center, // จัดข้อความให้อยู่ตรงกลาง
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // มุมโค้งมนขึ้น
                        ),
                        hintText: "0.00",
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 5,
                        ),
                        isDense: true, // ลดขนาด field ให้กระชับขึ้น
                      ),
                      style: GoogleFonts.prompt(fontSize: 12),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "โปรดกรอก GPA";
                        }
                        double? gpa = double.tryParse(value);
                        if (gpa == null || gpa < 0.00 || gpa > 4.00) {
                          return "GPA ต้องอยู่ระหว่าง 0.00 - 4.00";
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    BuildContext context,
    String subject,
    String label,
    List<String> items,
    Map<String, String> selectedValues,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButton<String>(
        value: selectedValues[label],
        alignment: Alignment.center,
        isExpanded: true,
        isDense: true,
        items:
            items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: GoogleFonts.prompt(fontSize: 10)),
              );
            }).toList(),
        onChanged: (value) {
          if (value != null) {
            context.read<SubjectBloc>().add(
              UpdateSubjectSelection(subject, label, value),
            );
          }
        },
      ),
    );
  }
}
