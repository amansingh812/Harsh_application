import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_scout/screens/compare/show_compare_data.dart';
import 'package:school_scout/screens/home/maps_view_page.dart';
import 'package:school_scout/screens/profile/profile_screen.dart';
import 'package:school_scout/screens/details/school_list.dart';
import 'package:school_scout/screens/shortlist/shortlisted_school.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global/global_data.dart';
import '../screens/login/login_page.dart';

class BottomNavigatorClass extends StatefulWidget {
  const BottomNavigatorClass({super.key});

  @override
  State<BottomNavigatorClass> createState() => BottomNavigatorState();
}

class BottomNavigatorState extends State<BottomNavigatorClass>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  int? _pressedIndex; // 🔥 Track which button is being pressed

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void goToHome() {
    setState(() {
      _currentIndex = 0;
    });
  }

  void goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _tabs = [
    MapsViewPage(),
    _getCompareTab(),
    SchoolList(),
    const ProfileScreen(),
    const ShortlistedSchool(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {

          // 🔥 Agar current tab Home nahi hai
          if (_currentIndex != 0) {
            setState(() {
              _currentIndex = 0;   // Home tab pe bhej do
            });
            return false; // app close mat karo
          }

          // 🔥 Agar already Home pe ho
          return true; // tab app close ho sakti hai
        },
        child: Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Page Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.03, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _getCurrentTab(),
          ),

          // Glass Bottom Nav
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildGlassBottomNav(context),
          ),
        ],
      ),
    ),
    );
  }

  Widget _navItem(
      IconData icon,
      String label,
      int index,
      Color primary,
      ) {
    final bool isSelected = _currentIndex == index;
    final bool isPressed = _pressedIndex == index; // 🔥 Check if this button is pressed

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressedIndex = index); // 🔥 Mark as pressed
        HapticFeedback.selectionClick(); // 🔥 Immediate haptic feedback
      },
      onTapUp: (_) {
        setState(() => _pressedIndex = null); // 🔥 Release
      },
      onTapCancel: () {
        setState(() => _pressedIndex = null); // 🔥 Release on cancel
      },
      onTap: () async{
        // Clear compare state when leaving compare tab


        if (_currentIndex == 1 &&
            index != 1 &&
            GlobalData().selectedSchools.length == 2) {
          GlobalData().selectedSchools.clear();
          GlobalData().compareCount.value = 0;
        }

        // Change tab
        setState(() => _currentIndex = index);


      },
      child: AnimatedScale(
        scale: isPressed ? 0.90 : 1.0, // 🔥 Scale down when pressed
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20 : 12,
            vertical: 10,
          ),
          decoration: isSelected
              ? BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary.withOpacity(0.15),
                primary.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Icon with scale animation
                  AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      icon,
                      size: 24,
                      color: isSelected ? primary : Colors.grey.shade600,
                    ),
                  ),

                  // Compare Badge
                  if (index == 1)
                    Positioned(
                      top: -6,
                      right: -6,
                      child: ValueListenableBuilder<int>(
                        valueListenable: GlobalData().compareCount,
                        builder: (_, count, __) {
                          if (count == 0) return const SizedBox();
                          return AnimatedScale(
                            scale: 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF5252), Color(0xFFE91E63)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  count.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  fontSize: isSelected ? 12 : 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? primary : Colors.grey.shade600,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCompareTab() {
    return const ShowCompareData();
  }

  Widget _getCurrentTab() {
    switch (_currentIndex) {
      case 0:
        return KeyedSubtree(
          key: const ValueKey(0),
          child: MapsViewPage(),
        );
      case 1:
        return const KeyedSubtree(
          key: ValueKey(1),
          child: ShowCompareData(),
        );
      case 2:
        return KeyedSubtree(
          key: const ValueKey(2),
          child: SchoolList(),
        );
      case 3:
        return KeyedSubtree(
          key: const ValueKey(3),
          child: ProfileScreen(),
        );
      case 4:
        return KeyedSubtree(
          key: const ValueKey(4),
          child: ShortlistedSchool(),
        );
      default:
        return KeyedSubtree(
          key: const ValueKey(0),
          child: MapsViewPage(),
        );
    }
  }

  Widget _buildGlassBottomNav(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Glass Effect Background
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.7),
                        Colors.white.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                        spreadRadius: -4,
                      ),
                      BoxShadow(
                        color: primary.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),

              // Navigation Items
              Container(
                height: 72,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _navItem(Icons.home_rounded, 'Home', 0, primary),
                    _navItem(Icons.compare_arrows_rounded, 'Compare', 1, primary),
                    _navItem(Icons.school_rounded, 'Schools', 2, primary),
                    _navItem(Icons.person_rounded, 'Profile', 3, primary),
                  ],
                ),
              ),

              // Shine Effect (subtle highlight)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 1.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.6),
                        Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}