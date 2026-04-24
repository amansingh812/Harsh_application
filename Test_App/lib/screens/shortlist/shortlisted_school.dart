import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:school_scout/screens/details/school_details_page.dart';
import 'package:school_scout/screens/compare/show_compare_data.dart';
import 'package:school_scout/screens/shortlist/show_shortlist_details.dart';
import 'package:shimmer/shimmer.dart';
import '../../apis/fetch_shortlist_service.dart';
import '../../apis/get_school_setrvice.dart';
import '../../apis/remove_shortlisted_school_service.dart';
import '../../global/global_data.dart';
import '../../apis/api_service.dart';
import '../../helper/shortlist_helper.dart';
import '../../main.dart';
import '../../themes/app_colors.dart';
import '../../widgets/app_elevated_button.dart';
import '../launch/home_loader_screen.dart';

class ShortlistedSchool extends StatefulWidget {
  const ShortlistedSchool({super.key});

  @override
  State<ShortlistedSchool> createState() => _ShortlistedSchoolState();
}

class _ShortlistedSchoolState extends State<ShortlistedSchool> {
  // List<Shortlist> matchedSchools = [];
  bool isLoading = true;

  // List<Shortlist> selectedSchools = [];

  List<User> matchedSchools = [];
  List<User> selectedSchools = [];

  @override
  void initState() {
    super.initState();
    analytics.logScreenView(
      screenName: "ShortListScreen",
    );
    fetchShortlistedSchools();
  }

