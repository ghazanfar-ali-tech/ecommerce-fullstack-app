import 'package:ecommerceapp/models/hive_models/cart_model/cart_model.dart';
import 'package:ecommerceapp/models/hive_models/shipping_address/address.dart' as hive_address;
import 'package:ecommerceapp/services/deep_link_services.dart';
import 'package:ecommerceapp/services/fire_base_services.dart';
import 'package:ecommerceapp/view_model/auth_view_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FireBaseServices authService = FireBaseServices();
  final DeepLinkService deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _handleStartupLogic();
  }

  Future<void> _handleStartupLogic() async {
    // Small splash delay
    await Future.delayed(const Duration(seconds: 2));

    final Uri? uri = await deepLinkService.getInitialDeepLink();
 await Hive.openBox<hive_address.Address>('addresses');



  final user = FirebaseAuth.instance.currentUser; 
  
  final authVM = context.read<AuthViewModel>();
  
  if (user != null) {
    await authVM.openUserCart(user.uid);
  }
    if (uri != null && uri.pathSegments.isNotEmpty) {
 
      if (uri.pathSegments.first == 'product') {
        final slug = uri.pathSegments[1];

        Navigator.pushReplacementNamed(
          context,
          '/product',
          arguments: slug,
        );
        return;
      }
    }

    authService.isLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
