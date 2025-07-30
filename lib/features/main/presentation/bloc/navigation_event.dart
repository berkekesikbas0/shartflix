import 'package:equatable/equatable.dart';

/// Base navigation event
abstract class NavigationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Tab changed event
class NavigationTabChangedEvent extends NavigationEvent {
  final int selectedIndex;

  NavigationTabChangedEvent(this.selectedIndex);

  @override
  List<Object?> get props => [selectedIndex];
}
