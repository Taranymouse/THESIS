import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'semester_event.dart';
part 'semester_state.dart';

class SemesterBloc extends Bloc<SemesterEvent, SemesterState> {
  SemesterBloc() : super(SemesterInitial()) {
    on<SemesterSelected>((event, emit) {
      emit(SemesterChanged(event.selectedSemester ?? ''));
    });
  }
}
