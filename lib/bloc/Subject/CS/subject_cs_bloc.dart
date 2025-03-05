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
    on<UpdateSubjectSelectionCS>((event, emit){
      if (state is SubjectCsLoaded) {
        final currentState = state as SubjectCsLoaded;
        final newSelectedValues = Map<String, Map<String, String>>.from(
          currentState.selectedValues,
        );

        // ถ้ายังไม่มีค่า ให้สร้าง map ใหม่
        if (!newSelectedValues.containsKey(event.subject)) {
          newSelectedValues[event.subject] = {};
        }

        // อัปเดตค่า field ที่เลือก
        newSelectedValues[event.subject]![event.field] = event.value;

        emit(
          SubjectCsLoaded(
            currentState.subjects,
            selectedValues: newSelectedValues,
          ),
        );
      }
    });
  }
}
