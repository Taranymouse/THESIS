import 'package:flutter_bloc/flutter_bloc.dart';

class GradeSelectionCubit extends Cubit<Map<int, String>> {
  GradeSelectionCubit() : super({});

  void updateGrade(int subjectId, String grade) {
    final updated = Map<int, String>.from(state);
    updated[subjectId] = grade;
    emit(updated);
  }

  int countPassedSubjects() {
    return state.values.where((grade) => grade == 'A' || grade == 'B').length;
  }
}
