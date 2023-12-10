import 'package:flutter/material.dart';

import '../../common/const/color.dart';

TextFormField textFormField(
    {required String hintText,
    TextEditingController? controller,
    FocusNode? focusNode,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int? maxLength,
    int? maxLines,
    bool? obscureText,
    InputDecoration? decoration,
    required double borderRadius,
    required TextInputType keyboardType,
    required Key key,
    required double errorBorderRadius,
    TextStyle? counterStyle}) {
  return TextFormField(
    key: key,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    controller: controller,
    onChanged: onChanged,
    focusNode: focusNode,
    validator: validator,
    maxLength: maxLength,
    maxLines: maxLines,
    keyboardType: keyboardType,
    obscureText: obscureText ?? false,
    decoration: InputDecoration(
      counterStyle: counterStyle,
      filled: true,
      fillColor: WHITE_COLOR,
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: FOCUS_BORDERSIDE, width: 2.0),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: RECORD_OUTLINE, width: 2.0),
        borderRadius: BorderRadius.all(
          Radius.circular(
            errorBorderRadius,
          ),
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        ),
      ),
      hintText: hintText,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
    ),
  );
}
