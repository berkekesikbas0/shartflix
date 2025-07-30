import 'dart:async';
import 'package:injectable/injectable.dart';

/// Global event bus for cross-BLoC communication
@singleton
class EventBusService {
  final StreamController<dynamic> _controller =
      StreamController<dynamic>.broadcast();

  Stream<T> on<T>() =>
      _controller.stream.where((event) => event is T).cast<T>();

  void emit(dynamic event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}

/// Event for favorite movies update
class FavoriteMoviesUpdatedEvent {
  final List<dynamic> favoriteMovies;

  FavoriteMoviesUpdatedEvent(this.favoriteMovies);
}
