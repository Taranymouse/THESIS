import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'course_event.dart';
part 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  final String baseIP = "192.168.1.179";
  late final String baseUrl;

  CourseBloc() : super(CourseInitial()) {
    baseUrl = "http://$baseIP:8000"; // ✅ กำหนด baseUrl จาก baseIP
    on<LoadCourses>(_onLoadCourses);
    on<CourseSelected>(_onCourseSelected);
  }

  Future<void> _onLoadCourses(LoadCourses event, Emitter<CourseState> emit) async {
    emit(CourseLoading());
    try {
      final response = await http.get(Uri.parse("$baseUrl/branches")); // ✅ ใช้ baseUrl

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Map<String, dynamic>> courses = data
            .map((item) => {
                  'name_branch': item['name_branch'],
                  'id_branch': item['id_branch'],
                })
            .toList();

        emit(CourseLoaded(courses: courses, selectedCourse: null));
      } else {
        emit(CourseError("❌ Failed to load branches. Status: ${response.statusCode}"));
      }
    } catch (e) {
      emit(CourseError("❌ Error: $e"));
    }
  }

  void _onCourseSelected(CourseSelected event, Emitter<CourseState> emit) {
    if (state is CourseLoaded) {
      final loadedState = state as CourseLoaded;
      emit(CourseLoaded(
        courses: loadedState.courses,
        selectedCourse: event.selectedCourse,
      ));
    }
  }
}
