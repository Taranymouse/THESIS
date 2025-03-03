part of 'subject_bloc.dart';

abstract class SubjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubjectInitial extends SubjectState {}

class SubjectLoaded extends SubjectState {
  final List<String> subjects;

  SubjectLoaded(this.subjects);

  @override
  List<Object?> get props => [subjects];
}

