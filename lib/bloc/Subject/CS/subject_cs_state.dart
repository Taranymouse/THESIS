part of 'subject_cs_bloc.dart';

sealed class SubjectCsState extends Equatable {
  const SubjectCsState();
  
  @override
  List<Object?> get props => [];
}

final class SubjectCsInitial extends SubjectCsState {}

class SubjectCsLoaded extends SubjectCsState {
  final List<String> subjects;

  SubjectCsLoaded(this.subjects);

  @override
  List<Object?> get props => [subjects];
}