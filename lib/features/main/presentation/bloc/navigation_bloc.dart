import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

/// Navigation BLoC for managing bottom navigation state
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigationTabChangedEvent>(_onNavigationTabChanged);
  }

  /// Handle tab change event
  void _onNavigationTabChanged(
    NavigationTabChangedEvent event,
    Emitter<NavigationState> emit,
  ) {
    emit(state.copyWith(selectedIndex: event.selectedIndex));
  }
}
