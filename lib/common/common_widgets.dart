import 'package:flutter/material.dart';

class CommonWidget {
  static ClipRRect buildButton(String text, VoidCallback onPressed) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: ElevatedButton(onPressed: onPressed, child: Text(text)),
      ),
    );
  }

  static TextFormField buildTextFormField(
      {required final controller,
      required String labelText,
      required IconData prefixIcon,
      IconData? suffixIcon,
      bool? obscureText}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.0)),
          prefixIcon: Icon(prefixIcon),
          suffixIcon: suffixIcon != null
              ? const Icon(Icons.visibility_off_outlined)
              : null),
    );
  }
}
