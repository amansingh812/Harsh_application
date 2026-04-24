import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../apis/api_service.dart';
import '../../apis/get_school_setrvice.dart';
import '../../apis/review_rating_service.dart';
import '../../global/global_data.dart';
import '../../themes/app_colors.dart';

class ReviewWidget extends StatefulWidget {
  final User user;
  final VoidCallback? onReviewSubmitted;
  const ReviewWidget({super.key, required this.user, this.onReviewSubmitted});

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  int _hoverStar = 0;
  int _selectedStar = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;
  bool _submitted = false;
  bool _showAllReviews = false;
  String _loggedInUserId = '';

  // Own reviews state — independent of parent's user object
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = false;

  final _reviewService = ReviewRatingService();

  final List<String> _starLabels = [
    '',
    'Poor',
    'Fair',
    'Good',
    'Very Good',
    'Excellent',
  ];

  @override
  void initState() {
    super.initState();
    print('🏁 ReviewWidget.initState: id=${widget.user.id} existing=${widget.user.reviewsList.length}');
    // Seed from whatever the parent already has
    _reviews = List<Map<String, dynamic>>.from(widget.user.reviewsList);
    // Always fetch fresh — this is the authoritative source
    _fetchReviews();
    _loadLoggedInUser();
  }

  @override
  void didUpdateWidget(ReviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent passed a user with more reviews than we have, adopt them
    if (widget.user.reviewsList.length > _reviews.length) {
      setState(() {
        _reviews = List<Map<String, dynamic>>.from(widget.user.reviewsList);
      });
    }
  }

  Future<void> _fetchReviews() async {
    print('🚀 _fetchReviews CALLED | schoolId=${widget.user.id}');
    if (_isLoadingReviews) return;
    _isLoadingReviews = true;
    try {
      // Use GetSchoolService — fetches THIS school directly by ID
      final service = GetSchoolService();
      final users = await service.fetchUserBySchoolId(widget.user.id);
      print('📡 fetchUserBySchoolId returned ${users.length} users');
      if (!mounted) return;
      if (users.isNotEmpty) {
        final fresh = users.first;
        print('📡 reviews=${fresh.reviewsList.length}');
        if (mounted) {
          setState(() {
            _reviews = List<Map<String, dynamic>>.from(fresh.reviewsList);
          });
        }
      }
    } catch (e, stack) {
      print('❌ ReviewWidget fetch error: $e');
      print('❌ Stack: $stack');
    } finally {
      _isLoadingReviews = false;
    }
  }

  Future<void> _loadLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    if (mounted) setState(() => _loggedInUserId = userId);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    final isGuestUser = prefs.getBool('isGuestUser') ?? false;
    final userId = prefs.getString('userId') ?? '';

    if (isGuestUser || userId.isEmpty) {
      _showLoginPrompt();
      return;
    }

