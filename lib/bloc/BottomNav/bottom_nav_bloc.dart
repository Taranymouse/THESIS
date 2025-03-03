import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'bottom_nav_event.dart';
part 'bottom_nav_state.dart';

class BottomNavBloc extends Bloc<BottomNavEvent, BottomNavState> {
  BottomNavBloc() : super(CurrentPage(currentIndex: 1)) {
    on<ChangePage>((event, emit) {
      emit(CurrentPage(currentIndex: event.index));
    });
  }
}
