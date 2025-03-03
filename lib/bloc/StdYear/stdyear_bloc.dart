import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'stdyear_event.dart';
part 'stdyear_state.dart';

class StdyearBloc extends Bloc<StdyearEvent, StdyearState> {
  StdyearBloc() : super(StdyearInitial()) {
    on<StdyearSelected>((event, emit) {
      emit(StdyearChanged(event.selectedStdyear ?? ''));
    });
  }
}
