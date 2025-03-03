import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'course_event.dart';
part 'course_state.dart';

class CourseBloc extends Bloc<CourseEvent, CourseState> {
  CourseBloc() : super(CourseInitial()) {
    on<CourseSelected>((event, emit) {
      emit(CourseChanged(event.selectedCourse ?? ''));
    });
  }
}
