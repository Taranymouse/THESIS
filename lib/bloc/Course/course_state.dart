part of 'course_bloc.dart';

sealed class CourseState extends Equatable {
  const CourseState();

  @override
  List<Object?> get props => [];
}

class CourseInitial extends CourseState {}

class CourseLoading extends CourseState {}

class CourseLoaded extends CourseState {
  final List<Map<String, dynamic>> courses;
  final String? selectedCourse;

  const CourseLoaded({required this.courses, this.selectedCourse});

  @override
  List<Object?> get props => [courses, selectedCourse];
}

class CourseError extends CourseState {
  final String message;

  const CourseError(this.message);

  @override
  List<Object?> get props => [message];
}

