part of 'subject_bloc.dart';

abstract class SubjectEvent {}

class LoadSubjectsEvent extends SubjectEvent {
  final int offset;
  final int limit;
  LoadSubjectsEvent({required this.offset, required this.limit});
}
