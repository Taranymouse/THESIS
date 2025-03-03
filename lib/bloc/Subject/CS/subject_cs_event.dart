part of 'subject_cs_bloc.dart';

sealed class SubjectCsEvent extends Equatable {
  const SubjectCsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubjectsCS extends SubjectCsEvent {}