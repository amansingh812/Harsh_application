import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../apis/register_new_child_service.dart';
import '../../global/global_data.dart';
import '../../widgets/about_screen_dropdown.dart';
import '../../widgets/brand_loader.dart';
import '../../widgets/muti_drop_down.dart';

class AddChildProfile extends StatefulWidget {
  const AddChildProfile({super.key});

  @override
  State<AddChildProfile> createState() => _AddChildProfileState();
}

class _AddChildProfileState extends State<AddChildProfile>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  String? gender;
  String? selectedClass;
  DateTime? dob;
  List<String> selectedHobbies = [];
  final ChildRegisterAPI apiService = ChildRegisterAPI();
  bool isSubmitting = false;
  late AnimationController _animationController;
  final FocusNode nameFocus = FocusNode();
  final FocusNode dummyFocus = FocusNode(); // used to remove focus

  final List<String> classList = [
    // Pre-Primary
    "Play Group",
    "Pre Nursery",
    "Nursery",
    "LKG",
    "UKG",

    // Primary
    "Class 1",
    "Class 2",
    "Class 3",
    "Class 4",
    "Class 5",

    // Middle School
    "Class 6",
    "Class 7",
    "Class 8",

    // Secondary
    "Class 9",
    "Class 10",

    // Senior Secondary
    "Class 11",
    "Class 12",
  ];

  final List<String> hobbyList = [
    // Sports
    "Cricket",
    "Football",
    "Basketball",
    "Badminton",
    "Table Tennis",
    "Tennis",
    "Swimming",
    "Skating",
    "Athletics",
    "Karate",
    "Taekwondo",
    "Yoga",
    "Gymnastics",

    // Performing Arts
    "Dancing",
    "Classical Dance",
    "Western Dance",
    "Singing",
    "Classical Music",
    "Instrumental Music",
    "Drama",
    "Theatre",

    // Creative Arts
    "Drawing",
    "Painting",
    "Craft",
    "Pottery",
    "Origami",
    "Calligraphy",

    // Academics / Brain
    "Chess",
    "Abacus",
    "Vedic Maths",
    "Mental Maths",
    "Robotics",
    "Coding",
    "AI & Machine Learning",
    "STEM Activities",

    // Language & Communication
    "Debate",
    "Public Speaking",
    "Creative Writing",
    "Story Telling",
    "Poetry",
    "Journalism",

    // Clubs
    "Science Club",
    "Maths Club",
    "Eco Club",
    "Astronomy Club",
    "Photography",
    "Film Making",

    // Life Skills
    "Leadership Training",
    "Personality Development",
    "Meditation",
    "Mindfulness",

    // Others
    "Gardening",
    "Cooking",
    "Baking",
    "Social Service",
    "Community Work",
  ];
  final ValueNotifier<bool> _formNotifier = ValueNotifier(false);

  List<String> filteredHobbies = [];
  final TextEditingController hobbySearchController = TextEditingController();

  bool get isFormValid =>
      nameController.text.isNotEmpty &&
          gender != null &&
          selectedClass != null &&
          dob != null &&
          isAgeValid;

  @override
  void initState() {
    super.initState();
    filteredHobbies = hobbyList;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    nameController.dispose();
    hobbySearchController.dispose();
    _animationController.dispose();
    nameFocus.dispose();
    dummyFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Add Child Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: primary,
        elevation: 2,
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
      bottomNavigationBar: ValueListenableBuilder<bool>(
        valueListenable: _formNotifier,
        builder: (context, valid, _) {
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            color: Colors.white,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: valid ? _submitProfile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: AbsorbPointer(
                    absorbing: isSubmitting,
                    child: isSubmitting
                        ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 12),
                        Text(
                          'Creating...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_outlined,
                            size: 20, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Add Child Profile',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                20,
                16,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 20,
                ),
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
                      .animate(_animationController),
                  child: FadeTransition(
                    opacity: _animationController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderSection(primary),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(22),
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
                          child: _buildForm(primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
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
          child: Icon(Icons.child_care, color: primary, size: 28),
        ),
        const SizedBox(height: 14),
        const Text(
          "Add New Child",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Create a profile for your child to get personalized school recommendations",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name
        _fieldLabel("Child's Name", primary),
        _inputField("Enter child's full name", nameController),
        const SizedBox(height: 22),

        // Gender
        _fieldLabel("Gender", primary),
        _buildGenderChips(primary),
        const SizedBox(height: 22),

        // Class
        _fieldLabel("Preferred Class", primary),
        AboutScreenDropdown(
          label: "Select preferred class",
          items: classList,
          selectedItem: selectedClass,
          onChanged: (v) {
            _unfocus();
            setState(() => selectedClass = v);
            _formNotifier.value = isFormValid;
          },


        ),
        const SizedBox(height: 22),
        // Date of Birth
        _fieldLabel("Date of Birth", primary),
        _buildDatePicker(primary),

// ❌ ERROR MESSAGE
        if (dob != null && !isAgeValid)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              "Child must be at least 1 year old",
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),


        const SizedBox(height: 22),


        // Hobbies
        _fieldLabel("Hobbies", primary),
        _buildHobbiesSelector(primary),
      ],
    );
  }

  Widget _fieldLabel(String text, Color primary) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _inputField(String hint, TextEditingController c) {
    final primary = Theme.of(context).colorScheme.primary;

    return TextField(
      focusNode: nameFocus,
      controller: c,
      onChanged: (_) {
        // sirf form validity update karo
        _formNotifier.value = isFormValid;
      },
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildGenderChips(Color primary) {
    return Row(
      children: ["Male", "Female"]
          .map((g) => Expanded(
        child: GestureDetector(
            onTap: () {
              _unfocus();
              setState(() => gender = g);
              _formNotifier.value = isFormValid;
            },

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 48,
            margin: EdgeInsets.only(
                right: g == "" ? 0 : 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: gender == g ? primary : Colors.grey.shade300,
                width: gender == g ? 2 : 1.5,
              ),
              color:
              gender == g ? primary.withOpacity(0.1) : Colors.white,
              boxShadow: gender == g
                  ? [
                BoxShadow(
                  color: primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
                  : [],
            ),
            child: Center(
              child: Text(
                g,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: gender == g
                      ? primary
                      : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ))
          .toList(),
    );
  }

  Widget _buildDatePicker(Color primary) {
    return GestureDetector(
      onTap: pickDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: dob == null || isAgeValid ? Colors.grey.shade200 : Colors.red,
            width: 1.5,
          ),

        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                color: primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dob == null
                    ? "Select date of birth"
                    : DateFormat("dd MMM yyyy").format(dob!),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: dob == null ? Colors.grey.shade500 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHobbiesSelector(Color primary) {
    return GestureDetector(
      onTap: () {
        _unfocus();
        _openHobbySelector();
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.favorite_outline, color: primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: selectedHobbies.isEmpty
                  ? Text(
                "Select hobbies",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              )
                  : Wrap(
                spacing: 6,
                runSpacing: 8,
                children: selectedHobbies
                    .map(
                      (h) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      h,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primary,
                      ),
                    ),
                  ),
                )
                    .toList(),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ===== LOGIC =====

  void pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dob ?? DateTime.now(),
      firstDate: DateTime(1995),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        dob = picked;
      });
      _unfocus();
      _formNotifier.value = isFormValid;

    }
  }

  bool get isAgeValid {
    if (dob == null) return false;

    final today = DateTime.now();
    final minDate = DateTime(today.year - 1, today.month, today.day);

    return dob!.isBefore(minDate);
  }

  Future<void> _submitProfile() async {
    if (!isFormValid) return;

    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    try {
      setState(() => isSubmitting = true);

      await apiService.registerChild(
        userId: userId ?? '',
        firstName: nameController.text.trim(),
        middleName: "",
        lastName: "",
        gender: gender!,
        admissionClass: selectedClass!,
        dob: DateFormat("yyyy-MM-dd").format(dob!),
        hobbies: selectedHobbies.join(","),
        childPic: "",
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Child profile created successfully!"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  void _openHobbySelector() {
    // 🔥 TEMP state (IMPORTANT)
    final List<String> tempSelected = List.from(selectedHobbies);
    filteredHobbies = List.from(hobbyList);
    hobbySearchController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).viewInsets.bottom + 12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  // 🔥 Drag handle
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🔥 HEADER (Title + Close)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 40),
                      const Text(
                        'Select Hobbies',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context), // ❌ CANCEL
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 🔍 SEARCH
                  TextField(
                    controller: hobbySearchController,
                    onChanged: (value) {
                      setSheetState(() {
                        filteredHobbies = hobbyList
                            .where((h) =>
                            h.toLowerCase().contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search hobbies...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: const Color(0xfff4f6fa),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 📜 LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredHobbies.length,
                      itemBuilder: (_, i) {
                        final hobby = filteredHobbies[i];
                        final isSelected = tempSelected.contains(hobby);

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setSheetState(() {
                              if (isSelected) {
                                tempSelected.remove(hobby);
                              } else {
                                tempSelected.add(hobby);
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    hobby,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Theme.of(context)
                                          .colorScheme
                                          .primary
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ✅ DONE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedHobbies = List.from(tempSelected);
                        });
                        _formNotifier.value = isFormValid;
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
  void _unfocus() {
    FocusScope.of(context).requestFocus(dummyFocus);
  }

}