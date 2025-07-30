import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Loading indicator widget for different loading states
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool isSmall;

  const LoadingIndicator({super.key, this.message, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: isSmall ? 24 : 40,
            height: isSmall ? 24 : 40,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: isSmall ? 2 : 3,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: isSmall ? 8 : 16),
            Text(
              message!,
              style:
                  isSmall
                      ? theme.textTheme.bodySmall
                      : theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Shimmer loading placeholder for movie cards
class MovieCardShimmer extends StatefulWidget {
  const MovieCardShimmer({super.key});

  @override
  State<MovieCardShimmer> createState() => _MovieCardShimmerState();
}

class _MovieCardShimmerState extends State<MovieCardShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[900],
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment(-1.0 - _animation.value, 0.0),
                end: Alignment(1.0 + _animation.value, 0.0),
                colors: [
                  Colors.grey[900]!,
                  Colors.grey[800]!,
                  Colors.grey[900]!,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
