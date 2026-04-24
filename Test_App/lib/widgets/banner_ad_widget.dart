import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({Key? key}) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBannerAd();
  }

  Future<void> _loadBannerAd() async {
    final AnchoredAdaptiveBannerAdSize? size =
    await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      debugPrint('❌ Unable to get banner size');
      return;
    }

    final String adUnitId = Platform.isIOS
    // 🔥 iOS TEST ID (replace with production later)
        ? 'ca-app-pub-7958976759958710/1503147029'
    // 🔥 Android TEST ID
        : 'ca-app-pub-7958976759958710/2674973567';

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Banner loaded');
          setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Banner failed: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}