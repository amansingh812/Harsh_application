import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class PinTextFormField extends StatelessWidget {
  const PinTextFormField({
    super.key,
    required this.digits,
    required this.onChanged,
    required this.onCompleted,
  });

  final int digits;
  final void Function(String)? onChanged;
  final void Function(String)? onCompleted;

  @override
  Widget build(BuildContext context) {
    return Pinput(
      length: digits,
      onChanged: onChanged,
      onCompleted: onCompleted,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      defaultPinTheme: PinTheme(
        height: 48,
        width: 62,
        margin: const EdgeInsets.symmetric(
          horizontal: 8,
        ).copyWith(
          left: 0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: const Color(0xFFE2E2E2),
            width: 1,
          ),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: Color(0xFF484848),
        ),
      ),
    );
  }
}
