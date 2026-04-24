import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../apis/fetch_child_details_service.dart';
import '../../apis/register_new_child_service.dart';
import '../../global/global_data.dart';
import '../../widgets/brand_loader.dart';

class UpdateChildDetails extends StatefulWidget {
  final ChildDetails childDetails;

  const UpdateChildDetails({super.key, required this.childDetails});

  @override
  State<UpdateChildDetails> createState() => _UpdateChildDetailsState();
}

class _UpdateChildDetailsState extends State<UpdateChildDetails>
    with SingleTickerProviderStateMixin {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  String? selectedGender;
  String? selectedClass;
  DateTime? selectedDateOfBirth;
  List<String> hobbies = ['Skating', 'Dancing', 'Swimming', 'Singing'];
  List<String> selectedHobbies = [];
  bool isSubmitButtonEnabled = false;
  bool isAgeValid = true;
  bool isSubmitting = false;
  late AnimationController _animationController;

  final ChildRegisterAPI apiService = ChildRegisterAPI();

  final List<String> classList = [
    'Nursery',
    'LKG',
    'UKG',
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();

    // Prepopulate the form with the passed child data
    firstNameController.text = widget.childDetails.firstName;
    lastNameController.text = widget.childDetails.lastName;
    selectedGender = widget.childDetails.gender;
    selectedClass = widget.childDetails.admissionClass;
    selectedDateOfBirth = DateTime.parse(widget.childDetails.dob);

    firstNameController.addListener(_checkFormValidity);
    lastNameController.addListener(_checkFormValidity);
  }

  void _checkFormValidity() {
    setState(() {
      isSubmitButtonEnabled = firstNameController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          selectedGender != null &&
          selectedClass != null &&
          selectedDateOfBirth != null;
    });
  }

  Future<void> _updateChildProfile() async {
    setState(() => isSubmitting = true);

    try {
      final response = await apiService.registerChild(
        userId: GlobalData().userId.toString(),
        firstName: firstNameController.text.trim(),
        middleName: "",
        lastName: lastNameController.text.trim(),
        gender: selectedGender.toString(),
        admissionClass: selectedClass.toString(),
        dob: DateFormat("yyyy-MM-dd").format(selectedDateOfBirth!),
        hobbies: selectedHobbies.join(","),
        recordId: widget.childDetails.recordId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Child profile updated successfully!"),
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
          content: Text("Error: ${e.toString()}"),
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

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: primary,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        title: const Text(
          "Edit Child Profile",
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
              .animate(_animationController),
          child: FadeTransition(
            opacity: _animationController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                  child: _buildForm(context, primary),
                ),

                const SizedBox(height: 24),

                // Submit Button
                _buildSubmitButton(primary),
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
          child: Icon(Icons.edit_outlined, color: primary, size: 28),
        ),
        const SizedBox(height: 14),
        Text(
          "Update ${widget.childDetails.firstName}'s Profile",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Make changes to your child's information",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // First Name
        _fieldLabel("First Name", primary),
        _textField(
          firstNameController,
          hint: "Enter first name",
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 22),

        // Last Name
        _fieldLabel("Last Name", primary),
        _textField(
          lastNameController,
          hint: "Enter last name",
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 22),

        // Gender
        _fieldLabel("Gender", primary),
        _genderDropdown(primary),
        const SizedBox(height: 22),

        // Class
        _fieldLabel("Preferred Class", primary),
        _classDropdown(primary),
        const SizedBox(height: 22),

        // Date of Birth
        _fieldLabel("Date of Birth", primary),
        _dateOfBirthField(primary),
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

  Widget _textField(
      TextEditingController controller, {
        required String hint,
        required IconData icon,
      }) {
    final primary = Theme.of(context).colorScheme.primary;

    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(icon, color: primary.withOpacity(0.6), size: 20),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    );
  }

  Widget _genderDropdown(Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGender,
          isExpanded: true,
          icon: Icon(Icons.expand_more, color: primary),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          items: const [
            DropdownMenuItem(value: "Male", child: Text("Male")),
            DropdownMenuItem(value: "Female", child: Text("Female")),
            DropdownMenuItem(value: "Other", child: Text("Other")),
          ],
          onChanged: (v) {
            setState(() {
              selectedGender = v;
              _checkFormValidity();
            });
          },
        ),
      ),
    );
  }

  Widget _classDropdown(Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedClass,
          isExpanded: true,
          icon: Icon(Icons.expand_more, color: primary),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          items: classList
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (v) {
            setState(() {
              selectedClass = v;
              _checkFormValidity();
            });
          },
        ),
      ),
    );
  }

  Widget _dateOfBirthField(Color primary) {
    return GestureDetector(
      onTap: _selectDateOfBirth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, color: primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedDateOfBirth == null
                    ? "Select date of birth"
                    : DateFormat('dd MMM yyyy').format(selectedDateOfBirth!),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: selectedDateOfBirth == null
                      ? Colors.grey.shade500
                      : Colors.black87,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(Color primary) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isSubmitButtonEnabled && !isSubmitting
            ? _submitProfile
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isSubmitButtonEnabled && !isSubmitting ? 4 : 0,
        ),
        child: isSubmitting
            ?const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            ),
            const SizedBox(width: 12),
            const Text(
              'Saving...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.save_outlined, size: 20, color: Colors.white),
            const SizedBox(width: 10),
            const Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1995),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDateOfBirth = pickedDate;
        _checkFormValidity();
      });
    }
  }

  void _submitProfile() {
    if (isSubmitButtonEnabled && !isSubmitting) {
      _updateChildProfile();
    }
  }
}