import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:project/modles/subject_model.dart';

part 'get_subject_event.dart';
part 'get_subject_state.dart';

class GetSubjectBloc extends Bloc<GetSubjectEvent, GetSubjectState> {
  final String baseIP = "192.168.1.179";
  late final String baseUrl;

  GetSubjectBloc() : super(GetSubjectInitial()) {
    baseUrl = "http://$baseIP:8000";
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
      
      final response = await http.get(Uri.parse('$baseUrl/subjects'));

      print("✅ Response Status: ${response.statusCode}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List data = json.decode(response.body);

        List<Subject> subjects = data
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
