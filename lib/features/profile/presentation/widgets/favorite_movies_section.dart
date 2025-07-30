import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user_profile_entity.dart';

class FavoriteMoviesSection extends StatelessWidget {
  final List<FavoriteMovieEntity> favoriteMovies;

  const FavoriteMoviesSection({super.key, required this.favoriteMovies});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Container(
          color: AppColors.shartflixBackground,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            'Beğendiğim Filmler',
            style: const TextStyle(
              color: AppColors.shartflixWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Movies Grid or Empty State
        Container(
          color: AppColors.shartflixBackground,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child:
              favoriteMovies.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.6,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: favoriteMovies.length,
                    itemBuilder: (context, index) {
                      final movie = favoriteMovies[index];
                      return _buildMovieCard(movie);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(FavoriteMovieEntity movie) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.shartflixBlack,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie Poster
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                color: AppColors.shartflixBlack,
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: Image.network(
                  movie.posterUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.shartflixDarkGray,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.shartflixRed,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.shartflixDarkGray,
                      child: const Icon(
                        Icons.movie,
                        color: AppColors.shartflixWhite,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Movie Info
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.shartflixBlack,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      color: AppColors.shartflixWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (movie.productionCompany != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      movie.productionCompany!,
                      style: const TextStyle(
                        color: AppColors.shartflixWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 240,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.shartflixDarkGray,
            AppColors.shartflixDarkGray.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.shartflixRed.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shartflixRed.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon Container
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.shartflixRed.withOpacity(0.2),
                  AppColors.shartflixRed.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.shartflixRed.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.favorite_border,
              color: AppColors.shartflixRed,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          // Title with gradient text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Text(
              'Henüz Beğendiğiniz Film Yok',
              style: TextStyle(
                color: AppColors.shartflixWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          // Subtitle with better styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Filmleri beğenmeye başladığınızda\nburada görünecek',
              style: TextStyle(
                color: AppColors.shartflixWhite.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.4,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          // Decorative line
          Container(
            width: 60,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.shartflixRed.withOpacity(0.3),
                  AppColors.shartflixRed.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}
