part of 'subject_bloc.dart';

abstract class SubjectState extends Equatable {
  const SubjectState();

  @override
  List<Object?> get props => [];
}

class SubjectInitial extends SubjectState {}

class SubjectLoading extends SubjectState {} // ✅ สถานะโหลดข้อมูล

class SubjectLoaded extends SubjectState {
  final List<String> subjects;
  final Map<String, Map<String, String>> selectedValues;

  SubjectLoaded({
    required this.subjects,
    Map<String, Map<String, String>>? selectedValues,
  }) : selectedValues = selectedValues ?? {};

  @override
  List<Object?> get props => [subjects, selectedValues];
}

class SubjectError extends SubjectState { // ✅ สถานะเมื่อเกิดข้อผิดพลาด
  final String message;
  const SubjectError(this.message);

  @override
  List<Object?> get props => [message];
}
