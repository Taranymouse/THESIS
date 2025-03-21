import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'courseyear_event.dart';
part 'courseyear_state.dart';

class CourseyearBloc extends Bloc<CourseyearEvent, CourseyearState> {
  CourseyearBloc() : super(CourseyearInitial()) {
    on<CourseyearSelected>(_onCourseSelected);
  }

    void _onCourseSelected(CourseyearSelected event, Emitter<CourseyearState> emit) {
    if (state is CourseyearLoaded) {
      final loadedState = state as CourseyearLoaded;
      emit(CourseyearLoaded(
        courses: loadedState.courses,
        selectedyearCourse: event.selectedCourseyear,
      ));
    }
  }
}
