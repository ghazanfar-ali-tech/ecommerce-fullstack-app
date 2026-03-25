import 'dart:ui';

import 'package:flutter/material.dart';

class RibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const notch = 5.0;
    final path = Path();

  
    path.moveTo(0, 0);
   
    path.lineTo(size.width, 0);
    
    path.lineTo(size.width - notch, size.height / 2);
    path.lineTo(size.width, size.height);

    path.lineTo(0, size.height);
   
    path.lineTo(notch, size.height / 2);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}