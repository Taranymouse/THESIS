import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project/bloc/CourseYear/courseyear_bloc.dart';

class Courseyear extends StatelessWidget {
  final ValueChanged<String?> onChanged;
  final String? selectedValue;

  const Courseyear({
    Key? key,
    required this.onChanged,
    required this.selectedValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<CourseyearBloc, CourseyearState>(
        builder: (context, state) {
          if (state is CourseyearLoading) {
            // เมื่อกำลังโหลด ให้แสดง CircularProgressIndicator
            return const Center(child: CircularProgressIndicator());
          } else if (state is CourseyearError) {
            // เมื่อมีข้อผิดพลาด ให้แสดงข้อความผิดพลาด
            return Center(
              child: Text(state.message, style: GoogleFonts.prompt()),
            );
          } else if (state is CourseyearLoaded) {
            // เมื่อโหลดข้อมูลสำเร็จ แสดง Dropdown
            final selectedCourseYear = selectedValue;

            return DropdownButton<String>(
              hint: Text("ปีหลักสูตร", style: GoogleFonts.prompt(fontSize: 12)),
              value: selectedCourseYear, // ใช้ selectedValue
              items:
                  ['2560', '2565'].map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.prompt(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (newValue) {
                // เมื่อผู้ใช้เลือกค่าใหม่
                context.read<CourseyearBloc>().add(
                  CourseyearSelected(newValue),
                );
                onChanged(newValue); // แจ้งข้อมูลที่เลือก
              },
              isExpanded: true,
              alignment: Alignment.center,
              dropdownColor: Colors.white,
            );
          } else {
            // ถ้าไม่พบ state ที่คาดหวัง
            return const SizedBox(); // หรือแสดงอะไรตามต้องการเมื่อไม่พบ state
          }
        },
      ),
    );
  }
}
