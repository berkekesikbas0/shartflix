import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../../core/theme/app_theme.dart';
// import '../../../../core/injection/injection.dart';
import '../bloc/movies_bloc.dart';
import '../bloc/movies_event.dart';
import '../bloc/movies_state.dart';
import '../widgets/movie_card.dart';
import '../widgets/loading_indicator.dart';

/// Home page displaying movies in full screen Netflix style
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late PageController _pageController;
  int _currentIndex = 0;
  Set<int> _expandedDescriptions =
      {}; // Track which movie descriptions are expanded

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index, MoviesLoaded state) {
    setState(() {
      _currentIndex = index;
      // Reset expanded descriptions when changing movies
      _expandedDescriptions.clear();
    });

    print('📱 Page changed: index=$index, total=${state.movies.length}');

    // Check if we're at the last movie and trying to go further
    if (index >= state.movies.length - 1) {
      print('🔍 At last movie: index=$index, total=${state.movies.length}');

      // If there are more pages, load them
      if (state.hasNextPage && !state.isLoadingMore) {
        print(
          '🔄 Loading more movies: index=$index, total=${state.movies.length}, hasNextPage=${state.hasNextPage}, isLoadingMore=${state.isLoadingMore}',
        );
        context.read<MoviesBloc>().add(LoadMoreMoviesEvent());
      } else {
        // If no more pages, loop back to the first movie
        print('🔄 Looping back to first movie');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pageController.jumpToPage(0);
        });
      }
    }
  }

  // Add scroll listener to detect when user tries to scroll past the last item
  void _onScroll() {
    final currentState = context.read<MoviesBloc>().state;
    if (currentState is MoviesLoaded) {
      // Check if we're at the last item and user is trying to scroll
      if (_currentIndex >= currentState.movies.length - 1 &&
          currentState.hasNextPage &&
          !currentState.isLoadingMore) {
        print('🔄 Scroll detected at last item, loading more movies');
        context.read<MoviesBloc>().add(LoadMoreMoviesEvent());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<MoviesBloc, MoviesState>(
        listener: (context, state) {
          // Trigger initial load when page opens
          if (state is MoviesInitial) {
            context.read<MoviesBloc>().add(LoadMoviesEvent());
          }
        },
        builder: (context, state) {
          if (state is MoviesInitial || state is MoviesLoading) {
            return _buildInitialLoading();
          } else if (state is MoviesError) {
            return _buildError(state);
          } else if (state is MoviesLoaded) {
            return _buildFullScreenMovies(state);
          } else if (state is MoviesLoadMoreError) {
            return _buildFullScreenMoviesWithError(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInitialLoading() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.netflixRed,
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              'Filmler yükleniyor...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(MoviesError state) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.netflixRed),
              const SizedBox(height: 16),
              const Text(
                'Bir hata oluştu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              if (state.canRetry)
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<MoviesBloc>().add(RetryLoadMoviesEvent());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tekrar Dene'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.netflixRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullScreenMovies(MoviesLoaded state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MoviesBloc>().add(RefreshMoviesEvent());
      },
      color: AppColors.netflixRed,
      backgroundColor: Colors.grey[900],
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) => _onPageChanged(index, state),
        itemCount: state.movies.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final movie = state.movies[index];
          return _buildFullScreenMovieCard(movie, index, state.movies.length);
        },
      ),
    );
  }

  Widget _buildFullScreenMoviesWithError(MoviesLoadMoreError state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MoviesBloc>().add(RefreshMoviesEvent());
      },
      color: AppColors.netflixRed,
      backgroundColor: Colors.grey[900],
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: (index) => _onPageChanged(index, state as MoviesLoaded),
        itemCount: state.movies.length + 1,
        itemBuilder: (context, index) {
          if (index >= state.movies.length) {
            // Error loading more
            return Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, color: AppColors.warning, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Daha fazla film yüklenirken hata oluştu',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MoviesBloc>().add(LoadMoreMoviesEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.netflixRed,
                      ),
                      child: const Text(
                        'Tekrar Dene',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final movie = state.movies[index];
          return _buildFullScreenMovieCard(movie, index, state.movies.length);
        },
      ),
    );
  }

  // Build description with inline "Daha Fazlası" button
  Widget _buildDescriptionWithInlineButton(
    movie,
    int index,
    bool isDescriptionExpanded,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(
          text: movie.description,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14.5.sp,
            height: 1.3,
            letterSpacing: 0.2,
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          maxLines: 2,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        final isTextOverflowing = textPainter.didExceedMaxLines;

        if (isDescriptionExpanded) {
          // Show full text with "Daha Az" button
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14.sp,
                  height: 1.3,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 0.5.h),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedDescriptions.remove(index);
                  });
                },
                child: Text(
                  'Daha Az',
                  style: TextStyle(
                    color: Colors.white.withOpacity(1),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        }

        // Always show "Daha Fazlası" button - regardless of text length
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              movie.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14.sp,
                height: 1.3,
                letterSpacing: 0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 0.5.h),
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedDescriptions.add(index);
                });
              },
              child: Text(
                'Daha Fazlası',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFullScreenMovieCard(movie, int index, int totalMovies) {
    final isDescriptionExpanded = _expandedDescriptions.contains(index);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          // Full screen movie poster
          Positioned.fill(
            child: Image.network(
              movie.posterUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[900],
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.netflixRed,
                      strokeWidth: 3,
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('🖼️ Image loading error for ${movie.posterUrl}: $error');
                return Container(
                  color: Colors.grey[900],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.movie_outlined,
                        size: 80,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        movie.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Görsel yüklenemedi',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Gradient overlay for better text readability - starts lower like in the photo
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.95),
                  ],
                  stops: const [0.0, 0.5, 0.65, 0.75, 0.85, 0.92, 1.0],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 15.h,
            right: 4.w,
            child: GestureDetector(
              onTap: () {
                context.read<MoviesBloc>().add(
                  ToggleMovieFavoriteEvent(
                    movieId: movie.id,
                    isFavorite: !movie.isFavorite,
                  ),
                );
              },
              child: Container(
                width: 13.w,
                height: 9.h,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25.sp),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
          ),

          // Movie information overlay - positioned very close to navbar like in the photo
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                5.w,
                0,
                5.w,
                2.h, // Much lower - closer to navbar
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Netflix logo on left, title and description on right like in photo
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Center logo with content
                    children: [
                      // N LOGO
                      Container(
                        width: 11.w,
                        height: 11.w,
                        margin: EdgeInsets.only(
                          top: 1.h,
                        ), // Push logo down a bit
                        decoration: BoxDecoration(
                          color: AppColors.netflixRed,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 0.4.w),
                        ),
                        child: Center(
                          child: Text(
                            'N',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      // Title and description column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Movie title
                            Text(
                              movie.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            // Movie description with inline "Daha Fazlası" button
                            _buildDescriptionWithInlineButton(
                              movie,
                              index,
                              isDescriptionExpanded,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
