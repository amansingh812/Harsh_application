import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'legal_web_view.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: TextButton(
          child: const Text("Privacy Policy"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LegalWebView(
                  assetPath: "assets/legal/terms_and_conditions.html",
                  title: "Terms and Conditions",
                ),
              ),
            );
          },
        ),

      ),
    );
  }
}
