class UserProfileEntity {
  final String id;
  final String name;
  final String? profilePhotoUrl;
  final List<FavoriteMovieEntity> favoriteMovies;

  const UserProfileEntity({
    required this.id,
    required this.name,
    this.profilePhotoUrl,
    required this.favoriteMovies,
  });

  UserProfileEntity copyWith({
    String? id,
    String? name,
    String? profilePhotoUrl,
    List<FavoriteMovieEntity>? favoriteMovies,
  }) {
    return UserProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
    );
  }
}

class FavoriteMovieEntity {
  final String id;
  final String title;
  final String? productionCompany;
  final String posterUrl;

  const FavoriteMovieEntity({
    required this.id,
    required this.title,
    this.productionCompany,
    required this.posterUrl,
  });
}
