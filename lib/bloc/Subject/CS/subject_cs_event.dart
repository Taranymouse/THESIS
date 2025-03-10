part of 'subject_cs_bloc.dart';

sealed class SubjectCsEvent extends Equatable {
  const SubjectCsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSubjectsCS extends SubjectCsEvent {}

class UpdateSubjectSelectionCS extends SubjectCsEvent {
  final String subject;
  final String field; // "ภาคการศึกษา", "ปีการศึกษา", หรือ "เกรด"
  final String value;

  const UpdateSubjectSelectionCS(this.subject, this.field, this.value);

  @override
  List<Object?> get props => [subject, field, value];
}