import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInput extends StatelessWidget {
  const CustomInput({
    Key? key,
    this.keyboardType = TextInputType.text,
    this.hintText = "",
    this.controller,
    this.style,
    this.contentPadding,
    this.maxLines = 1,
    this.inputFormatter,
    this.focusNode,
    this.maxLength,
    this.autofocus = false,
    this.onChange
  }) : super(key: key);

  final TextInputType keyboardType;
  final String hintText;
  final TextEditingController? controller;
  final TextStyle? style;
  final EdgeInsets? contentPadding;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatter;
  final FocusNode? focusNode;
  final bool autofocus;
  final Function? onChange;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatter,
      focusNode: focusNode,
      autofocus: autofocus,
      decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBCBCBC)),
          contentPadding: contentPadding ?? const EdgeInsets.only(left: 0, bottom: 4),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.transparent,
          isDense: true,
          counterText: ""
      ),
      maxLines: maxLines,
      maxLength: maxLength,
      // cursorColor: AppColors.yellow_light,
      style: style ?? const TextStyle(fontSize: 14, color: Color(0xFF484E76)),
      onChanged: (String input){
        onChange?.call(input);
      },
    );
  }
}
