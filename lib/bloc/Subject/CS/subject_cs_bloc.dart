import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'subject_cs_event.dart';
part 'subject_cs_state.dart';

class SubjectCsBloc extends Bloc<SubjectCsEvent, SubjectCsState> {
  SubjectCsBloc() : super(SubjectCsInitial()) {
    on<LoadSubjectsCS>((event, emit) {
      List<String> subjects = [
        '520101 วิชาทดลอง CS',
        '520102 วิชาคณิตศาสตร์ CS',
        '520103 วิชาฟิสิกส์ CS',
        '520104 วิชาเคมี CS',
        '520105 วิชาชีววิทยา CS',
      ];
      emit(SubjectCsLoaded(subjects));
    });
  }
}
