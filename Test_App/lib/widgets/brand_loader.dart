import 'package:flutter/material.dart';

class BrandLoader extends StatefulWidget {
  final double size;
  final bool showText;
  final String text;

  const BrandLoader({
    super.key,
    this.size = 64,
    this.showText = true,
    this.text = "Please wait…",
  });

  @override
  State<BrandLoader> createState() => _BrandLoaderState();
}

class _BrandLoaderState extends State<BrandLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scale = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _glow = Tween(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Transform.scale(
              scale: _scale.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF2A900).withOpacity(_glow.value),
                      blurRadius: 30,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    "assets/images/app_icon.png",
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.showText) ...[
          const SizedBox(height: 16),
          Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );
  }
}
