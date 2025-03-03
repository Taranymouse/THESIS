part of 'courseyear_bloc.dart';

abstract class CourseyearEvent extends Equatable {
  const CourseyearEvent();

  @override
  List<Object?> get props => [];
}

class CourseyearSelected extends CourseyearEvent {
  final String? selectedCourseyear;

  const CourseyearSelected(this.selectedCourseyear);

  @override
  List<Object?> get props => [selectedCourseyear];
}
