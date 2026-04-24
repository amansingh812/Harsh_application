import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:school_scout/apis/update_pin_service.dart';
import 'package:school_scout/widgets/app_elevated_button.dart';

import '../../global/global_data.dart';

class UpdatePinScreen extends StatefulWidget {
  const UpdatePinScreen({super.key});

  @override
  State<UpdatePinScreen> createState() => _UpdatePinScreenState();
}

class _UpdatePinScreenState extends State<UpdatePinScreen> {
  final _oldPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool isLoading = false;
  bool isButtonEnabled = false;

  final _pinTheme = PinTheme(
    height: 56,
    width: 56,
    textStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
  );

  void _validateForm() {
    final oldPin = _oldPinController.text;
    final newPin = _newPinController.text;
    final confirmPin = _confirmPinController.text;

    final isValid = oldPin.length == 4 &&
        newPin.length == 4 &&
        confirmPin.length == 4 &&
        newPin == confirmPin;

    setState(() => isButtonEnabled = isValid);
  }

  Future<void> _updatePin() async {
    if (!isButtonEnabled) return;

    setState(() => isLoading = true);

    try {
      final result = await UpdatePinService().updatePin(
        mobNumber: GlobalData().mobNumber.toString(),
        oldPin: _oldPinController.text.trim(),
        newPin: _newPinController.text.trim(),
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      if (result['success'] == true) {
        // ✅ SUCCESS
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'PIN updated successfully')),
        );
        Navigator.pop(context);
      } else {
        // ❌ BACKEND ERROR
        _showError(result['message'] ?? 'PIN update failed');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showError('Something went wrong. Please try again.');
    }
  }


  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _oldPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          appBar: AppBar(
            title: const Text('Change Security PIN'),
            backgroundColor: const Color(0xFF162E8B),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCard(),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.lock_outline, size: 42, color: Color(0xFF162E8B)),
                    SizedBox(height: 8),
                    Text(
                      'Update PIN',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Choose a secure 4-digit PIN to protect your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              _buildPinSection('Current PIN', _oldPinController),
              const SizedBox(height: 16),

              _buildPinSection('New PIN', _newPinController),
              const SizedBox(height: 16),

              _buildPinSection('Confirm New PIN', _confirmPinController),
              const SizedBox(height: 28),

              AppElevatedButton(
                onPressed: isButtonEnabled ? _updatePin : null,
                text: 'Update Security PIN',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinSection(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        Pinput(
          controller: controller,
          length: 4,
          obscureText: true,
          defaultPinTheme: _pinTheme,
          focusedPinTheme: _pinTheme.copyWith(
            decoration: _pinTheme.decoration!.copyWith(
              border: Border.all(color: const Color(0xFF162E8B), width: 2),
            ),
          ),
          onChanged: (_) => _validateForm(),
        ),
      ],
    );
  }
}
