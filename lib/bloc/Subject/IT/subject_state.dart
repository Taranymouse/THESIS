part of 'subject_bloc.dart';



abstract class SubjectState {}

class SubjectInitial extends SubjectState {}

class SubjectLoading extends SubjectState {}

class SubjectLoaded extends SubjectState {
  final List<Subject> subjects;
  final int offset;

  SubjectLoaded(this.subjects, this.offset);
}

class SubjectError extends SubjectState {
  final String message;
  SubjectError(this.message);
}
