import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/bootstrap_app.dart';
import 'package:ecommerceapp/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

/// https://ecommercestore-ea75d.firebaseapp.com/__/auth/handler
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BootstrapApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
   return GetMaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Flutter Demo',
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
  ),
  home: const SplashScreen(),
);
  }
}

