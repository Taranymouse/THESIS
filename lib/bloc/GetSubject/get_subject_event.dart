part of 'get_subject_bloc.dart';

sealed class GetSubjectEvent extends Equatable {
  const GetSubjectEvent();
  @override
  List<Object?> get props => [];
}

class FetchAllSubject extends GetSubjectEvent {
  final String courseYear;
  FetchAllSubject({required this.courseYear});

  @override
  List<Object?> get props => [courseYear];
}

// ✅ เพิ่ม event สำหรับอัปเดตค่าที่เลือก
class UpdateSubjectSelection extends GetSubjectEvent {
  final String subject;
  final String field;
  final String value;

  UpdateSubjectSelection(this.subject, this.field, this.value);

  @override
  List<Object?> get props => [subject, field, value];
}