  Future<void> fetchShortlistedSchools() async {
    final fetchService = FetchShortlistService();
    final getSchoolService = GetSchoolService();

    try {
      setState(() => isLoading = true);

      final response = await fetchService.fetchShortlistData(
        GlobalData().mobNumber.toString(),
      );

      if (response['success'] == true) {
        final List<dynamic> shortlist = response['shortedList'];

        List<User> users = [];

        for (var item in shortlist) {
          final schoolId = item['schoolId'].toString();

          final data = await getSchoolService.fetchUserBySchoolId(schoolId);
          print('School id $schoolId');

          User? user;

          for (final u in data) {
            if (u.id.toString() == schoolId) {
              user = u;
              break;
            }
          }

          if (user != null) {
            user.isLiked = true;
            users.add(user);
          }
        }

        setState(() {
          matchedSchools = users;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }


  // API call to remove the school from the shortlist
  void removeSchool(String schoolId, String userId) async {
    final removeService = RemoveShortlistedSchoolService();
    final result = await removeService.removeShortlistedSchool(
      schoolId: schoolId,
      shortListedBy: userId,
    );

    if (result['success']) {
      print('School removed successfully: ${result['info']}');
      fetchShortlistedSchools();
    } else {
      print('Error: ${result['message']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).colorScheme.primary),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          "Shortlisted Schools",
          style: TextStyle(color: Colors.white),
        ),
      ),
      // inside the build method
      body: isLoading
          ? _buildSkeletonList()
          : matchedSchools.isEmpty
          ? const Center(child: Text('No shortlisted schools found'))
          : ListView.builder(
        // Add padding directly to the ListView
        padding: const EdgeInsets.only(
          left: 12.0,
          right: 12.0,
          top: 12.0,
          bottom: 100.0, // <-- THIS ADDS THE NEEDED SPACE AT THE END
        ),
        itemCount: matchedSchools.length,
        itemBuilder: (context, index) {
          final school = matchedSchools[index];
          return _buildSchoolCard(school);
        },
      ),
      );


      /*   body: isLoading
          ? _buildSkeletonList()
          : Padding(
              padding: const EdgeInsets.all(12),
              child: matchedSchools.isEmpty
                  ? const Center(child: Text('No shortlisted schools found'))
                  : ListView.builder(
                      itemCount: matchedSchools.length,
                      itemBuilder: (context, index) {
                        final school = matchedSchools[index];
                        return _buildSchoolCard(school);

                      },

                    )*/



  }

  Widget _buildSchoolCard(User user) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isSelected = GlobalData().selectedSchools.contains(user);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Card(
        elevation: 8,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= IMAGE + BADGES =================
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    user.galleryImages.isNotEmpty
                        ? Image.network(
                      user.galleryImages.first,
                      key: ValueKey(user.id),
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) {
                        return Image.asset(
                          'assets/images/dummy_image.png',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                        : Image.asset(
                      'assets/images/dummy_image.png',
                      fit: BoxFit.cover,
                    ),

                    // ⭐ Rating badge
                    // Positioned(
                    //   top: 12,
                    //   left: 12,
                    //   child: Container(
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 10, vertical: 6),
                    //     decoration: BoxDecoration(
                    //       color: AppColors.accentGold,
                    //       borderRadius: BorderRadius.circular(16),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.black.withOpacity(0.25),
                    //           blurRadius: 6,
                    //           offset: const Offset(0, 3),
                    //         ),
                    //       ],
                    //     ),
                    //
                    //   ),
                    // ),

                    // Board badge
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          user.boards,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
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
                              _badge(
                                icon: Icons.verified_rounded,
                                label: 'Verified',
                                color: const Color(0xFF2E7D32),
                              ),
                            if (user.verified == 'Y' && user.partner == 'Y')
                              const SizedBox(width: 6),
                            if (user.partner == 'Y')
                              _badge(
                                icon: Icons.handshake_outlined,
                                label: 'Partner',
                                color: AppColors.accentGold,
                              ),
                          ],
                        ),
                      ),

                    // ❤️ Heart (same style as home)
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: ValueListenableBuilder(
                        valueListenable: Hive.box('shortlist').listenable(),
                        builder: (context, box, _) {
                          final isLiked = box.containsKey(user.id);

                          return IconButton(
                            icon: isLiked
                                ? Stack(
                                    alignment: Alignment.center,
                                    children: const [
                                      // White outline (back)
                                      Icon(
                                        Icons.favorite,
                                        size: 26,
                                        color: Colors.white,
                                      ),
                                      // Red heart (front)
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
                              if (!isLiked) return;

                              // UI FIRST (instant)
                              ShortlistHelper.remove(user.id);

                              // API in background
                              RemoveShortlistedSchoolService()
                                  .removeShortlistedSchool(
                                schoolId: user.id,
                                shortListedBy:
                                    GlobalData().mobNumber.toString(),
                              );

                              // Remove from shortlist screen
                              setState(() {
                                matchedSchools
                                    .removeWhere((u) => u.id == user.id);
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ================= BODY =================
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${user.address.area}, ${user.address.city.name}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Chips
                  Row(
                    children: [
                      _chip(user.classesOffered),
                      const SizedBox(width: 8),
                      _chip(user.boards),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ================= Compare + View =================
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            GlobalData().toggleCompare(user);

                            if (GlobalData().selectedSchools.length == 2) {
                              bottomNavKey.currentState?.goToTab(1);
                            }

                            setState(() {});
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SchoolDetailsPage(user: user),
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

  Widget _badge({
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

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _compareButton(bool isSelected) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isSelected ? Colors.green : Colors.grey.shade400,
        ),
        color: isSelected ? Colors.green.withOpacity(0.05) : Colors.white,
      ),
      child: Center(
        child: Text(
          isSelected ? "Selected" : "Compare",
          style: TextStyle(
            color: isSelected ? Colors.green : Colors.grey.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildSkeletonCard();
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shimmerBox(height: 160, radius: 22),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBox(height: 14, width: 180),
                  const SizedBox(height: 8),
                  _shimmerBox(height: 12, width: 140),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _shimmerBox(height: 22, width: 70),
                      const SizedBox(width: 8),
                      _shimmerBox(height: 22, width: 60),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _shimmerBox(height: 42)),
                      const SizedBox(width: 10),
                      Expanded(child: _shimmerBox(height: 42)),
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

  Widget _shimmerBox({
    double height = 12,
    double width = double.infinity,
    double radius = 12,
  }) {
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
}
