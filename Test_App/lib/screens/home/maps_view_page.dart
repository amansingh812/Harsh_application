import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:location/location.dart' as loc;
import 'package:school_scout/constants/pin_code_constants.dart';
import 'package:school_scout/hive/mappers/user_hive_to_user.dart';
import 'package:school_scout/hive/mappers/user_to_hive_mapper.dart';
import 'package:school_scout/screens/details/school_details_page.dart';
import 'package:school_scout/screens/home/most_shortlisted_widget.dart';
import 'package:school_scout/screens/home/recent_searched_widget.dart';
import 'package:school_scout/screens/other/search_page.dart';
import 'package:school_scout/widgets/app_elevated_button.dart';
import 'package:school_scout/widgets/brand_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../apis/api_service.dart';
import '../../apis/master_api_dart.dart';
import '../../apis/remove_shortlisted_school_service.dart';
import '../../apis/service/master_sync_service.dart';
import '../../apis/shortlist_api_call.dart';
import '../../global/global_data.dart';
import '../../global/location_notifier.dart';
import '../../helper/shortlist_helper.dart';
import '../../hive/models/user_hive.dart';
import '../../themes/app_colors.dart';
import '../../widgets/banner_ad_widget.dart';
import '../../widgets/location_modal.dart';
import '../launch/home_loader_screen.dart';
import '../login/login_page.dart';

List<Map<String, dynamic>> globalSchoolData = [];

class MapsViewPage extends StatefulWidget {
  @override
  _MapsViewPageState createState() => _MapsViewPageState();
}

class _MapsViewPageState extends State<MapsViewPage> {
  String _selectedLocation = 'Bangalore';
  String _selectedValue = 'Day School';
  bool isLiked = false;
  bool isLoading = false;
  late ApiService apiService;
  late MasterApi masterApi;
  final ShortlistApiCall shortlistApiCall = ShortlistApiCall();
  static Position? _currentPosition;
  double kBottomNavHeight = 86;
  late final VoidCallback _listener;
  BannerAdWidget bannerAd = const BannerAdWidget();
  late Future<List<User>> futureUsers;
  List<User> filteredSchools = [];
  late Future<void> userFuture;
  late Box<UserHive> schoolBox;
  String mobileNumber = GlobalData().mobNumber.toString();
  int schoolCount = 0;
  List<User> selectedSchools = [];
  final shortlistBox = Hive.box('shortlist');

  final TextEditingController _citySelectionController =
      TextEditingController();
  bool showSkeleton = false;

  @override
  void initState() {
    super.initState();
    _citySelectionController.text =
        GlobalData().city.isNotEmpty ? GlobalData().city : "Bangalore";
    schoolBox = Hive.box<UserHive>('schools');
    apiService = ApiService();

    _loadHomeFromCache();
    _loadMasterIfNeeded();
    GlobalData.homeDataReady.addListener(_onHomeDataReady);
    _listener = () {
      _reloadData();
    };
    LocationNotifier.refresh.addListener(_listener);
    _reloadData();
  }

  void _onHomeDataReady() {
    if (!mounted) return;
    if (GlobalData().users.isNotEmpty) {
      setState(() {
        showSkeleton = false;
        _loadHomeFromCache();
      });
    }
  }

  void _loadHomeFromCache() async {
    if (GlobalData().users.isNotEmpty) {
      setState(() {
        showSkeleton = false;
        filteredSchools = List.from(GlobalData().users);
        schoolCount = filteredSchools.length;
      });
      return;
    }

    final pincode = GlobalData().pincode;
    final cached =
        schoolBox.values.where((e) => e.address.pincode == pincode).toList();

    if (cached.isNotEmpty) {
      setState(() {
        showSkeleton = false;
        GlobalData().users = cached.map((e) => e.toUser()).toList();
        filteredSchools = List.from(GlobalData().users);
        schoolCount = filteredSchools.length;
      });
      return;
    }

    setState(() {
      showSkeleton = true;
    });
  }

  Future<void> _loadMasterIfNeeded() async {
    try {
      debugPrint('🔄 Syncing master data (Hive + Firestore)');
      await MasterSyncService.sync();
      debugPrint('✅ Master data ready');
    } catch (e) {
      debugPrint('❌ Master sync failed: $e');
    }
  }

