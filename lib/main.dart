import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/constants.dart';
import 'package:ecommerceapp/models/hive_models/cart_model/cart_model.dart';
import 'package:ecommerceapp/resources/constants.dart';
import 'package:ecommerceapp/view_model/address_view_model.dart';
import 'package:ecommerceapp/view_model/admin_settings_view_model.dart';
import 'package:ecommerceapp/view_model/admin_view_model.dart';
import 'package:ecommerceapp/view_model/coupon_view_model.dart';
import 'package:ecommerceapp/view_model/detail_view_model.dart';
import 'package:ecommerceapp/view_model/google_sign.dart';
import 'package:ecommerceapp/view_model/home_view_mode.dart';
import 'package:ecommerceapp/view_model/product_review_view_model.dart';
import 'package:ecommerceapp/view_model/profile_view_model.dart';
import 'package:ecommerceapp/view_model/setting_view_model.dart';
import 'package:ecommerceapp/view_model/stats_view_model.dart';
import 'package:ecommerceapp/view_model/store_view_model.dart';
import 'package:ecommerceapp/view_model/theme_provider.dart';
import 'package:ecommerceapp/views/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:ecommerceapp/models/hive_models/shipping_address/address.dart'
    as hive_address;

import 'package:provider/provider.dart';
import 'package:ecommerceapp/view_model/auth_view_model.dart';
import 'package:get/get.dart';
/// https://ecommercestore-ea75d.firebaseapp.com/__/auth/handler
void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: firebaseApiKey,
      appId: firebaseAppId,
      messagingSenderId: firebaseMessagingSenderId,
      projectId: firebaseProjectId,
    ),
  );

  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);


  Stripe.publishableKey = stripePubishableKey;
  await Stripe.instance.applySettings();

  await GoogleSignInService.initSignIn();
await Hive.initFlutter();

 if (!Hive.isAdapterRegistered(0)) {
  Hive.registerAdapter(hive_address.AddressAdapter());
}

if (!Hive.isAdapterRegistered(1)) {
  Hive.registerAdapter(CartModelAdapter());
}


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => DetailViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => StoreViewModel()),
        ChangeNotifierProvider(create: (_) => SettingViewModel()),
        ChangeNotifierProvider(create: (_) => AddressViewModel()),
        ChangeNotifierProvider(create: (_) => CouponViewModel()),
        ChangeNotifierProvider(create: (_) => ProductReviewViewModel()),
        ChangeNotifierProvider(create: (_) => StatsViewModel()),
        ChangeNotifierProvider(create: (_) => AppSettingsViewModel()),
      ],
      child: const MyApp(),
    ),
  );
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

