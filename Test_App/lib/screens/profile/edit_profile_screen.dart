import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_scout/global/global_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../apis/update_user_details.dart';
import '../../main.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with  TickerProviderStateMixin
{
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  bool isMobileNumberValid = true;
  bool isSaveButtonEnabled = false;
  bool _isSaving = false;
  final UpdateUserService _updateUserService = UpdateUserService();
  late AnimationController _animationController;
  final RegExp nameRegex = RegExp(r'^[a-zA-Z ]+$');
  final RegExp emailRegex =
  RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final RegExp phoneRegex = RegExp(r'^[6789]\d{9}$');

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  late String _origFirst;
  late String _origLast;
  late String _origEmail;
  late String _origPhone;
  late String _origGender;
  String userId ='';


  Future<void> updateUser() async {
    setState(() => _isSaving = true);

    try {
      final response = await _updateUserService.updateUserDetails(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        mobNumber: mobileNumberController.text,
        appId: 'SID',
        userPic: '',
        userId: userId,
        email: emailController.text,
        gender: genderController.text,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        // 🔥 SAVE TO SHARED PREFS
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('firstName', firstNameController.text);
        await prefs.setString('lastName', lastNameController.text);
        await prefs.setString('email', emailController.text);
        await prefs.setString('phoneNumber', mobileNumberController.text);
        await prefs.setString('gender', genderController.text);

        // 🔥 UPDATE GLOBAL MEMORY
        GlobalData().firstName = firstNameController.text;
        GlobalData().lastName = lastNameController.text;
        GlobalData().email = emailController.text;
        GlobalData().mobNumber = mobileNumberController.text;
        GlobalData().gender = genderController.text;

        setState(() {
          isSaveButtonEnabled = false;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Profile updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        setState(() => _isSaving = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Update failed'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    analytics.logScreenView(
      screenName: "EditProfileScreen",
    );
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
    _loadUserFromPrefs();

    firstNameController.addListener(_enableSaveButton);
    lastNameController.addListener(_enableSaveButton);
    emailController.addListener(_enableSaveButton);
    mobileNumberController.addListener(_enableSaveButton);
    genderController.addListener(_enableSaveButton);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -10), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10, end: 10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10, end: -10), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeOut,
    ));

  }

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    _origFirst = prefs.getString('firstName') ?? '';
    _origLast  = prefs.getString('lastName') ?? '';
    _origEmail = prefs.getString('email') ?? '';
    _origPhone = prefs.getString('phoneNumber') ?? '';
    _origGender = prefs.getString('gender') ?? 'Male';
     userId = prefs.getString('userId') ?? 'Male';


    setState(() {
      firstNameController.text = _origFirst;
      lastNameController.text = _origLast;
      emailController.text = _origEmail;
      mobileNumberController.text = _origPhone;
      genderController.text = _origGender;

      isSaveButtonEnabled = false;   // 🔥 initially disabled
    });
  }


  void _enableSaveButton() {
    final first = firstNameController.text.trim();
    final last  = lastNameController.text.trim();
    final email = emailController.text.trim();
    final phone = mobileNumberController.text.trim();
    final gender = genderController.text.trim();

    final isValid =
        first.isNotEmpty &&
            last.isNotEmpty &&
            email.isNotEmpty &&
            phone.isNotEmpty &&
            gender.isNotEmpty &&
            nameRegex.hasMatch(first) &&
            nameRegex.hasMatch(last) &&
            emailRegex.hasMatch(email) &&
            phoneRegex.hasMatch(phone);

    final isChanged =
        first != _origFirst ||
            last  != _origLast ||
            email != _origEmail ||
            phone != _origPhone ||
            gender != _origGender;

    setState(() {
      isSaveButtonEnabled = isValid && isChanged;
    });
  }



  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileNumberController.dispose();
    genderController.dispose();
    _animationController.dispose();
    _shakeController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        leading: Container(
          margin: const EdgeInsets.only(left: 12, top: 6, bottom: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(24),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        body: SingleChildScrollView(
          child: Column(
            children: [

              // ===== HEADER =====
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 28,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withOpacity(0.85)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),

                    ScaleTransition(
                      scale: Tween<double>(begin: 0.1, end: 1.0)
                          .animate(_animationController),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 42,
                          backgroundImage: AssetImage('assets/images/man.png'),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      '${firstNameController.text} ${lastNameController.text}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== FORM =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildPersonalDetailsCard(primary),
                    const SizedBox(height: 18),
                    _buildContactDetailsCard(primary),
                    const SizedBox(height: 24),
                    _buildInfoCard(primary),
                    const SizedBox(height: 20),
                    _buildBottomSaveButton(primary),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
        );
}

        // ===== PERSONAL DETAILS CARD =====
  Widget _buildPersonalDetailsCard(Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_outline, color: primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Personal Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // First Name
          _fieldLabel('FIRST NAME'),
          /*_profileTextField(firstNameController,
              hint: 'Enter your first name', keyboardType: TextInputType.text),*/
          _shakeWrapper(
            child: TextFormField(
              controller: firstNameController,
              keyboardType: TextInputType.text,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (_) => _enableSaveButton(),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'First name required';
                if (!nameRegex.hasMatch(v.trim())) return 'Only alphabets allowed';
                return null;
              },
              decoration: _profileInputDecoration('Enter your first name'),
            ),
          ),

          const SizedBox(height: 18),

          // Last Name
          _fieldLabel('LAST NAME'),
          _shakeWrapper(
          child:TextFormField(
            controller: lastNameController,
            keyboardType: TextInputType.text,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (_) => _enableSaveButton(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Last name required';
              if (!nameRegex.hasMatch(v.trim())) return 'Only alphabets allowed';
              return null;
            },
            decoration: _profileInputDecoration('Enter your last name'),
          ),
          ),
          const SizedBox(height: 20),

          // Gender
          _fieldLabel('GENDER'),
          const SizedBox(height: 10),
          _buildGenderChips(),
        ],
      ),
    );
  }

  // ===== CONTACT DETAILS CARD =====
  Widget _buildContactDetailsCard(Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.mail_outline,
                    color: Colors.green.shade600, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Contact Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Email
          _fieldLabel('EMAIL ADDRESS'),
          _shakeWrapper(
          child:TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (_) => _enableSaveButton(),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email required';
              if (!emailRegex.hasMatch(v.trim())) return 'Enter valid email';
              return null;
            },
            decoration: _profileInputDecoration('Enter your email', icon: Icons.mail_outline),
          ),
          ),

          const SizedBox(height: 18),

          // Phone
          _fieldLabel('PHONE NUMBER'),
          _phoneTextField(),
        ],
      ),
    );
  }

  // ===== TEXT FIELD =====
  Widget _profileTextField(
      TextEditingController controller, {
        required TextInputType keyboardType,
        String hint = '',
        IconData? prefixIcon,
      }) {
    final primary = Theme.of(context).colorScheme.primary;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade50,
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w400,
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: primary.withOpacity(0.6))
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    );
  }

  // ===== PHONE FIELD =====
  Widget _phoneTextField() {
    final primary = Theme.of(context).colorScheme.primary;

    return TextFormField(
      controller: mobileNumberController,
      keyboardType: TextInputType.number,
      enabled: false,
      onChanged: (value) {
        setState(() {
          isMobileNumberValid =
              RegExp(r'^[6789][0-9]{9}$').hasMatch(value);
          _enableSaveButton();
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14.0, right: 10.0),
          child: Text(
            '+91',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        errorText: !isMobileNumberValid
            ? 'Invalid phone number'
            : null,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
    );
  }
  InputDecoration _profileInputDecoration(String hint, {IconData? icon}) {
    final primary = Theme.of(context).colorScheme.primary;

    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      prefixIcon: icon != null
          ? Icon(icon, size: 20, color: primary.withOpacity(0.6))
          : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  // ===== GENDER CHIPS =====
  Widget _buildGenderChips() {
    final selected = genderController.text;
    final primary = Theme.of(context).colorScheme.primary;

    Widget chip(String label, IconData icon) {
      final isActive = selected == label;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            genderController.text = label;
            _enableSaveButton();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 48,
            decoration: BoxDecoration(
              color: isActive ? primary : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? primary : Colors.grey.shade300,
                width: isActive ? 2 : 1.5,
              ),
              boxShadow: isActive
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isActive ? Colors.white : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('Male', Icons.male),
        const SizedBox(width: 10),
        chip('Female', Icons.female),
        const SizedBox(width: 10),
        chip('Other', Icons.help_outline),
      ],
    );
  }
  Widget _shakeWrapper({required Widget child}) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
    );
  }

  // ===== FIELD LABEL =====
  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  // ===== INFO CARD =====
  Widget _buildInfoCard(Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withOpacity(0.08),
            primary.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: primary.withOpacity(0.2),
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
            child: Icon(Icons.lightbulb_outline, color: primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keep Profile Updated',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'A complete profile helps schools provide personalized recommendations for your child\'s education.',
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

  // ===== SAVE BUTTON =====
  Widget _buildBottomSaveButton(Color primary) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isSaveButtonEnabled && !_isSaving ? updateUser : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isSaveButtonEnabled ? 4 : 0,
        ),
        child: _isSaving
            ? const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            const Text(
              'Save Changes',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}