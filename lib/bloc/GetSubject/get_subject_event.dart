part of 'get_subject_bloc.dart';

sealed class GetSubjectEvent extends Equatable {
  const GetSubjectEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllSubject extends GetSubjectEvent {
  final String courseYear; // เพิ่ม field นี้
  FetchAllSubject({required this.courseYear}); // รับค่าปีใน constructor

  @override
  List<Object?> get props => [courseYear]; // เพิ่ม props
}

