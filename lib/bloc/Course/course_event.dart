part of 'course_bloc.dart';

sealed class CourseEvent extends Equatable {
  const CourseEvent();

  @override
  List<Object?> get props => [];
}

class LoadCourses extends CourseEvent {}


class CourseSelected extends CourseEvent {
  final String? selectedCourse;

  const CourseSelected(this.selectedCourse);

  @override
  List<Object?> get props => [selectedCourse];
}
