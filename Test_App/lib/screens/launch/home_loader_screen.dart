import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../apis/service/home_prefetch_service.dart';
import '../../widgets/my_bottomNavigator.dart';

final GlobalKey<BottomNavigatorState> bottomNavKey =
GlobalKey<BottomNavigatorState>();

class HomeLoaderScreen extends StatefulWidget {
  const HomeLoaderScreen({super.key});

  @override
  State<HomeLoaderScreen> createState() => _HomeLoaderScreenState();
}

class _HomeLoaderScreenState extends State<HomeLoaderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _checkAndLoad();
  }

  Future<void> _checkAndLoad() async {
    await HomePrefetchService.preload();

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => BottomNavigatorClass(
          key: bottomNavKey,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show UI for subsequent launches
    if (!_isFirstLaunch) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF162E8B),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, child) {
                final scale = 1 + (_pulse.value * 0.08);
                final glowOpacity = 0.2 + (_pulse.value * 0.2);

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF2A900)
                              .withOpacity(glowOpacity),
                          blurRadius: 35,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: child,
                    ),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Getting things ready…',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}