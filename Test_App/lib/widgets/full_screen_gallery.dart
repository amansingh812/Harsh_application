import 'package:flutter/material.dart';

class FullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int startIndex;

  const FullScreenGallery({
    super.key,
    required this.images,
    required this.startIndex,
  });

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isZooming = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,

            physics: _isZooming
                ? const NeverScrollableScrollPhysics()
                : const ClampingScrollPhysics(),

            onPageChanged: (i) {
              setState(() {
                _currentIndex = i;
                _isZooming = false; // 🔥 RESET zoom on page change
              });
            },

            itemBuilder: (_, i) {
              return _ZoomableImage(
                key: ValueKey(widget.images[i]), // 🔥 VERY IMPORTANT
                imageUrl: widget.images[i],
                onZoomChanged: (zooming) {
                  if (_isZooming != zooming) {
                    setState(() => _isZooming = zooming);
                  }
                },
              );
            },
          ),

          // TOP BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${_currentIndex + 1} / ${widget.images.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               ZOOMABLE IMAGE                                */
/* -------------------------------------------------------------------------- */

class _ZoomableImage extends StatefulWidget {
  final String imageUrl;
  final ValueChanged<bool> onZoomChanged;

  const _ZoomableImage({
    super.key,
    required this.imageUrl,
    required this.onZoomChanged,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  late TransformationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController(); // 🔥 NEW for each image
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateZoomState() {
    final scale = _controller.value.getMaxScaleOnAxis();
    widget.onZoomChanged(scale > 1.01);
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      minScale: 1.0,
      maxScale: 4.0,
      panEnabled: true,
      scaleEnabled: true,

      onInteractionUpdate: (_) => _updateZoomState(),
      onInteractionEnd: (_) => _updateZoomState(),

      child: SizedBox.expand( // 🔥 FULL SCREEN FIX
        child: Image.network(
          widget.imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (_, __, ___) => Image.asset(
            "assets/images/dummy_image.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
