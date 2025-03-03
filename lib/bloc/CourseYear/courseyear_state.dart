part of 'courseyear_bloc.dart';

abstract class CourseyearState extends Equatable {
  const CourseyearState();

  @override
  List<Object?> get props => [];
}

final class CourseyearInitial extends CourseyearState {}

class CourseyearChanged extends CourseyearState {
  final String? selectedCourseyear;

  CourseyearChanged(this.selectedCourseyear);

  @override
  List<Object?> get props => [selectedCourseyear];
}
