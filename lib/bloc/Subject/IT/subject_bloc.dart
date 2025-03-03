import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'subject_event.dart';
part 'subject_state.dart';

class SubjectBloc extends Bloc<SubjectEvent, SubjectState> {
  SubjectBloc() : super(SubjectInitial()) {
    on<LoadSubjects>((event, emit) {
      List<String> subjects = [
        '520101 วิชาทดลอง IT',
        '520102 วิชาคณิตศาสตร์ IT',
        '520103 วิชาฟิสิกส์ IT',
        '520104 วิชาเคมี IT',
        '520105 วิชาชีววิทยา IT',
        '520101 วิชาทดลอง IT',
        '520102 วิชาคณิตศาสตร์ IT',
        '520103 วิชาฟิสิกส์ IT',
        '520104 วิชาเคมี IT',
        '520105 วิชาชีววิทยา IT',
        '520101 วิชาทดลอง IT',
        '520102 วิชาคณิตศาสตร์ IT',
        '520103 วิชาฟิสิกส์ IT',
        '520104 วิชาเคมี IT',
        '520105 วิชาชีววิทยา IT',
      ];
      emit(SubjectLoaded(subjects));
    });
  }
}
