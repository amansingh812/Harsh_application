import 'package:flutter/material.dart';
import '../../apis/api_service.dart';
import '../../themes/app_colors.dart';

class RatingWidget extends StatelessWidget {
  final User user;
  const RatingWidget({super.key, required this.user});

  double get _avgRating =>
      double.tryParse(user.averageRating.isNotEmpty
          ? user.averageRating
          : (user.rating.isNotEmpty ? user.rating : '0')) ??
      0;

  bool get _hasRating => _avgRating > 0;

  @override
  Widget build(BuildContext context) {
    final viewCount = user.totalViewCount.isNotEmpty ? user.totalViewCount : '0';
    final reviewCount = user.reviewsList.length;

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star_rounded,
                      size: 20, color: Color(0xFFF9A825)),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Rating & Views',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Main Stats Row ──
            IntrinsicHeight(
              child: Row(
                children: [
                  // Rating block
                  Expanded(
                    child: _statCard(
                      topWidget: _hasRating
                          ? _bigRatingDisplay(_avgRating)
                          : _noRatingDisplay(),
                      label: _hasRating ? 'Average Rating' : 'Not Rated Yet',
                      bgColor: _hasRating
                          ? const Color(0xFFFFF8E1)
                          : const Color(0xFFF8F9FF),
                      borderColor: _hasRating
                          ? Colors.amber.shade200
                          : Colors.grey.shade200,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Views block
                  Expanded(
                    child: _statCard(
                      topWidget: _viewsDisplay(viewCount),
                      label: 'Profile Views',
                      bgColor: const Color(0xFFE3F2FD),
                      borderColor: const Color(0xFFBBDEFB),
                    ),
                  ),
                ],
              ),
            ),

            if (reviewCount > 0) ...[
              const SizedBox(height: 12),
              _reviewCountBanner(reviewCount),
            ],

            if (_hasRating) ...[
              const SizedBox(height: 16),
              _starBreakdown(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required Widget topWidget,
    required String label,
    required Color bgColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          topWidget,
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bigRatingDisplay(double rating) {
    return Column(
      children: [
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: _ratingColor(rating),
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        _starsRow(rating, size: 16),
      ],
    );
  }

  Widget _noRatingDisplay() {
    return Column(
      children: [
        const Icon(Icons.star_border_rounded,
            size: 36, color: Colors.grey),
        const SizedBox(height: 2),
        Text(
          '–',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _viewsDisplay(String count) {
    return Column(
      children: [
        const Icon(Icons.visibility_outlined,
            size: 28, color: Color(0xFF1565C0)),
        const SizedBox(height: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1565C0),
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _reviewCountBanner(int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0D8FF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_outline,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$count parent${count > 1 ? 's have' : ' has'} reviewed this school',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _starBreakdown() {
    // Static display – 5 star bars based on average rating
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Rating Breakdown',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(5, (i) {
          final star = 5 - i;
          final filled = _avgRating >= star;
          final partial =
              !filled && _avgRating > star - 1 && _avgRating < star;
          final fraction =
              partial ? (_avgRating - (star - 1)).clamp(0.0, 1.0) : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: Row(
              children: [
                SizedBox(
                  width: 14,
                  child: Text(
                    '$star',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star_rounded,
                    size: 14, color: Colors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          color: Colors.grey.shade200,
                        ),
                        FractionallySizedBox(
                          widthFactor:
                              filled ? 1.0 : (partial ? fraction : 0.0),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: _ratingColor(_avgRating),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _starsRow(double rating, {double size = 14}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = rating >= i + 1;
        final half = !filled && rating > i && rating < i + 1;
        return Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_border_rounded,
          size: size,
          color: Colors.amber,
        );
      }),
    );
  }

  Color _ratingColor(double r) {
    if (r >= 4) return const Color(0xFF2E7D32);
    if (r >= 3) return const Color(0xFFF57F17);
    return const Color(0xFFC62828);
  }
}
