part of 'course_bloc.dart';

sealed class CourseState extends Equatable {
  const CourseState();
  
  @override
  List<Object?> get props => [];
}

final class CourseInitial extends CourseState {}

class CourseChanged extends CourseState {
  final String? selectedCourse;

  const CourseChanged(this.selectedCourse);

  @override
  List<Object?> get props => [selectedCourse];
}
