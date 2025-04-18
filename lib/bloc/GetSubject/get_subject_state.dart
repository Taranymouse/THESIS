part of 'get_subject_bloc.dart';

sealed class GetSubjectState extends Equatable {
  const GetSubjectState();
  
  @override
  List<Object?> get props => [];
}

final class GetSubjectInitial extends GetSubjectState {}

class SubjectLoading extends GetSubjectState {}

class SubjectsLoaded extends GetSubjectState {
  final List<Subject> subjects;
  final int offset;
  final int limit;
  final int total;

  const SubjectsLoaded({
    required this.subjects,
    required this.offset,
    required this.limit,
    required this.total,
  });

  @override
  List<Object?> get props => [subjects, offset, limit, total];
}


class SubjectError extends GetSubjectState {
  final String message;
  SubjectError(this.message);

  @override
  List<Object?> get props => [message];
}
