part of 'bottom_nav_bloc.dart';

sealed class BottomNavState extends Equatable {
  final int currentIndex;
  const BottomNavState({required this.currentIndex});

  @override
  List<Object> get props => [currentIndex];
}

class BottomNavInitial extends BottomNavState {
  const BottomNavInitial() : super(currentIndex: 1);
}

class CurrentPage extends BottomNavState {
  const CurrentPage({required super.currentIndex});
}
