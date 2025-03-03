part of 'stdyear_bloc.dart';

sealed class StdyearState extends Equatable {
  const StdyearState();

  @override
  List<Object?> get props => [];
}

final class StdyearInitial extends StdyearState {}

class StdyearChanged extends StdyearState {
  final String? selectedStdyear;

  StdyearChanged(this.selectedStdyear);
  
  @override
  List<Object?> get props => [selectedStdyear];
}
