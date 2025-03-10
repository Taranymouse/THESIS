part of 'stdyear_bloc.dart';

sealed class StdyearEvent extends Equatable {
  const StdyearEvent();

  @override
  List<Object?> get props => [];
}

class StdyearSelected extends StdyearEvent {
  final String? selectedStdyear;

  const StdyearSelected(this.selectedStdyear);

  @override
  List<Object?> get props => [selectedStdyear];
}