  Widget _buildSkeletonList() {
    return SizedBox(
      height: 360,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) => _buildSkeletonCard(),
      ),
    );
  }

  Widget _buildSkeletonCard() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.83;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(height: 160, radius: 22),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(height: 14, width: cardWidth * 0.6),
                  const SizedBox(height: 8),
                  _shimmerBox(height: 12, width: cardWidth * 0.4),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _shimmerBox(height: 20, width: 70),
                      const SizedBox(width: 8),
                      _shimmerBox(height: 20, width: 60),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _shimmerBox(height: 40)),
                      const SizedBox(width: 10),
                      Expanded(child: _shimmerBox(height: 40)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(
      {double height = 12,
      double width = double.infinity,
      double radius = 12}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1200),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }

  Future<void> _fetchDataAfterCityChange() async {
    try {
      showSkeleton = true;
      final String city = GlobalData().city;
      final String pincode = GlobalData().pincode;

      GlobalData().users = [];
      final cached = schoolBox.values.where((e) {
        return e.address.city.name == city && e.address.pincode == pincode;
      }).toList();

      if (cached.isNotEmpty) {
        GlobalData().users = cached.map((e) => e.toUser()).toList();
        schoolCount = GlobalData().users.length;
        _filterSchools(_selectedValue);
        // Fetch in background to get fresh data (reviewsList, averageRating, dashboard sections).
        // Re-filter so filteredSchools points at the NEW User objects (which carry reviewsList).
        apiService.fetchUser(pincode).then((_) {
          if (mounted) _filterSchools(_selectedValue);
        }).catchError((_) {});
        return;
      }

      final users = await apiService.fetchUser(pincode);
      GlobalData().users = users;
      schoolCount = GlobalData().users.length;
      _filterSchools(_selectedValue);

      final hiveMap = {for (final user in users) user.id: user.toHive()};
      await schoolBox.putAll(hiveMap);
    } catch (e) {
      debugPrint('❌ Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          showSkeleton = false; // 👈 skeleton off when data ready
        });
      }
    }
  }

  void _filterSchools(String type) {
    final String currentPincode = GlobalData().pincode;
    setState(() {
      filteredSchools = GlobalData().users.where((school) {
        final matchesPincode =
            school.address.pincode.trim() == currentPincode.trim();
        final matchesFormat =
            school.format.toLowerCase().contains(type.toLowerCase());
        return matchesPincode && matchesFormat;
      }).toList();
      schoolCount = filteredSchools.length;
    });
  }

  @override
  void dispose() {
    GlobalData.homeDataReady.removeListener(_onHomeDataReady);
    LocationNotifier.refresh.removeListener(_listener);
    _citySelectionController.dispose();
    super.dispose();
  }

  Future<void> _reloadData() async {
    await _fetchDataAfterCityChange();
  }

  void _refreshDashboardSections() {
    final pincode = GlobalData().pincode;
    apiService.fetchUser(pincode).then((_) {
      if (mounted) _filterSchools(_selectedValue);
    }).catchError((_) {});
  }

  void _showLocationModal() async {
    String? selectedLocation = await LocationModal.show(context);

    if (selectedLocation != null && selectedLocation.isNotEmpty) {
      setState(() {
        showSkeleton = true; // 👈 skeleton on
        filteredSchools.clear();
        schoolCount = 0;
      });

      GlobalData().city = selectedLocation;
      _citySelectionController.text = selectedLocation;

      await _fetchDataAfterCityChange();
    }
  }

  Widget _buildLoadingOverlay() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const BrandLoader(
          size: 80,
          showText: true,
          text: "Loading schools…",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Theme.of(context).colorScheme.primary,
          statusBarIconBrightness: Brightness.light,
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: GestureDetector(
          onTap: _showLocationModal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('LOCATION',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text(GlobalData().city,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down,
                      color: Colors.white, size: 18),
                ],
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              bottomNavKey.currentState?.goToTab(3);
              /*final prefs = await SharedPreferences.getInstance();
              final isGuestUser = prefs.getBool('isGuestUser') ?? false;

              if (!mounted) return;   // 🔥 VERY IMPORTANT

              // 🔐 Profile protection
              if (isGuestUser) {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );

              } else {

                bottomNavKey.currentState?.goToTab(3);

              }*/
            },

            child: const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Image(
                  image: AssetImage('assets/images/man.png'),
                  width: 40,
                  height: 40),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(context),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: kBottomNavHeight),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroHeader(colorScheme),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //_buildModeChipsStrip(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                size: 18,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Top Rated Schools',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 2),
                                Text(
                                  'Find the best schools near you',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          bottomNavKey.currentState?.goToTab(2);
                        },
                        child: Row(
                          children: [
                            Text('View All',
                                style: TextStyle(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13)),
                            const SizedBox(width: 4),
                            Icon(Icons.arrow_forward_ios,
                                size: 13, color: colorScheme.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (showSkeleton)
                  _buildSkeletonList()
                else if (filteredSchools.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48.0),
                      child: Column(
                        children: [
                          Icon(Icons.school_outlined,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text("No schools found",
                              style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text("Try selecting a different school type",
                              style: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 13)),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 360,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredSchools.length > 7
                          ? 7
                          : filteredSchools.length,
                      itemBuilder: (context, index) =>
                          _buildSchoolCard(filteredSchools[index]),
                    ),
                  ),
                const SizedBox(height: 20),

                //  const SizedBox(height: 28),
                if (!showSkeleton && filteredSchools.isNotEmpty) ...[
                 /* Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          bottomNavKey.currentState
                              ?.goToTab(2); // School List tab
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26)),
                          elevation: 6,
                          shadowColor: colorScheme.primary.withOpacity(0.4),
                        ),
                        child: const Text('Explore all schools',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: 0.3)),
                      ),
                    ),
                  ),*/
                  const SizedBox(height: 28),

                  // ── Most Shortlisted ──
                  if (GlobalData().mostShortedSchools.isNotEmpty) ...[
                    MostShortlistedWidget(
                      schools: GlobalData().mostShortedSchools,
                      onDetailsReturned: _refreshDashboardSections,
                    ),
                    const SizedBox(height: 28),
                  ],

                  // ── Recently Viewed ──
                  if (GlobalData().recentSearchedSchools.isNotEmpty) ...[
                    RecentSearchedWidget(
                      schools: GlobalData().recentSearchedSchools,
                      onDetailsReturned: _refreshDashboardSections,
                    ),
                    const SizedBox(height: 28),
                  ],

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE7F6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.compare_arrows_rounded,
                            size: 18,
                            color: Color(0xFF4527A0),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Popular Comparisons',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'Compare top schools side by side',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 240,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: GlobalData().users.isEmpty
                          ? 0
                          : 6.clamp(0, GlobalData().users.length),
                      itemBuilder: (context, index) {
                        final schoolA = GlobalData()
                            .users[index % GlobalData().users.length];
                        final schoolB = GlobalData()
                            .users[(index + 1) % GlobalData().users.length];
                        return ComparisonCard(
                            schoolA: schoolA, schoolB: schoolB);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const BannerAdWidget(),
                  const SizedBox(height: 12),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        bottomNavKey.currentState?.goToTab(1);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [AppColors.primary, AppColors.accentGold],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Compare Schools Now',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.3),
                        ),
                      ),
                    ),
                  ),
                ],

               const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroHeader(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _AnimatedHeadline(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const SearchPage()));
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: const Row(
                      children: [
                        Icon(Icons.search, color: Colors.black54, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Search schools, curriculum…',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500)),
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
    );
  }

  Widget _buildModeChipsStrip() {
    return Transform.translate(
      offset: const Offset(0, -12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          children: [
            _buildOptionButton('assets/images/bus.png', 'Day School'),
            const SizedBox(width: 10),
            _buildOptionButton('assets/images/year.png', 'Day Cum Boarding'),
            const SizedBox(width: 10),
            _buildOptionButton('assets/images/school-bag.png', 'Full Boarding'),
            const SizedBox(width: 10),
            _buildOptionButton('assets/images/game.png', 'Disable Friendly'),
          ],
        ),
      ),
    );
  }

  ElevatedButton _buildOptionButton(String imagePath, String label) {
    final isSelected = _selectedValue == label;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: isSelected ? AppColors.accentGold : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
              width: 1.5),
        ),
        elevation: isSelected ? 6 : 2,
        shadowColor: isSelected
            ? AppColors.accentGold.withOpacity(0.4)
            : Colors.black.withOpacity(0.1),
      ),
      onPressed: () {
        setState(() {
          _selectedValue = label;
          _filterSchools(_selectedValue);
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imagePath, height: 26, width: 32),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSchoolCard(User user) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.83;
    final bool isSelected = GlobalData().selectedSchools.contains(user);
    final liked = ShortlistHelper.isLiked(user);

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black12,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      user.galleryImages.isNotEmpty
                          ? user.galleryImages[0]
                          : 'assets/images/dummy_image.png',
                      key: ValueKey(user.id),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        return progress == null
                            ? child
                            : Image.asset("assets/images/dummy_image.png",
                                fit: BoxFit.cover);
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset("assets/images/dummy_image.png",
                            fit: BoxFit.cover);
                      },
                    ),
                    /*Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.accentGold, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 6, offset: const Offset(0, 3))]),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                   */ /* const Icon(Icons.star, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('4.8', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 12)),*/ /*
                  ],
                ),
              ),
            ),*/
                    // Board badge — top right
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16)),
                        child: Text(user.boards,
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                    // Views badge — top left
                    if (user.views.isNotEmpty && user.views != '0')
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.remove_red_eye_outlined,
                                  size: 12, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                user.views,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Verified / Partner badges — bottom left
                    if (user.verified == 'Y' || user.partner == 'Y')
                      Positioned(
                        bottom: 10,
                        left: 12,
                        child: Row(
                          children: [
                            if (user.verified == 'Y')
                              _schoolBadge(
                                icon: Icons.verified_rounded,
                                label: 'Verified',
                                color: const Color(0xFF2E7D32),
                              ),
                            if (user.verified == 'Y' && user.partner == 'Y')
                              const SizedBox(width: 6),
                            if (user.partner == 'Y')
                              _schoolBadge(
                                icon: Icons.handshake_outlined,
                                label: 'Partner',
                                color: AppColors.accentGold,
                              ),
                          ],
                        ),
                      ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: IconButton(
                        icon: ShortlistHelper.isLiked(user)
                            ? const Stack(
                                alignment: Alignment.center,
                                children: const [
                                  // White border
                                  Icon(
                                    Icons.favorite,
                                    size: 26,
                                    color: Colors.white,
                                  ),
                                  // Red fill
                                  Icon(
                                    Icons.favorite,
                                    size: 22,
                                    color: Colors.red,
                                  ),
                                ],
                              )
                            : const Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                                size: 24,
                              ),
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final isLoggedIn =
                              prefs.getBool('isLoggedIn') ?? false;
                          ;
                          final isGuestUser =
                              prefs.getBool('isGuestUser') ?? false;
                          ;

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
                              shortListedBy: mobileNumber,
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
                              mobileNumber: mobileNumber,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                            '${user.address.area}, ${user.address.city.name}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16)),
                        child: Text(user.classesOffered,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w500)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16)),
                        child: Text(user.boards,
                            style: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            GlobalData().toggleCompare(user);

                            // 🚀 Auto-open ONLY when 2 schools selected
                            if (GlobalData().selectedSchools.length == 2) {
                              bottomNavKey.currentState?.goToTab(1); // 👈 THIS
                            }

                            setState(() {}); // only rebuild UI
                          },
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.primary.withOpacity(0.06)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: isSelected
                                    ? colorScheme.primary
                                    : Colors.grey.shade400,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  size: 18,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Compare',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? colorScheme.primary
                                        : Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppElevatedButton(
                          onPressed: () {
                            // Always use the freshest User from GlobalData so
                            // reviewsList / averageRating / totalViewCount are populated.
                            final fresh = GlobalData().users.firstWhere(
                              (u) => u.id == user.id,
                              orElse: () => user,
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    SchoolDetailsPage(user: fresh),
                              ),
                            );
                          },
                          text: 'View Details',
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          buttonSize: ButtonSize.large,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _schoolBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10, color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  getCurrentLocation() async {
    loc.Location location = loc.Location();

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();

      if (!serviceEnabled) {
        print("User denied enabling GPS.");
        _setDefaultLocation();
        return;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _setDefaultLocation();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _setDefaultLocation();
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    _currentPosition = position;
    List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude, _currentPosition!.longitude);

    var address = '';
    if (placemarks.isNotEmpty) {
      var streets = placemarks.reversed
          .map((placemark) => placemark.street)
          .where((street) => street != null);

      streets = streets.where((street) =>
          street!.toLowerCase() !=
          placemarks.reversed.last.locality!.toLowerCase());
      streets = streets.where((street) => !street!.contains('+'));

      address += streets.join(', ');
      address += ', ${placemarks.reversed.last.subLocality ?? ''}';
      address += ', ${placemarks.reversed.last.locality ?? ''}';
      address += ', ${placemarks.reversed.last.subAdministrativeArea ?? ''}';
      address += ', ${placemarks.reversed.last.administrativeArea ?? ''}';
      address += ', ${placemarks.reversed.last.postalCode ?? ''}';
      address += ', ${placemarks.reversed.last.country ?? ''}';
      print(address);
      GlobalData().pincode = placemarks.reversed.last.postalCode?.trim() ?? '';
      GlobalData().city = placemarks.reversed.last.locality?.trim() ?? '';
      print('PINCODE FROM MAPS ${GlobalData().pincode}');
    }
  }
}

