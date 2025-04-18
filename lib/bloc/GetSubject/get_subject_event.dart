part of 'get_subject_bloc.dart';

sealed class GetSubjectEvent extends Equatable {
  const GetSubjectEvent();
  @override
  List<Object?> get props => [];
}

class FetchAllSubject extends GetSubjectEvent {
  final String? courseYear;
  final int? offset;
  final int? limit;
  final String? searchQuery;
  final String? branchId;

  FetchAllSubject({
    this.courseYear,
    this.offset,
    this.limit,
    this.searchQuery,
    this.branchId,
  });

  @override
  List<Object?> get props => [courseYear, offset, limit, searchQuery, branchId];
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
