import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:school_scout/global/global_data.dart';
import 'package:school_scout/screens/child_profile/add_child_profile.dart';
import 'package:school_scout/screens/child_profile/update_child_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../apis/fetch_child_details_service.dart';
import '../../widgets/brand_loader.dart';

class ShowChildDetails extends StatefulWidget {
  const ShowChildDetails({super.key});

  @override
  State<ShowChildDetails> createState() => _ShowChildDetailsState();
}

class _ShowChildDetailsState extends State<ShowChildDetails>
    with SingleTickerProviderStateMixin {
  List<ChildDetails> childDetails = [];
  bool isLoading = true;
  bool hasError = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
    fetchChildDetails();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchChildDetails() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId') ?? '';
      final api = ChildDetailsAPI();
      List<ChildDetails> fetchedDetails =
      await api.getChildDetails(userId: userId);
      setState(() {
        childDetails = fetchedDetails;
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      debugPrint("Child fetch failed: $e");

      setState(() {
        isLoading = false;
        hasError = false;     // 👈 never show error screen
        childDetails = [];   // treat as empty state
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 2,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: primary,
          statusBarIconBrightness: Brightness.light,
        ),
        title: const Text(
          'My Children',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BrandLoader(text: ""),
            const SizedBox(height: 16),
            Text(
              'Loading child profiles...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      )
          : _buildContent(primary),

    );
  }

  Widget _buildErrorState(Color primary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Failed to Load',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to fetch child profiles. Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: fetchChildDetails,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color primary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
            .animate(_animationController),
        child: FadeTransition(
          opacity: _animationController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Child Button
              _buildAddChildButton(primary),
              const SizedBox(height: 28),

              // Header
              // Header
              if (childDetails.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Children',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${childDetails.length} child${childDetails.length > 1 ? 'ren' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

              if (childDetails.isEmpty)
                _buildEmptyState(primary)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: childDetails.length,
                  itemBuilder: (context, index) {
                    final child = childDetails[index];
                    return _buildChildCard(context, child, primary);
                  },
                ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddChildButton(Color primary) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddChildProfile()),
        );
        if (result == true) {
          fetchChildDetails();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primary.withOpacity(0.3), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Add New Child',
              style: TextStyle(
                color: primary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color primary) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.child_care, size: 40, color: primary),
            ),
            const SizedBox(height: 20),
            Text(
              'No Children Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your child\'s profile to get\npersonalized school recommendations',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddChildProfile()),
                );
                if (result == true) {
                  fetchChildDetails();
                }
              },
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add Child Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildCard(
      BuildContext context, ChildDetails child, Color primary) {
    DateTime dob = DateTime.parse(child.dob);
    String formattedDob = DateFormat('dd MMM yyyy').format(dob);
    String childImage = child.gender == 'Male'
        ? 'assets/images/boy.png'
        : 'assets/images/girl.png';

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateChildDetails(childDetails: child),
          ),
        );
        if (result == true) {
          fetchChildDetails();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: primary.withOpacity(0.2), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    childImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Child Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${child.firstName} ${child.lastName ?? ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.cake_outlined,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          formattedDob,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Gender Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            child.gender ?? 'Unknown',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Class Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Class: ${child.admissionClass ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: primary.withOpacity(0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}