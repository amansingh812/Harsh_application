import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:school_scout/global/global_data.dart';
import '../../apis/add_user_additional_details_service.dart';
import '../../apis/get_user_additional_details_service.dart';
import '../../main.dart';
import '../../widgets/about_screen_dropdown.dart';
import '../../widgets/brand_loader.dart';

class ProfileAboutScreen extends StatefulWidget {
  const ProfileAboutScreen({super.key});

  @override
  State<ProfileAboutScreen> createState() => _ProfileAboutScreenState();
}

class _ProfileAboutScreenState extends State<ProfileAboutScreen>
    with SingleTickerProviderStateMixin {
  String? selectedIncome;
  String? selectedCity;
  String? selectedRole;
  String? selectedOccupation;
  String? selectedQualification;
  String? selectedClass;
  String? selectedAcademic;
  String? selectedState;

  bool isSubmitButtonEnabled = false;
  bool isLoading = false;
  bool isSubmitting = false;
  String userId = GlobalData().userId.toString();
  late AnimationController _animationController;

  final AddUserAdditionalDetailsService apiService =
  AddUserAdditionalDetailsService();
  final UserAdditionalDetailsAPI userAdditionalDetailsAPI =
  UserAdditionalDetailsAPI();

  @override
  void initState() {
    super.initState();
    analytics.logScreenView(
      screenName: "AboutProfileScreen",
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
    _fetchUserAdditionalDetails();
  }

  Future<void> _submitUserDetails() async {
    await apiService.submitUserAdditionalDetails(
      userId: userId,
      qualification: selectedQualification ?? '',
      userCat: selectedRole ?? '',
      admissionCategory: selectedClass ?? '',
      occupation: selectedOccupation ?? '',
      annualIncome: selectedIncome ?? '',
      sessionPeriod: selectedAcademic ?? '',
      state: selectedState ?? '',
      city: selectedCity ?? '',
      locality: '',
      landmark: '',
      dob: '',
    );
  }

  Future<void> _fetchUserAdditionalDetails() async {
    setState(() => isLoading = true);
    try {
      final details = await userAdditionalDetailsAPI.getUserAdditionalDetails(
        userId: userId,
      );

      if (details != null) {
        selectedQualification =
        GlobalData().qualification.contains(details['qualification'])
            ? details['qualification']
            : null;

        selectedClass =
        GlobalData().getCourseNames().contains(details['addmissionCategory'])
            ? details['addmissionCategory']
            : null;

        selectedIncome = GlobalData().annualIncome.contains(details['annualIncome'])
            ? details['annualIncome']
            : null;

        selectedOccupation =
        GlobalData().occupations.contains(details['occupation'])
            ? details['occupation']
            : null;

        selectedAcademic = GlobalData()
            .getAcademicSession()
            .contains(details['sessionPeriod'])
            ? details['sessionPeriod']
            : null;

        selectedState = GlobalData().states.contains(details['state'])
            ? details['state']
            : null;

        if (selectedState != null) {
          selectedCity = (GlobalData().citiesByState[selectedState] ?? [])
              .contains(details['city'])
              ? details['city']
              : null;
        }

        checkIfAllDropdownsSelected();
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 2,
        title: const Text(
          'Tell us about yourself',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
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
            BrandLoader(text: ""),
            Text(
              'Loading your profile...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
              .animate(_animationController),
          child: FadeTransition(
            opacity: _animationController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(primary),
                const SizedBox(height: 28),

                // Form Container
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Qualification
                      _fieldSection(
                        icon: Icons.school_outlined,
                        label: "Qualification",
                        dropdown: AboutScreenDropdown(
                          label: "Please select",
                          items: GlobalData().qualification,
                          selectedItem: selectedQualification,
                          onChanged: (value) {
                            setState(() {
                              selectedQualification = value;
                              checkIfAllDropdownsSelected();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Annual Income
                      _fieldSection(
                        icon: Icons.account_balance_wallet_outlined,
                        label: "Annual Income",
                        dropdown: AboutScreenDropdown(
                          label: "Please select",
                          items: GlobalData().annualIncome,
                          selectedItem: selectedIncome,
                          onChanged: (value) {
                            setState(() {
                              selectedIncome = value;
                              checkIfAllDropdownsSelected();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Occupation
                      _fieldSection(
                        icon: Icons.work_outline,
                        label: "Occupation",
                        dropdown: AboutScreenDropdown(
                          label: "Please select",
                          items: GlobalData().occupations,
                          selectedItem: selectedOccupation,
                          onChanged: (value) {
                            setState(() {
                              selectedOccupation = value;
                              checkIfAllDropdownsSelected();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 22),

                      // State
                      _fieldSection(
                        icon: Icons.map_outlined,
                        label: "State",
                        dropdown: AboutScreenDropdown(
                          label: "Please select",
                          items: GlobalData().states,
                          selectedItem: selectedState,
                          onChanged: (value) {
                            setState(() {
                              selectedState = value;
                              selectedCity = null;
                              checkIfAllDropdownsSelected();
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 22),

                      // City
                      _fieldSection(
                        icon: Icons.location_on_outlined,
                        label: "City",
                        dropdown: AboutScreenDropdown(
                          key: ValueKey(selectedState),
                          label: selectedState == null
                              ? "Select state first"
                              : "Please select",
                          items: selectedState == null
                              ? <String>[]
                              : (GlobalData().citiesByState[selectedState] ?? []),
                          selectedItem: selectedCity,
                          onChanged: (value) {
                            if (selectedState == null) return;

                            setState(() {
                              selectedCity = value;
                              checkIfAllDropdownsSelected();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Info Card
                _buildInfoCard(primary),

                const SizedBox(height: 24),

                // Save Button
                _buildSaveButton(primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(Icons.person_outline, color: primary, size: 28),
        ),
        const SizedBox(height: 14),
        Text(
          "Complete Your Profile",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Help us understand you better for personalized school recommendations",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _fieldSection({
    required IconData icon,
    required String label,
    required Widget dropdown,
  }) {
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: primary),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        dropdown,
      ],
    );
  }

  Widget _buildInfoCard(Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withOpacity(0.08),
            primary.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.info_outline, color: primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why complete your profile?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This helps us provide better school recommendations tailored to your family\'s needs and preferences.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(Color primary) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isSubmitButtonEnabled && !isSubmitting ? _saveChanges : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isSubmitButtonEnabled && !isSubmitting ? 4 : 0,
        ),
        child: isSubmitting
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Saving...',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                size: 20, color: Colors.white),
            const SizedBox(width: 10),
            const Text(
              'Save Changes',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkIfAllDropdownsSelected() {
    final allSelected = selectedQualification != null &&
        selectedIncome != null &&
        selectedOccupation != null &&
        selectedState != null &&
        selectedCity != null;

    setState(() {
      isSubmitButtonEnabled = allSelected;
    });
  }

  Future<void> _saveChanges() async {
    setState(() => isSubmitting = true);
    try {
      await _submitUserDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }

      debugPrint('Changes saved!');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }

      debugPrint('Error saving additional details: $e');
    } finally {
      setState(() => isSubmitting = false);
    }
  }
}