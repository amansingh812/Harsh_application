import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  State<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();

    final String adUnitId = Platform.isIOS
    // 🔥 iOS TEST ID (replace with production later)
        ? 'ca-app-pub-7958976759958710/7525629893'
    // 🔥 Android TEST ID
        : 'ca-app-pub-7958976759958710/5932521249';
    _nativeAd = NativeAd(
      adUnitId: "ca-app-pub-7958976759958710/5932521249", // TEST ID |   real-ca-app-pub-7958976759958710/5932521249
      factoryId: "schoolCard", // Flutter default style
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) return const SizedBox(height: 0);

    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          ),
        ],
      ),
      child: AdWidget(ad: _nativeAd!),
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
}