void _setDefaultLocation() {
  final String cityPincode = _getPinCodeFromCity(GlobalData().city);
  GlobalData().city = GlobalData().city;
  GlobalData().pincode = cityPincode;
  print(
      "Using default location: Pincode - ${GlobalData().pincode}, City - ${GlobalData().city}");
}

class ComparisonCard extends StatelessWidget {
  final User? schoolA;
  final User? schoolB;

  const ComparisonCard({
    Key? key,
    this.schoolA,
    this.schoolB,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 320,
      child: GestureDetector(
        onTap: () {
          if (schoolA != null && schoolB != null) {
            GlobalData().selectedSchools
              ..clear()
              ..add(schoolA!)
              ..add(schoolB!);

            bottomNavKey.currentState?.goToTab(1);
          }
        },
        child: Card(
          elevation: 6,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _miniSchoolTile(context, schoolA)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 36),
                          Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withOpacity(0.75),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Text(
                              'VS',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: _miniSchoolTile(context, schoolB)),
                  ],
                ),
              ),
              // Tap to compare hint
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app_rounded,
                        size: 13, color: theme.colorScheme.primary),
                    const SizedBox(width: 5),
                    Text(
                      'Tap to compare',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _miniSchoolTile(BuildContext context, User? school) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 90,
                child: Image.network(
                  school != null && school.galleryImages.isNotEmpty
                      ? school.galleryImages[0]
                      : 'assets/images/dummy_image.png',
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) => progress == null
                      ? child
                      : Image.asset('assets/images/dummy_image.png',
                          fit: BoxFit.cover, width: double.infinity, height: 90),
                  errorBuilder: (_, __, ___) => Image.asset(
                      'assets/images/dummy_image.png',
                      fit: BoxFit.cover, width: double.infinity, height: 90),
                ),
              ),
              // Board badge
              if (school != null && school.boards.isNotEmpty)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      school.boards,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          school?.name ?? 'Add School',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.3),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on_outlined, size: 11, color: Colors.grey.shade500),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                school?.address.area ?? '',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

