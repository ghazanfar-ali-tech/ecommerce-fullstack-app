import 'package:flutter/material.dart';

Widget productFields({
  required String hintName,
  required IconData icon,
  required int minLines,
  TextInputType keyboardtype = TextInputType.text,
  String? labelText,
  TextEditingController? controller,
  String? Function(String?)? validator,

}) {
  return TextFormField(
    controller: controller,
    validator: validator,
    keyboardType: keyboardtype,
    minLines: minLines,
    maxLines: minLines > 1 ? null : 1,
    decoration: InputDecoration(
      prefixIcon: Icon(icon),
      labelText: labelText,
      hintText: hintName,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        
      ),
    ),
  );
}
