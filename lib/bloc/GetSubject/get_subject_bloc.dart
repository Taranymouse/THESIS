import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:project/modles/subject_model.dart';

part 'get_subject_event.dart';
part 'get_subject_state.dart';

class GetSubjectBloc extends Bloc<GetSubjectEvent, GetSubjectState> {
  final String apiUrl = "http://192.168.1.117:8000/subjects";

  GetSubjectBloc() : super(ManageSubjectInitial()) {
    on<FetchAllSubject>(_onFetchAllSubject);
  }

  // ส่วนของการดึงข้อมูลทั้งหมด
  Future<void> _onFetchAllSubject(
    FetchAllSubject event,
    Emitter<GetSubjectState> emit,
  ) async {
    emit(SubjectLoading());
    try {
      print("📡 Fetching all subjects...");
      final response = await http.get(
        Uri.parse("http://192.168.1.117:8000/subjects"),
      );

      print("✅ Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("🔹 Response Body: ${response.body}");
        final List data = json.decode(response.body);

        // คัดกรองเฉพาะรายวิชาของปีที่เลือก
        List<Subject> subjects =
            data
                .where((item) => item['year_course_sub'] == event.courseYear)
                .map((item) => Subject.fromJson(item))
                .toList();

        emit(SubjectsLoaded(subjects: subjects, selectedValues: {}));
      } else {
        emit(SubjectError("Failed to load all subjects"));
      }
    } catch (e) {
      print("❌ Error fetching all subjects: $e");
      emit(SubjectError("Error: $e"));
    }
  }
}
