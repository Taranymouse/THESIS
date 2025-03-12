import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'subject_event.dart';
part 'subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  SubjectBloc() : super(SubjectInitial()) {
    on<LoadSubjects>(_onLoadSubjects);
    on<UpdateSubjectSelection>(_onUpdateSubjectSelection);
  }

  Future<void> _onLoadSubjects(
    LoadSubjects event,
    Emitter<SubjectState> emit,
  ) async {
    emit(SubjectLoading());

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.117:8000/subjects/'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print("###### !!! API response : ${response.body}");
        // ✅ คัดกรองเฉพาะรายวิชาของปีที่เลือก
        List<String> subjects = data.where((item) => item['year_course_sub'] == event.courseYear).map(
                  (item) => "${item['course_code']} ${item['name_subjects']}",
                ).toList();

        emit(SubjectLoaded(subjects: subjects, selectedValues: {}));
      } else {
        emit(SubjectError("เกิดข้อผิดพลาด: ${response.statusCode}"));
      }
    } catch (e) {
      emit(SubjectError("เชื่อมต่อ API ไม่สำเร็จ: ${e.toString()}"));
    }
  }

  void _onUpdateSubjectSelection(
    UpdateSubjectSelection event,
    Emitter<SubjectState> emit,
  ) {
    if (state is SubjectLoaded) {
      final currentState = state as SubjectLoaded;

      // ✅ สร้าง Map ใหม่แทนที่การแก้ไขอันเก่าโดยตรง
      final newSelectedValues = Map<String, Map<String, String>>.from(
        currentState.selectedValues,
      );

      newSelectedValues[event.subject] = Map<String, String>.from(
        newSelectedValues[event.subject] ?? {},
      );

      newSelectedValues[event.subject]![event.field] = event.value;

      emit(
        SubjectLoaded(
          subjects: currentState.subjects,
          selectedValues: newSelectedValues, // ✅ Map ใหม่ (ทำให้ UI รีเฟรช)
        ),
      );
    }
  }
}

// dummy subjects
List<String> _getSubjectsForYear(String courseYear) {
  if (courseYear == "2560") {
    return [
      '520101 วิชาทดลอง IT (2560)',
      '520102 วิชาคณิตศาสตร์ IT (2560)',
      '520103 วิชาฟิสิกส์ IT (2560)',
      '520104 วิชาเคมี IT (2560)',
      '520105 วิชาชีววิทยา IT (2560)',
    ];
  } else if (courseYear == "2565") {
    return [
      '520201 วิชาเขียนโปรแกรม IT (2565)',
      '520202 วิชาโครงสร้างข้อมูล IT (2565)',
      '520203 วิชาเครือข่ายคอมพิวเตอร์ IT (2565)',
      '520204 วิชาปัญญาประดิษฐ์ IT (2565)',
      '520205 วิชาความมั่นคงไซเบอร์ IT (2565)',
    ];
  } else {
    return [];
  }
}
