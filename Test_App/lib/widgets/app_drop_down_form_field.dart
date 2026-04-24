import 'package:flutter/material.dart';

class AppDropDownFormField extends StatelessWidget {
  const AppDropDownFormField({
    super.key,
    required this.title,
    required this.hintText,
    required this.items,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.autovalidateMode,
    this.value,
  });

  final String title;
  final String hintText;
  final String? Function(AppDropDownItem?)? validator;
  final List<AppDropDownItem> items;
  final void Function(AppDropDownItem?)? onChanged;
  final void Function(AppDropDownItem?)? onSaved;
  final AutovalidateMode? autovalidateMode;
  final AppDropDownItem? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Frutiger',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF797979),
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        DropdownButtonFormField<AppDropDownItem>(
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem<AppDropDownItem>(
                  value: e,
                  child: Text(
                    e.value,
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          onSaved: onSaved,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
          ),
          iconSize: 12,
          iconEnabledColor: const Color(0xFF0061A2),
          dropdownColor: const Color(0xFFFFFFFF),
          validator: validator,
          autovalidateMode: autovalidateMode,
          style: const TextStyle(
            //   fontFamily: FontConstants.frutiger,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF484848),
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(14),
            hintText: hintText,
            hintStyle: const TextStyle(
              // fontFamily: FontConstants.frutiger,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFFC6C6C6),
            ),
            filled: true,
            fillColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.error)
                  ? const Color(0xFFFDE8E9)
                  : const Color(0xFFFFFFFF),
            ),
            errorMaxLines: 3,
            errorStyle: const TextStyle(
              //    fontFamily: FontConstants.frutiger,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFFED1C24),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: Color(0xFFC6C6C6),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: Color(0xFFC6C6C6),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: Color(0xFFC6C6C6),
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: Color(0xFFED1C24),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: Color(0xFFED1C24),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppDropDownItem {
  final String key;
  final String value;

  const AppDropDownItem({
    required this.key,
    required this.value,
  });
}
