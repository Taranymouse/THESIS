part of 'get_subject_bloc.dart';

sealed class GetSubjectState extends Equatable {
  const GetSubjectState();
  
  @override
  List<Object?> get props => [];
}

final class ManageSubjectInitial extends GetSubjectState {}

class SubjectLoading extends GetSubjectState {}

class SubjectsLoaded extends GetSubjectState {
  final List<Subject> subjects;
  final Map<String, Map<String, String>> selectedValues;

  SubjectsLoaded({
    required this.subjects,
    Map<String, Map<String, String>>? selectedValues,
  }) : selectedValues = selectedValues ?? {};

  @override
  List<Object?> get props => [subjects, selectedValues];
}



class SubjectError extends GetSubjectState {
  final String message;
  SubjectError(this.message);

  @override
  List<Object?> get props => [message];
}
