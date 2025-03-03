part of 'semester_bloc.dart';

abstract class SemesterEvent extends Equatable {
  const SemesterEvent();

  @override
  List<Object?> get props => [];
}

class SemesterSelected extends SemesterEvent {
  final String? selectedSemester;
  
  SemesterSelected(this.selectedSemester);

  @override
  List<Object?> get props => [selectedSemester];
}
