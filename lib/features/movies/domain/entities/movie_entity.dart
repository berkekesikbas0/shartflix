import 'package:equatable/equatable.dart';

/// Movie entity representing a movie object in the domain layer
class MovieEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String posterUrl;
  final bool isFavorite;

  const MovieEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
    this.isFavorite = false,
  });

  /// Copy entity with updated values
  MovieEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? posterUrl,
    bool? isFavorite,
  }) {
    return MovieEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [id, title, description, posterUrl, isFavorite];

  @override
  String toString() {
    return 'MovieEntity(id: $id, title: $title, description: $description, posterUrl: $posterUrl, isFavorite: $isFavorite)';
  }
}
