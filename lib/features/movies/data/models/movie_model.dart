import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/movie_entity.dart';

part 'movie_model.g.dart';

/// Movie data model for API responses
@JsonSerializable()
class MovieModel {
  final String id;
  @JsonKey(name: 'Title')
  final String title;
  @JsonKey(name: 'Plot')
  final String description;
  @JsonKey(name: 'Poster')
  final String posterUrl;

  const MovieModel({
    required this.id,
    required this.title,
    required this.description,
    required this.posterUrl,
  });

  /// Convert from JSON
  factory MovieModel.fromJson(Map<String, dynamic> json) =>
      _$MovieModelFromJson(json);

  /// Convert to JSON
  Map<String, dynamic> toJson() => _$MovieModelToJson(this);

  /// Convert to domain entity
  MovieEntity toEntity({bool isFavorite = false}) {
    return MovieEntity(
      id: id,
      title: title,
      description: description,
      posterUrl: _fixPosterUrl(posterUrl),
      isFavorite: isFavorite,
    );
  }

  /// Fix poster URL protocol and handle common issues
  String _fixPosterUrl(String url) {
    if (url.isEmpty) {
      // Return a placeholder image if URL is empty
      return 'https://via.placeholder.com/300x450/000000/FFFFFF?text=No+Image';
    }

    // Fix http to https
    if (url.startsWith('http://')) {
      url = url.replaceFirst('http://', 'https://');
    }

    // Handle common IMDB poster issues
    if (url.contains('ia.media-imdb.com')) {
      // Replace old IMDB domain with new one
      url = url.replaceAll('ia.media-imdb.com', 'm.media-amazon.com');
    }

    // Ensure URL starts with https
    if (!url.startsWith('https://')) {
      url = 'https://$url';
    }

    return url;
  }

  /// Create from domain entity
  factory MovieModel.fromEntity(MovieEntity entity) {
    return MovieModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      posterUrl: entity.posterUrl,
    );
  }

  @override
  String toString() {
    return 'MovieModel(id: $id, title: $title, description: $description, posterUrl: $posterUrl)';
  }
}
