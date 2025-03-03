part of 'semester_bloc.dart';

abstract class SemesterState extends Equatable {
  const SemesterState();

  @override
  List<Object?> get props => [];
}

final class SemesterInitial extends SemesterState {}

class SemesterChanged extends SemesterState {
  final String? selectedSemester;

  SemesterChanged(this.selectedSemester);

  @override
  List<Object?> get props => [selectedSemester];
}
