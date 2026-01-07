import 'package:flutter/material.dart';

Widget customField({
  required String hintName,
  required IconData icon,
  String? labelText,
  TextEditingController? controller,
  bool obscure = false,
  String? Function(String?)? validator,

}) {
  return TextFormField(
    controller: controller,
    obscureText: obscure,
    validator: validator,
    decoration: InputDecoration(
      prefixIcon: Icon(icon),
      labelText: labelText,
      hintText: hintName,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  );
}
