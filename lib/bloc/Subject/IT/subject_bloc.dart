import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:project/bloc/Subject/IT/subject_repository.dart';
import 'dart:convert';

import 'package:project/modles/subject_model.dart';

part 'subject_event.dart';
part 'subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  final SubjectRepository repository;

  SubjectBloc(this.repository) : super(SubjectInitial()) {
    on<LoadSubjectsEvent>((event, emit) async {
      emit(SubjectLoading());
      try {
        final subjects = await repository.getSubjects(offset: event.offset, limit: event.limit);
        emit(SubjectLoaded(subjects, event.offset));
      } catch (e) {
        emit(SubjectError(e.toString()));
      }
    });
  }
}