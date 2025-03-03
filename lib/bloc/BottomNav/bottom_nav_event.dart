part of 'bottom_nav_bloc.dart';

abstract class BottomNavEvent extends Equatable {
  const BottomNavEvent();

  @override
  List<Object> get props => [];
}

class ChangePage extends BottomNavEvent {
  final int index;
  ChangePage({required this.index});

  @override
  List<Object> get props => [index];
}