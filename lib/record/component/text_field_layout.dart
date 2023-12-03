import 'package:flutter/material.dart';

import '../../common/const/color.dart';

TextFormField textFormField({
  required String hintText,
  TextEditingController? controller,
  FocusNode? focusNode,
  String? Function(String?)? validator,
  void Function(String)? onChanged,
  int? maxLength,
  int? maxLines,
  bool? obscureText,
  InputDecoration? decoration,
  required double borderRadiusSize,
  required TextInputType keyboardType,
  required Key key,
}) {
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
      filled: true,
      fillColor: WHITE_COLOR,
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: WHITE_COLOR),
        borderRadius: BorderRadius.circular(borderRadiusSize),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: RECORD_OUTLINE),
        borderRadius: BorderRadius.all(
          Radius.circular(
            borderRadiusSize,
          ),
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 2.0),
        borderRadius: BorderRadius.all(
          Radius.circular(
            50,
          ),
        ),
      ),
      hintText: hintText,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
    ),
  );
}