String _getPinCodeFromCity(String city) {
  final match = PinCodeConstants.cities.firstWhere(
    (c) => c.city.toLowerCase() == city.toLowerCase(),
    orElse: () => const CityInfo(
      city: 'Bangalore',
      pincode: '560001',
      state: 'Karnataka',
    ),
  );

  return match.pincode;
}

// Add this function inside _MapsViewPageState class
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

// Helper widget for benefits
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

// ─────────────────────────────────────────────────────────────────────────────
//  Animated headline  ("Find the  [cycling phrase]  near you")
// ─────────────────────────────────────────────────────────────────────────────
class _AnimatedHeadline extends StatefulWidget {
  const _AnimatedHeadline();

  @override
  State<_AnimatedHeadline> createState() => _AnimatedHeadlineState();
}

class _AnimatedHeadlineState extends State<_AnimatedHeadline> {
  static const _phrases = [
    'best schools',
    'top-rated schools',
    'CBSE schools',
    'ICSE schools',
    'affordable schools',
    'verified schools',
  ];

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() => _index = (_index + 1) % _phrases.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const whiteStyle = TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      height: 1.3,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Find the', style: whiteStyle),
        SizedBox(
          height: 36,
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              layoutBuilder: (currentChild, previousChildren) => Stack(
                alignment: Alignment.centerLeft,
                children: [
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              ),
              child: RichText(
                key: ValueKey(_index),
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _phrases[_index],
                      style: const TextStyle(
                        color: AppColors.accentGold,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const TextSpan(text: ' near you', style: whiteStyle),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
