import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LegalWebView extends StatelessWidget {
  final String assetPath;
  final String title;

  const LegalWebView({super.key, required this.assetPath, required this.title});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..loadFlutterAsset(assetPath);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: WebViewWidget(controller: controller),
    );
  }
}
