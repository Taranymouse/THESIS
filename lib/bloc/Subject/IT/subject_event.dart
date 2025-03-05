part of 'subject_bloc.dart';

abstract class SubjectEvent extends Equatable {
  const SubjectEvent();

  @override
  List<Object> get props => [];
}

// ✅ เพิ่มพารามิเตอร์ courseYear เพื่อระบุปีหลักสูตร
class LoadSubjects extends SubjectEvent {
  final String courseYear;

  const LoadSubjects(this.courseYear);

  @override
  List<Object> get props => [courseYear];
}

class UpdateSubjectSelection extends SubjectEvent {
  final String subject;
  final String field;
  final String value;

  const UpdateSubjectSelection(this.subject, this.field, this.value);

  @override
  List<Object> get props => [subject, field, value];
}
