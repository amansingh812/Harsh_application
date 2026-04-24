import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    super.key,
    this.title,
    required this.hintText,
    this.leadingIcon,
    this.prefixIconColor,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.isMobileNumberField = false,
    this.isEmailAddressField = false,
    this.isDateField = false,
    this.isNumberField = false,
    this.initialValue,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.textEditingController,
    this.inputFormatters,
    this.textInputAction,
    this.readOnly = false,
    this.maxLines = 1,
    this.errorText,
    this.maxLength,
    this.textCapitalization,
    this.keyboardType,
    this.editingComplete,
    this.onTapOutside,
    this.isLeadJourney = false,
    this.focusNode,
    this.autofocus = false,

  });
  final bool autofocus;
  final FocusNode? focusNode;
  final String? title;
  final String hintText;
  final Widget? leadingIcon;
  final Color? prefixIconColor;
  final String? Function(String? value)? validator;
  final String? Function()? editingComplete;
  final void Function(String value)? onTapOutside;

  final void Function(String value)? onChanged;
  final void Function(String? value)? onSaved;
  final bool isMobileNumberField;
  final bool isEmailAddressField;
  final bool isDateField;
  final bool isNumberField;
  final String? initialValue;
  final AutovalidateMode? autovalidateMode;
  final TextEditingController? textEditingController;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final int maxLines;
  final String? errorText;
  final int? maxLength;
  final TextCapitalization? textCapitalization;
  final TextInputType? keyboardType;
  final bool isLeadJourney;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late TextEditingController _textEditingController = TextEditingController();
  String? errorText;

  @override
  void initState() {
    if (widget.textEditingController != null) {
      _textEditingController =
          widget.textEditingController ?? TextEditingController();
    }
    if (widget.initialValue != null) {
      _textEditingController.text = widget.initialValue ?? '';
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AppTextFormField oldWidget) {
    if (widget.initialValue != null) {
      _textEditingController.text = widget.initialValue ?? '';
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title ?? "",
          style: const TextStyle(
            // fontFamily: FontConstants.frutiger,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF797979),
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        TextFormField(
          focusNode: widget.focusNode,
          textCapitalization:
              widget.textCapitalization ?? TextCapitalization.none,
          maxLines: widget.maxLines,
          readOnly: widget.isDateField ? true : widget.readOnly,
          inputFormatters: widget.inputFormatters ?? [],
          scrollPadding: const EdgeInsets.only(
            bottom: 54,
          ),
          controller: _textEditingController,
          //  onTap: widget.isDateField ? _onCalendarIconPressed : null,
          onTapOutside: (event) {
            widget.onTapOutside?.call(_textEditingController.text);
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onEditingComplete: widget.editingComplete,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
          autovalidateMode: widget.autovalidateMode,
          maxLength: widget.isMobileNumberField ? 10 : widget.maxLength,
          textInputAction: widget.textInputAction ?? TextInputAction.done,
          keyboardType: widget.isMobileNumberField
              ? TextInputType.phone
              : widget.isEmailAddressField
                  ? TextInputType.emailAddress
                  : widget.isNumberField
                      ? TextInputType.number
                      : widget.isDateField
                          ? TextInputType.datetime
                          : widget.keyboardType,
          style: WidgetStateTextStyle.resolveWith(
            (states) => states.contains(WidgetState.error)
                ? TextStyle(
                    //    fontFamily: FontConstants.frutiger,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFED1C24),
                  )
                : TextStyle(
                    //  fontFamily: FontConstants.frutiger,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF484848),
                  ),
          ),
          decoration: InputDecoration(
            counterText: '',
            errorText: widget.errorText ?? errorText,
            contentPadding: const EdgeInsets.all(14),
            hintText: widget.hintText,
            hintStyle:  TextStyle(color: Colors.white.withOpacity(0.7)), /*TextStyle(
              // fontFamily: FontConstants.frutiger,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFFC6C6C6),
            ),*/
            suffixIconColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.error)
                  ? Color(0xFFED1C24)
                  : Color(0xFF0061A2),
            ),
            filled: true,
            /* fillColor: WidgetStateColor.resolveWith(
              (states) => states.contains(WidgetState.error)
                  ? const Color(0xFFFDE8E9)
                  : const Color(0xFFFFFFFF),
            ),*/
            fillColor: WidgetStateColor.resolveWith((states) =>
                states.contains(WidgetState.error)
                    ? const Color(0xFFFDE8E9)
                    : (widget.readOnly
                        ? const Color(0xFFF2F2F2)
                        : const Color(0xFFFFFFFF))),
            errorMaxLines: 3,
            errorStyle: const TextStyle(
              // fontFamily: FontConstants.frutiger,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFFED1C24),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(
                color: Color(0xFFC6C6C6),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(
                color: /*Color(0xFFC6C6C6)*/ widget.readOnly
                    ? Colors.transparent
                    : const Color(0xFFC6C6C6),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: widget.readOnly
                  ? const BorderSide(
                      color: Color(0xFFC6C6C6),
                      width: 1,
                    )
                  : BorderSide(
                      color: Color(0xFF00ADEF),
                      width: 1,
                    ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(
                color: Color(0xFFED1C24),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: const BorderSide(
                color: Color(0xFFED1C24),
                width: 1,
              ),
            ),
            prefixIcon: widget.isMobileNumberField
                ? Padding(
                    padding: const EdgeInsets.only(
                      left: 14,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "+91",
                          style: TextStyle(
                            // fontFamily: FontConstants.frutiger,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF484848),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          width: 1,
                          height: 14,
                          color: const Color(0xFFC6C6C6),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                      ],
                    ),
                  )
                : null,
            suffixIcon: widget.isDateField
                ? IconButton(
                    onPressed: widget.isLeadJourney ? null : null,
                    padding: EdgeInsets.zero,
                    style: const ButtonStyle(
                      minimumSize: WidgetStatePropertyAll<Size>(
                        Size(16, 16),
                      ),
                      maximumSize: WidgetStatePropertyAll<Size>(
                        Size(16, 16),
                      ),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    iconSize: 24,
                    icon: const Icon(
                      Icons.calendar_month,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
