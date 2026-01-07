import 'dart:async';
import 'package:ecommerceapp/views/auth_screens/auth_screen.dart';
import 'package:ecommerceapp/views/bottom_navigation/bottom_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FireBaseServices { 
  void isLogin(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final user = auth.currentUser;

    if (user != null) {
      Timer(
        const Duration(seconds: 8),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigation()),
        ),
      );
    } else {
      Timer(
        const Duration(seconds: 8),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  AuthScreen()),
        ),
      );
    }
  }
}
