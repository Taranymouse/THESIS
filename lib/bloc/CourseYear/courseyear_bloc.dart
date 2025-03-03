import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'courseyear_event.dart';
part 'courseyear_state.dart';

class CourseyearBloc extends Bloc<CourseyearEvent, CourseyearState> {
  CourseyearBloc() : super(CourseyearInitial()) {
    on<CourseyearSelected>((event, emit) {
      emit(CourseyearChanged(event.selectedCourseyear ?? ''));
    });
  }
}
