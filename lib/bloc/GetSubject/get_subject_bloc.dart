import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:project/API/api_config.dart';
import 'package:project/modles/session_service.dart';
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

    final offset = event.offset ?? 0;
    final limit = event.limit ?? 10;
    final token = await SessionService().getAuthToken();

    // ✅ ชื่อ param ต้องตรงกับ backend
    final queryParams = {
      'offset': offset.toString(),
      'limit': limit.toString(),
      if (event.courseYear != null) 'course_year': event.courseYear!,
      if (event.branchId != null) 'id_branch': event.branchId!,
    };

    final uri = Uri.parse(
      '$baseUrl/api/subjects',
    ).replace(queryParameters: queryParams);

    try {
      print("📡 Fetching subjects from: $uri");

      if (token == null) {
        emit(SubjectError("Token is null"));
        return;
      }
      
      final response = await http.get(
        uri,
        headers: {"Authorization": "$token"},
      );

      print("📡 Response Body: ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey("data") && jsonResponse["data"] is List) {
          final List<dynamic> subjectsData = jsonResponse["data"];
          List<Subject> subjects =
              subjectsData.map((item) => Subject.fromJson(item)).toList();

          emit(
            SubjectsLoaded(
              subjects: subjects,
              offset: offset,
              limit: limit,
              total: jsonResponse['pagination']['total'],
            ),
          );
        } else {
          emit(SubjectError("Invalid response format"));
        }
      } else {
        emit(SubjectError("Failed to load subjects"));
      }
    } catch (e) {
      print("❌ Error fetching subjects: $e");
      emit(SubjectError("Error: $e"));
    }
  }
}
