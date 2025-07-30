import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.id,
    required super.name,
    super.profilePhotoUrl,
    required super.favoriteMovies,
  });

  // API response mapping
  factory UserProfileModel.fromApiResponse(Map<String, dynamic> json) {
    // API response'u data objesi içinde döndürüyor
    final data = json['data'] as Map<String, dynamic>;

    // Handle photoUrl - make sure we convert empty string to null
    final photoUrl = data['photoUrl'] as String?;
    final normalizedPhotoUrl =
        (photoUrl == null || photoUrl.isEmpty) ? null : photoUrl;

    print('📋 Profile data from API - photoUrl: "$photoUrl"');

    return UserProfileModel(
      id: data['id'] as String,
      name: data['name'] as String,
      profilePhotoUrl: normalizedPhotoUrl,
      favoriteMovies: [], // Favori filmler ayrı API'den gelecek
    );
  }
}

class FavoriteMovieModel extends FavoriteMovieEntity {
  const FavoriteMovieModel({
    required super.id,
    required super.title,
    super.productionCompany,
    required super.posterUrl,
  });

  factory FavoriteMovieModel.fromJson(Map<String, dynamic> json) {
    return FavoriteMovieModel(
      id: json['id'] as String,
      title: json['title'] as String,
      productionCompany: json['productionCompany'] as String?,
      posterUrl: json['posterUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'productionCompany': productionCompany,
      'posterUrl': posterUrl,
    };
  }
}
