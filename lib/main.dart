import 'package:ecommerceapp/core/constants.dart';
import 'package:ecommerceapp/models/hive_models/cart_model/cart_model.dart';
import 'package:ecommerceapp/models/hive_models/shipping_address/address.dart'
    as hive_address;
import 'package:ecommerceapp/resources/constants.dart';
import 'package:ecommerceapp/view_model/address_view_model.dart';
import 'package:ecommerceapp/view_model/admin_settings_view_model.dart';
import 'package:ecommerceapp/view_model/admin_view_model.dart';
import 'package:ecommerceapp/view_model/app_version_info.dart';
import 'package:ecommerceapp/view_model/auth_view_model.dart';
import 'package:ecommerceapp/view_model/coupon_view_model.dart';
import 'package:ecommerceapp/view_model/detail_view_model.dart';
import 'package:ecommerceapp/view_model/google_sign.dart';
import 'package:ecommerceapp/view_model/home_view_model.dart';
import 'package:ecommerceapp/view_model/notification_view_model.dart';
import 'package:ecommerceapp/view_model/order_view_model.dart';
import 'package:ecommerceapp/view_model/see_all_view_model.dart';
import 'package:ecommerceapp/view_model/theme_provider.dart';
import 'package:ecommerceapp/views/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecommerceapp/view_model/product_review_view_model.dart';
import 'package:ecommerceapp/view_model/profile_view_model.dart';
import 'package:provider/provider.dart';
import 'package:ecommerceapp/view_model/setting_view_model.dart';
import 'package:ecommerceapp/view_model/stats_view_model.dart';
import 'package:ecommerceapp/view_model/store_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Future.wait([
    Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: AppConstants.firebaseApiKey,
        appId: AppConstants.firebaseAppId,
        messagingSenderId: AppConstants.firebaseMessagingSenderId,
        projectId: AppConstants.firebaseProjectId,
      ),
    ),
    Hive.initFlutter(),
  ]);

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(hive_address.AddressAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(CartModelAdapter());
  }

  await Future.wait([
    Hive.openBox('app'),
    Hive.openBox<hive_address.Address>('addresses'),
  ]);

  Stripe.publishableKey = stripePubishableKey;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
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
        ChangeNotifierProvider(
          create: (ctx) => OrderViewModel(ctx.read<NotificationViewModel>()),
        ),
        ChangeNotifierProvider(
          create: (_) => AppVersionInfoViewModel()..loadPackageInfo(),
        ),
        ChangeNotifierProvider(create: (_) => SeeAllViewModel()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
