
import 'package:ecommerceapp/bootstrap_app.dart';
import 'package:ecommerceapp/view_model/theme_provider.dart';
import 'package:ecommerceapp/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
   return Consumer<ThemeProvider>(
  builder: (context, themeProvider, _) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  },
);
  }
}