    if (_selectedStar == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a star rating first'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await _reviewService.submitReview(
      schoolId: widget.user.id,
      userId: userId,
      rating: _selectedStar,
      review: _reviewController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      setState(() => _submitted = true);
      widget.onReviewSubmitted?.call();
      // Re-fetch reviews to show the new review in the list
      _fetchReviews();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLoginPrompt() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded,
                  size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Login to Submit a Review',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Share your experience with this school.\nSign in to post a review.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Login / Sign Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _reviews;
    print('📋 ReviewWidget.build: reviews=${reviews.length}');
    const int _previewCount = 5;
    final bool hasMore = reviews.length > _previewCount;
    final displayedReviews = _showAllReviews ? reviews : reviews.take(_previewCount).toList();

    final bool alreadyReviewed = _loggedInUserId.isNotEmpty &&
        reviews.any((r) {
          if (r is! Map) return false;
          return (r['userId']?.toString().trim() ?? '') ==
              _loggedInUserId.trim();
        });

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
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.rate_review_outlined,
                      size: 20, color: Color(0xFFE65100)),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Reviews',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                if (reviews.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${reviews.length} review${reviews.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Existing Reviews ──
            if (reviews.isNotEmpty) ...[
              ...displayedReviews.map((r) => _reviewCard(r)),
              if (hasMore) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() => _showAllReviews = !_showAllReviews),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _showAllReviews
                              ? 'Show less'
                              : 'Show ${reviews.length - _previewCount} more review${reviews.length - _previewCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          _showAllReviews
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade200),
              const SizedBox(height: 12),
            ] else ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Text(
                      'No reviews yet — be the first!',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ],

            // ── Add Review Panel ──
            if (_submitted)
              _successState()
            else if (alreadyReviewed)
              _alreadyReviewedState()
            else
              _addReviewPanel(),
          ],
        ),
      ),
    );
  }

  // ─────────────────── Add Review Panel ───────────────────
  Widget _addReviewPanel() {
    final activeColor = _selectedStar > 0
        ? _starColor(_selectedStar.toDouble())
        : Colors.amber;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rate this School',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'How was your experience?',
            style:
                TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 16),

          // ── Stars ──
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) {
                final star = i + 1;
                final filled =
                    star <= (_hoverStar > 0 ? _hoverStar : _selectedStar);
                return GestureDetector(
                  onTap: () => setState(() => _selectedStar = star),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hoverStar = star),
                    onExit: (_) => setState(() => _hoverStar = 0),
                    child: AnimatedScale(
                      scale: filled ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          filled
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 38,
                          color: filled ? Colors.amber : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // ── Star Label ──
          if (_selectedStar > 0) ...[
            const SizedBox(height: 6),
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _starLabels[_selectedStar],
                  key: ValueKey(_selectedStar),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: activeColor,
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // ── Review Text Field ──
          TextField(
            controller: _reviewController,
            maxLines: 3,
            maxLength: 300,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Share your experience (optional)…',
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              counterStyle: TextStyle(
                  color: Colors.grey.shade400, fontSize: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),

          const SizedBox(height: 12),

          // ── Submit Button ──
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Submit Review',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── Already Reviewed State ───────────────────
  Widget _alreadyReviewedState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0D8FF)),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.rate_review_rounded,
                color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 12),
          const Text(
            'You\'ve Already Reviewed This School',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Thank you for sharing your feedback!\nYour review is visible above.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── Success State ───────────────────
  Widget _successState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(height: 14),
          const Text(
            'Thank you for your Feedback!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your review helps other parents make\nbetter decisions for their child.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // Show the stars they gave
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => Icon(
                i < _selectedStar
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                size: 22,
                color: Colors.amber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────── Review Card ───────────────────
  Widget _reviewCard(dynamic review) {
    if (review is! Map) return const SizedBox.shrink();

    final rawName =
        (review['reviewerName'] ?? review['name'] ?? '').toString().trim();
    final name = rawName.isNotEmpty ? rawName : 'A Parent';
    final comment =
        (review['comment'] ?? review['review'] ?? '').toString();
    final ratingVal = review['rating'] ?? review['stars'];
    final double rating = ratingVal != null
        ? double.tryParse(ratingVal.toString()) ?? 0
        : 0;
    final rawDate = (review['date'] ?? review['createdAt'] ?? '').toString();
    final formattedDate = _formatReviewDate(rawDate);

    if (comment.isEmpty && rating == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar circle
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'A',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    if (rating > 0) ...[
                      const SizedBox(height: 4),
                      _starRow(rating),
                    ],
                    if (formattedDate.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(formattedDate,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(comment,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    height: 1.5)),
          ],
        ],
      ),
    );
  }

  Widget _starRow(double rating) {
    final filled = rating.round().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < filled ? Icons.star_rounded : Icons.star_border_rounded,
          size: 15,
          color: Colors.amber,
        );
      }),
    );
  }

  /// Formats a date string to "13th April 2026" style.
  String _formatReviewDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      DateTime? dt;
      // Try ISO / common formats
      dt = DateTime.tryParse(raw);
      if (dt == null) {
        // Try dd-MM-yyyy or dd/MM/yyyy
        final parts = raw.split(RegExp(r'[-/]'));
        if (parts.length == 3) {
          final a = int.tryParse(parts[0]);
          final b = int.tryParse(parts[1]);
          final c = int.tryParse(parts[2]);
          if (a != null && b != null && c != null) {
            dt = c > 31
                ? DateTime(c, b, a) // dd-MM-yyyy
                : DateTime(a, b, c); // yyyy-MM-dd fallback
          }
        }
      }
      if (dt == null) return raw;
      final day = dt.day;
      final suffix = _ordinal(day);
      const months = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      return '$day$suffix ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  String _ordinal(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  Color _starColor(double r) {
    if (r >= 4) return const Color(0xFF2E7D32);
    if (r >= 3) return const Color(0xFFF57F17);
    return const Color(0xFFC62828);
  }
}
