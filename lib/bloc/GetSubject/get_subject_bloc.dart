import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/subject_model.dart';

part 'get_subject_event.dart';
part 'get_subject_state.dart';

class GetSubjectBloc extends Bloc<GetSubjectEvent, GetSubjectState> {
  GetSubjectBloc() : super(GetSubjectInitial()) {
    on<FetchAllSubject>(_onFetchAllSubject);
  }

  Future<void> _onFetchAllSubject(
    FetchAllSubject event,
    Emitter<GetSubjectState> emit,
  ) async {
    emit(SubjectLoading());
    try {
      print(" (From GetSubject BLoC) ");
      print("📡Fetching all subjects...");

      final response = await http.get(
        Uri.parse('$baseUrl/api/subjects?offset=0&limit=-1'),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey("data") && jsonResponse["data"] is List) {
          final List<dynamic> subjectsData = jsonResponse["data"];
          print("📡Fetched ${subjectsData.length} subjects");
           print("📄 Subjects Data: $subjectsData");
          // กรองข้อมูลตามปีหลักสูตรที่เลือก
          List<Subject> filteredSubjects =
              subjectsData
                  .map((item) => Subject.fromJson(item))
                  .where((subject) => subject.year == event.courseYear)
                  .toList();

          emit(SubjectsLoaded(subjects: filteredSubjects, selectedValues: {}));
        } else {
          emit(SubjectError("Invalid response format: 'data' field not found"));
        }
      } else {
        emit(SubjectError("Failed to load all subjects"));
      }
    } catch (e) {
      print("❌ Error fetching all subjects: $e");
      emit(SubjectError("Error: $e"));
    }
  }
}
