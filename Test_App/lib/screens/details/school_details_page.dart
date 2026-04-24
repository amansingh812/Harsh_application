import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:school_scout/screens/details/review_screen.dart';
import 'package:school_scout/screens/details/fees_structure_widget.dart';
import 'package:school_scout/screens/details/admission_process_widget.dart';
import 'package:school_scout/screens/details/review_widget.dart';
import 'package:school_scout/screens/details/rating_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../apis/remove_shortlisted_school_service.dart';
import '../../apis/shortlist_api_call.dart';
import '../../global/global_data.dart';
import '../../apis/api_service.dart';
import '../../apis/get_school_setrvice.dart';
import '../../helper/shortlist_helper.dart';
import '../../main.dart';
import '../../widgets/full_screen_gallery.dart';
import '../../widgets/native_ads_widget.dart';
import '../compare/show_compare_data.dart';
import '../launch/home_loader_screen.dart';
import '../login/login_page.dart';

class SchoolDetailsPage extends StatefulWidget {
  final User user;

  const SchoolDetailsPage({super.key, required this.user});

  @override
  State<SchoolDetailsPage> createState() => _SchoolDetailsPageState();
}

class _SchoolDetailsPageState extends State<SchoolDetailsPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _showAllFacilities = false;
  bool _showFullAbout = false;
  List<User> filteredUsers = [];
  final ShortlistApiCall shortlistApiCall = ShortlistApiCall();
  int _currentHeroIndex = 0;
  late PageController _heroPageController;
  Timer? _heroAutoScrollTimer;
  Timer? _searchDebounce;
  bool _isUserScrolling = false;
  Timer? _resumeAutoScrollTimer;
  late User _currentUser;



  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    // Background refresh so reviews/ratings are always fresh
    _refreshUserData();
    analytics.logScreenView(
      screenName: "SchoolDetailsScreen",
    );
    _searchController.addListener(() {
      final query = _searchController.text.trim().toLowerCase();

      _searchDebounce?.cancel();
      _searchDebounce = Timer(
        const Duration(milliseconds: 350),
            () {
          if (!mounted) return;

          if (query.isEmpty || query.length < 3) {
            setState(() => filteredUsers.clear());
            return;
          }

          setState(() {
            filteredUsers = GlobalData().users.where((user) {
              return user.name.toLowerCase().contains(query);
            }).toList();
          });
        },
      );
    });

    _heroPageController = PageController();

    _heroAutoScrollTimer = Timer.periodic(
      const Duration(seconds: 4),
          (_) {
        if (!mounted) return;
        if (_isUserScrolling) return;
        if (_currentUser.galleryImages.length <= 1) return;

        _currentHeroIndex =
            (_currentHeroIndex + 1) % _currentUser.galleryImages.length;

        _heroPageController.animateToPage(
          _currentHeroIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
    );

  }

  Future<void> _refreshUserData() async {
    print('🔄 _refreshUserData CALLED | schoolId=${widget.user.id}');
    try {
      // Use GetSchoolService (searchschoolById) — fetches THIS school directly
      // instead of ApiService.fetchUser which fetches ALL schools by pincode.
      final service = GetSchoolService();
      final users = await service.fetchUserBySchoolId(widget.user.id);
      print('✅ fetchUserBySchoolId returned ${users.length} users');
      if (users.isNotEmpty) {
        print('   ↳ reviews=${users.first.reviewsList.length} rating=${users.first.averageRating}');
      }
      if (!mounted) return;
      if (users.isNotEmpty) {
        setState(() => _currentUser = users.first);
      }
    } catch (e, stack) {
      print('❌ REFRESH ERROR: $e');
      print('❌ STACK: $stack');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _heroAutoScrollTimer?.cancel();
    _searchDebounce?.cancel();
    _heroPageController.dispose();
    super.dispose();
  }

/*  void _openFullScreenGallery(List<String> images, int startIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              '${startIndex + 1} / ${images.length}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: PageView.builder(
            controller: PageController(initialPage: startIndex),
            itemCount: images.length,
            itemBuilder: (_, index) {
              return InteractiveViewer(
                child: Center(
                  child: Image.network(
                    images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        "assets/images/dummy_image.png",
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }*/
  void _openFullScreenGallery(List<String> images, int startIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenGallery(
          images: images,
          startIndex: startIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User selectedUser = _currentUser;
    final bool isCompared = GlobalData().selectedSchools.contains(selectedUser);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        leading: Container(
          margin: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
       /* actions: [
          _buildCircleIcon(Icons.share),
          const SizedBox(width: 8),
        ],*/
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ====== SCROLLABLE GALLERY ======
            SizedBox(
              height: 280,
              width: double.infinity,
              child: _buildGallery(selectedUser),
            ),

            // ====== SCROLLABLE CONTENT ======
            Container(
              color: const Color(0xFFF4F6FB),
              child: Column(
                children: [
                  // ====== FLOATING SCHOOL CARD ======
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildTopSchoolCard(selectedUser, isCompared),
                    ),
                  ),

                // ====== ABOUT SECTION ======
                if (selectedUser.showFees == 'Y') ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildAboutSection(selectedUser),
                  ),
                  const SizedBox(height: 16),
                ],

                // ====== KEY HIGHLIGHTS ======
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildHighlightsSection(selectedUser),
                ),
                const SizedBox(height: 16),

                // ====== SCHOOL DETAILS ======
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildAcademicSection(selectedUser),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: NativeAdWidget(),
                ),

                // ====== FEES STRUCTURE (only if showFees == 'Y') ======
                if (selectedUser.showFees == 'Y') ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FeesStructureWidget(user: selectedUser),
                  ),
                  const SizedBox(height: 16),
                ],

                // ====== ADMISSION PROCESS (only if addmissionEnabled == 'Y') ======
                if (selectedUser.addmissionEnabled == 'Y') ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: AdmissionProcessWidget(user: selectedUser),
                  ),
                  const SizedBox(height: 16),
                ],

                // ====== FACILITIES ======
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildFacilitiesSection(selectedUser),
                ),
                const SizedBox(height: 16),

                // ====== CONTACT INFORMATION ======
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildContactSection(selectedUser),
                ),
                const SizedBox(height: 16),

                // ====== RATING & VIEWS ======
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: RatingWidget(user: selectedUser),
                ),
                const SizedBox(height: 16),

                // ====== REVIEWS ======
                Padding(

                  padding: const EdgeInsets.symmetric(horizontal: 16.0),

                  child: ReviewWidget(
                    key: ValueKey(_currentUser.reviewsList.length), // 🔥 ADD THIS
                    user: selectedUser,
                    onReviewSubmitted: _refreshUserData,
                  ),
                ),

                if (selectedUser.verified != 'Y') ...[
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD6E0FF)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Color(0xFF3568FF),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      'This information is compiled from schools, public sources, and user inputs. '
                                      'Details may change—please verify with the school directly before proceeding.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ],

                const SizedBox(height: 32),

              ],
            ),
          ),
        ],
      ),
      ),
    );
  }

  // ─────────────────── Gallery Widget ───────────────────
  Widget _buildGallery(User user) {
    return Stack(
      children: [
        // PageView
        PageView.builder(
          controller: _heroPageController,
          onPageChanged: (index) {
            setState(() {
              _currentHeroIndex = index;
              _isUserScrolling = true;
              _resumeAutoScrollTimer?.cancel();
              _resumeAutoScrollTimer =
                  Timer(const Duration(seconds: 3), () {
                _isUserScrolling = false;
              });
            });
          },
          itemCount:
              user.galleryImages.isNotEmpty ? user.galleryImages.length : 1,
          itemBuilder: (context, index) {
            final bool hasImages = user.galleryImages.isNotEmpty;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (hasImages) {
                  _openFullScreenGallery(user.galleryImages, index);
                }
              },
              child: hasImages
                  ? Image.network(
                      user.galleryImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/dummy_image.png',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/dummy_image.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
            );
          },
        ),

        // Gradient overlay
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black38, Colors.transparent],
                ),
              ),
            ),
          ),
        ),

        // Dots indicator
        if (user.galleryImages.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  user.galleryImages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentHeroIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentHeroIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ─────────────────── About Section ───────────────────
  Widget _buildAboutSection(User user) {
    const int maxLines = 3;
    final text = user.about.trim();
    const textStyle = TextStyle(fontSize: 13, color: Color(0xFF424242), height: 1.6);

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline_rounded,
                      size: 20, color: Color(0xFF1565C0)),
                ),
                const SizedBox(width: 10),
                const Text(
                  'About',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            if (text.isNotEmpty) ...[
              const SizedBox(height: 12),
              // Use LayoutBuilder to measure whether text overflows 3 lines
              LayoutBuilder(
                builder: (context, constraints) {
                  final tp = TextPainter(
                    text: TextSpan(text: text, style: textStyle),
                    maxLines: maxLines,
                    textDirection: TextDirection.ltr,
                  )..layout(maxWidth: constraints.maxWidth);
                  final overflows = tp.didExceedMaxLines;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedCrossFade(
                        firstChild: Text(
                          text,
                          maxLines: maxLines,
                          overflow: TextOverflow.ellipsis,
                          style: textStyle,
                        ),
                        secondChild: Text(text, style: textStyle),
                        crossFadeState: _showFullAbout
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 200),
                      ),
                      if (overflows) ...[
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _showFullAbout = !_showFullAbout),
                          child: Text(
                            _showFullAbout ? 'Show less' : 'Show more',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCircleIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 4, right: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: () {},
      ),
    );
  }

  Widget _buildTopSchoolCard(User user, bool isCompared) {
    final theme = Theme.of(context);

    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Board Chip + Rating Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildChip(
                  label: user.boards.isNotEmpty ? user.boards : 'BOARD',
                  bg: theme.colorScheme.primary,
                  fg: Colors.white,
                ),
                // Right side: rating + views
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Average Rating badge (show only if rating exists)
                    if (user.averageRating.isNotEmpty &&
                        double.tryParse(user.averageRating) != null &&
                        double.parse(user.averageRating) > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              double.parse(user.averageRating)
                                  .toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    // Views badge
                    if (user.totalViewCount.isNotEmpty &&
                        user.totalViewCount != '0')
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFD0D8FF)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.visibility_outlined,
                                size: 13,
                                color: Color(0xFF162E8B)),
                            const SizedBox(width: 4),
                            Text(
                              user.totalViewCount,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF162E8B),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Verified & Partner Badges
            if (user.verified == 'Y' || user.partner == 'Y') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (user.verified == 'Y')
                    _infoBadge(
                      icon: Icons.verified_rounded,
                      label: 'Verified School',
                      bg: const Color(0xFFE8F5E9),
                      fg: const Color(0xFF2E7D32),
                    ),
                  if (user.verified == 'Y' && user.partner == 'Y')
                    const SizedBox(width: 8),
                  if (user.partner == 'Y')
                    _infoBadge(
                      icon: Icons.handshake_outlined,
                      label: 'Our Partner',
                      bg: const Color(0xFFFFF8E1),
                      fg: const Color(0xFFF9A825),
                    ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // School Name
            Text(
              user.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 8),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.redAccent),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${user.address.address1}, ${user.address.address2}, ${user.address.city.name} - ${user.address.pincode}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Divider
            Divider(height: 1, color: Colors.grey.shade200),

            const SizedBox(height: 12),

            // Actions Row
            Row(
              children: [
                // Compare Checkbox
                Expanded(
                  child: InkWell(
                    onTap: () => _toggleCompare(user, !isCompared),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: isCompared,
                              onChanged: (value) => _toggleCompare(user, value),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Compare',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Shortlist Button
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF9C623),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final isLoggedIn =
                            prefs.getBool('isLoggedIn') ?? false;
                        ;
                        final isGuestUser =
                            prefs.getBool('isGuestUser') ?? false;
                        ;
                        final mobileNumber = prefs.getString('phoneNumber');

                        if (isGuestUser == true) {
                          _showLoginPromptBottomSheet(context, user);
                          return;
                        }

                        final isLiked = ShortlistHelper.isLiked(user);

                        if (isLiked) {
                          // ❤️ REMOVE (UI first)
                          ShortlistHelper.remove(user.id);

                          setState(() {}); // instant UI update

                          // API call (background)
                          RemoveShortlistedSchoolService()
                              .removeShortlistedSchool(
                            schoolId: user.id,
                            shortListedBy: mobileNumber.toString(),
                          );
                        } else {
                          // ❤️ ADD (UI first)
                          ShortlistHelper.add(user.id);

                          setState(() {}); // instant UI update

                          // API call (background)
                          shortlistApiCall.shortList(
                            schoolId: user.id,
                            schoolName: user.name,
                            pinCode: user.address.pincode,
                            areaName: user.address.area,
                            state: user.address.state,
                            district: user.address.district,
                            city: user.address.city.name,
                            mobileNumber: mobileNumber.toString(),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            ShortlistHelper.isLiked(user)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Shortlist',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightsSection(User user) {
    return _sectionCard(
      iconAsset: 'assets/images/back-to-school.png',
      title: 'Key Highlights',
      child: Column(
        children: [
          const SizedBox(height: 12),
          GridView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.0,
            ),
            children: [
              _highlightTile(
                'Ownership',
                user.ownership,
                bgColor: const Color(0xFFEFF3FF),
              ),
              _highlightTile(
                'Co-ed Status',
                user.coedStatus,
                bgColor: const Color(0xFFFFEEF7),
                valueColor: const Color(0xFFB23AA6),
              ),
              _highlightTile(
                'Board',
                user.boards,
                bgColor: const Color(0xFFEFFFF4),
                valueColor: const Color(0xFF10A15B),
              ),
              _highlightTile(
                'Campus Size',
                user.builtInArea,
                bgColor: const Color(0xFFFFF3E5),
                valueColor: const Color(0xFFEB6B27),
              ),
              _highlightTile(
                'Established',
                user.yearOfEstablishment,
                bgColor: const Color(0xFFEFF3FF),
              ),
              _highlightTile(
                'Profile Views',
                user.totalViewCount.isNotEmpty ? user.totalViewCount : user.views,
                bgColor: const Color(0xFFFFEEF0),
                valueColor: const Color(0xFFE05252),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _highlightTile(
      String title,
      String value, {
        Color? bgColor,
        Color? valueColor,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor ?? Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isNotEmpty ? value : '-',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicSection(User user) {
    final theme = Theme.of(context);

    return _sectionCard(
      iconAsset: 'assets/images/school.png',
      title: 'School Details',
      child: Column(
        children: [
          const SizedBox(height: 16),
          _schoolDetailRow(
            'Classes Offered',
            user.classesOffered,
            valueStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          _divider(),
          _schoolDetailRow('Student Count', user.numberOfStudents),
          _divider(),
          _schoolDetailRow('Student–Faculty Ratio', user.studentTeacherRatio),
          _divider(),
          _schoolDetailRow('Medium', user.medium),
          _divider(),
          _schoolDetailRow('School Format', user.format),
          _divider(),
          _schoolDetailRow('Languages Taught', user.languagesTaught.join(', ')),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.shade200,
      ),
    );
  }

  Widget _schoolDetailRow(
      String label,
      String value, {
        TextStyle? valueStyle,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 5,
          child: Text(
            value.isNotEmpty ? value : '-',
            textAlign: TextAlign.right,
            style: valueStyle ??
                const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildFacilitiesSection(User user) {
    final facilities = user.featureFacilities;

    return _sectionCard(
      iconAsset: 'assets/images/amenities.png',
      title: 'Facilities',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          ...facilities
              .where((group) => group.features.isNotEmpty)
              .map((group) => _buildFacilityGroup(group))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildFacilityGroup(FeatureFacility group) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Header
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                group.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Facility Grid
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: group.features.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (_, index) {
              return _facilityCard(group.features[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _facilityCard(Feature feature) {
    final bool available = feature.exist == 'Yes';
    final Color statusColor = available ? const Color(0xFF1DBF73) : Colors.red;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            available ? Icons.check_circle : Icons.cancel,
            color: statusColor,
            size: 20,
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              feature.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            available ? 'AVAILABLE' : 'NOT AVAILABLE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

/*  Widget _buildContactSection(User user) {
    return _sectionCard(
      iconAsset: 'assets/images/map.png',
      title: 'Contact Information',
      child: Column(
        children: [
          const SizedBox(height: 16),
          _contactInfoTile(
            iconBg: const Color(0xFFE5F9ED),
            icon: Icons.phone,
            label: 'Phone Number',
            value: user.phoneNo,
            onTap: () => _makePhoneCall(user.phoneNo),
          ),
          const SizedBox(height: 12),
          _contactInfoTile(
            iconBg: const Color(0xFFE5F0FF),
            icon: Icons.public,
            label: 'Website',
            value: user.website,
            isLink: true,
            onTap: () => _launchURL(user.website),
          ),
          const SizedBox(height: 12),
          _contactInfoTile(
            iconBg: const Color(0xFFEAF2FF),
            icon: Icons.mail_outline,
            label: 'Email',
            value: user.email,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }*/

  Widget _buildContactSection(User user) {
    return _sectionCard(
      iconAsset: 'assets/images/map.png',
      title: 'Contact Information',
      child: Column(
        children: [
          const SizedBox(height: 16),

          // ✅ ADDRESS TILE (NEW)
          _contactInfoTile(
            iconBg: const Color(0xFFEAF2FF),
            icon: Icons.location_on,
            label: 'Address',
            value:
            '${user.address.address1}, ${user.address.address2}, ${user.address.city.name}, ${user.address.state} - ${user.address.pincode}',
            isLink: true,
            onTap: () => _openMaps(user),
          ),

          const SizedBox(height: 12),

          _contactInfoTile(
            iconBg: const Color(0xFFE5F9ED),
            icon: Icons.phone,
            label: 'Phone Number',
            value: user.phoneNo,
            onTap: () => _makePhoneCall(user.phoneNo),
          ),

          const SizedBox(height: 12),

          _contactInfoTile(
            iconBg: const Color(0xFFE5F0FF),
            icon: Icons.public,
            label: 'Website',
            value: user.website,
            isLink: true,
            onTap: () => _launchURL(user.website),
          ),

          const SizedBox(height: 12),

          _contactInfoTile(
            iconBg: const Color(0xFFEAF2FF),
            icon: Icons.mail_outline,
            label: 'Email',
            value: user.email,
            isLink: true,
            onTap: () => _sendEmail(user.email),
          ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }


  Widget _contactInfoTile({
    required Color iconBg,
    required IconData icon,
    required String label,
    required String value,
    bool isLink = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value.isNotEmpty ? value : '-',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isLink ? const Color(0xFF3568FF) : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String iconAsset,
    required String title,
    required Widget child,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(iconAsset, width: 24, height: 24),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            child,
          ],
        ),
      ),
    );
  }

  Widget _infoBadge({
    required IconData icon,
    required String label,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required Color bg,
    required Color fg,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  /*Future<void> _openMaps(User user) async {
    final address =
        '${user.address.address1}, ${user.address.address2}, ${user.address.city.name}, ${user.address.state}, ${user.address.pincode}';

    final encodedAddress = Uri.encodeComponent(address);

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      final appleMaps = Uri.parse('http://maps.apple.com/?q=$encodedAddress');
      await launchUrl(appleMaps, mode: LaunchMode.externalApplication);
    } else {
      final googleMaps = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$encodedAddress');
      await launchUrl(googleMaps, mode: LaunchMode.externalApplication);
    }
  }*/
  Future<void> _openMaps(User user) async {
    final address =
        '${user.address.address1}, ${user.address.address2}, ${user.address.city.name}, ${user.address.state}, ${user.address.pincode}';

    final encodedAddress = Uri.encodeComponent(address);

    final googleMapsApp = Uri.parse('comgooglemaps://?q=$encodedAddress');
    final googleMapsWeb = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress');
    final appleMaps = Uri.parse('http://maps.apple.com/?q=$encodedAddress');

    if (Theme.of(context).platform == TargetPlatform.iOS) {
      showCupertinoModalPopup(
        context: context,
        builder: (_) => CupertinoActionSheet(
          title: const Text("Open in Maps"),
          message: const Text("Choose your preferred map app"),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                if (await canLaunchUrl(googleMapsApp)) {
                  await launchUrl(googleMapsApp);
                } else {
                  await launchUrl(googleMapsWeb,
                      mode: LaunchMode.externalApplication);
                }
              },
              child: const Text("Google Maps"),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                await launchUrl(appleMaps,
                    mode: LaunchMode.externalApplication);
              },
              child: const Text("Apple Maps"),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            isDefaultAction: true,
            child: const Text("Cancel"),
          ),
        ),
      );
    } else {
      // Android → direct Google Maps
      await launchUrl(googleMapsWeb,
          mode: LaunchMode.externalApplication);
    }
  }


  Future<void> _sendEmail(String email) async {
    if (email.isEmpty) return;

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    await launchUrl(emailUri, mode: LaunchMode.externalApplication);
  }


  /*void _toggleCompare(User user, bool? value) {
    setState(() {
      if (value == true) {
        if (GlobalData().selectedSchools.length < 2) {
          GlobalData().selectedSchools.add(user);
        }
      } else {
        GlobalData().selectedSchools.remove(user);
      }

      if (GlobalData().selectedSchools.length == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ShowCompareData(
              selectedSchool1: GlobalData().selectedSchools[0],
              selectedSchool2: GlobalData().selectedSchools[1],
            ),
          ),
        );
      }
    });
  }*/
  void _toggleCompare(User user, bool? value) {
    setState(() {
      GlobalData().toggleCompare(user);
      if (value == true) {
        if (!GlobalData().selectedSchools.contains(user) &&
            GlobalData().selectedSchools.length < 2) {
          GlobalData().selectedSchools.add(user);
        }
      } else {
        GlobalData().selectedSchools.remove(user);
      }

      // 🚀 Auto-open ONLY when 2 schools are selected
      if (GlobalData().selectedSchools.length == 2) {
        bottomNavKey.currentState?.goToTab(1); // Compare tab
      }
    });
  }



  _launchURL(url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }
}
void _showLoginPromptBottomSheet(BuildContext context, User user) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    isScrollControlled: true,
    builder: (_) {
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Heart Icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.red,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),

            Text(
              "Sign in to Save Schools",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "Create an account to save your favorite schools and access them anytime across all devices.",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Benefits section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildBenefitRow(
                    Icons.bookmark_added_outlined,
                    "Save unlimited schools",
                    theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  _buildBenefitRow(
                    Icons.compare_arrows_outlined,
                    "Compare schools easily",
                    theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 10),
                  _buildBenefitRow(
                    Icons.notifications_active_outlined,
                    "Get admission updates",
                    theme.colorScheme.primary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Sign In Button
            // Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet

                  // Login page par le jao
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  "Sign In to Continue",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                "Maybe Later",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
Widget _buildBenefitRow(IconData icon, String text, Color color) {
  return Row(
    children: [
      Icon(icon, size: 20, color: color),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    ],
  );
}

