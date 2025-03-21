part of 'courseyear_bloc.dart';

abstract class CourseyearState extends Equatable {
  const CourseyearState();

  @override
  List<Object?> get props => [];
}

final class CourseyearInitial extends CourseyearState {}

class CourseyearLoading extends CourseyearState {}

class CourseyearLoaded extends CourseyearState {
  final List<Map<String, dynamic>> courses;
  final String? selectedyearCourse;

  const CourseyearLoaded({required this.courses, this.selectedyearCourse});

  @override
  List<Object?> get props => [courses, selectedyearCourse];
}

class CourseyearError extends CourseyearState {
  final String message;

  const CourseyearError(this.message);

  @override
  List<Object?> get props => [message];
}