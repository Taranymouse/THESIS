import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/bloc/Semester/semester_bloc.dart';
import 'package:project/screen/Form/dropdown/semester.dart';

class Checkform extends StatefulWidget {
  const Checkform({super.key});

  @override
  State<Checkform> createState() => _CheckformState();
}

class _CheckformState extends State<Checkform> {
  final List<String> stdyear = ['2567', '2568'];
  final List<String> courseyear = ['2560', '2565'];
  String? selectedStdyear;
  String? selectedCourseyear;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "แบบขอตรวจสอบคุณสมบัติในการมีสิทธิ์ขอจัดทำโครงงานปริญญานิพนธ์",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("หลักสูตร"),
                SizedBox(width: 20),
                DropdownButton<String>(
                  value: selectedCourseyear,
                  items:
                      courseyear.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                  onChanged: (String? newValvue) {
                    setState(() {
                      selectedCourseyear = newValvue;
                    });
                  },
                ),
              ],
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("ภาคการศึกษา"),
                SizedBox(width: 20),
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
                        ); // newValue เป็น String? แล้ว
                      },
                    );
                  },
                ),
                SizedBox(width: 20),
                Text("ปีการศึกษา"),
                SizedBox(width: 20),
                DropdownButton<String>(
                  value: selectedStdyear,
                  items:
                      stdyear.map((String item) {
                        return DropdownMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                  onChanged: (String? newValvue) {
                    setState(() {
                      selectedStdyear = newValvue;
                    });
                  },
                ),
              ],
            ),

            Text(
              "หมายเหตุ : กรุณาแนบผลการศึกษาที่พิมพ์จากเว็บระบบบริการการศึกษาของมหาวิทยาลัยด้วย (reg.su.ac.th)",
              style: TextStyle(fontSize: 10, color: Colors.red),
            ),

            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(20),
              color: const Color.fromARGB(255, 214, 214, 214),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text(
                            "ชื่อ",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          hintText: "กรุณากรอกชื่อจริง",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30.0),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0.0,
                            horizontal: 10.0,
                          ),
                        ),
                        keyboardType: TextInputType.name,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text(
                            "นามสกุล",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          hintText: "กรุณากรอกนามสกุล",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30.0),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0.0,
                            horizontal: 10.0,
                          ),
                        ),
                        keyboardType: TextInputType.name,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          label: Text(
                            "รหัสนักศึกษา",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          hintText: "กรุณากรอกรหัสนักศึกษา",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(30.0),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 0.0,
                            horizontal: 10.0,
                          ),
                        ),
                        keyboardType: TextInputType.name,
                      ),

                      SizedBox(height: 20),
                      Text(
                        "ผลการเรียนรายวิชาบังคับของหลักสูตรในชั้นปีที่ 1-3 ที่เป็นหลักสูตรของภาควิชาฯ (รายวิชาที่ขึ้นต้นรหัสด้วย 517 และ 520)",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
