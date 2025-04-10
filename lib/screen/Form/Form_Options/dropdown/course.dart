import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/bloc/Course/course_bloc.dart';

class Course extends StatelessWidget {
  final ValueChanged<String?> onChanged;
  final String? selectedValue;

  const Course({Key? key, required this.onChanged, required this.selectedValue})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<CourseBloc, CourseState>(
        builder: (context, state) {
          if (state is CourseLoading) {
            return const CircularProgressIndicator();
          } else if (state is CourseError) {
            return Text(state.message, style: GoogleFonts.prompt());
          } else if (state is CourseLoaded) {
            final items = state.courses;

            return DropdownButton<String>(
              hint: Text("หลักสูตร", style: GoogleFonts.prompt(fontSize: 12)),
              value: selectedValue,
              items:
                  items.isNotEmpty
                      ? items.map((item) {
                        return DropdownMenuItem<String>(
                          value: item['name_branch'],
                          child: Text(
                            item['name_branch'],
                            style: GoogleFonts.prompt(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList()
                      : [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            "ไม่พบข้อมูลหลักสูตร",
                            style: GoogleFonts.prompt(fontSize: 16),
                          ),
                        ),
                      ],
              onChanged: (newValue) {
                context.read<CourseBloc>().add(CourseSelected(newValue));
                onChanged(newValue);
              },
              isExpanded: true,
              alignment: Alignment.center,
              dropdownColor: Colors.white,
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
