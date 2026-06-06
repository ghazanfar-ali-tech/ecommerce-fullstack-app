import 'dart:async';
import 'package:ecommerceapp/resources/constants.dart';
import 'package:ecommerceapp/services/deep_link_services.dart';
import 'package:ecommerceapp/services/fire_base_services.dart';
import 'package:ecommerceapp/services/notification_services.dart/notification_services.dart';
import 'package:ecommerceapp/models/hive_models/shipping_address/address.dart'
    as hive_address;
import 'package:ecommerceapp/view_model/auth_view_model.dart';
import 'package:ecommerceapp/view_model/notification_view_model.dart';
import 'package:ecommerceapp/view_model/store_view_model.dart';
import 'package:ecommerceapp/view_model/theme_provider.dart';
import 'package:ecommerceapp/views/onboarding_screens/onboarding_screens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:ecommerceapp/view_model/google_sign.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final FireBaseServices authService = FireBaseServices();
  final DeepLinkService deepLinkService = DeepLinkService();

  late final AnimationController _fadeController;
  late final AnimationController _shimmerController;
  late final AnimationController _dotsController;

  late final Animation<double> _fadeIn;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _handleStartupLogic();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _shimmer = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shimmerController.dispose();
    _dotsController.dispose();
    super.dispose();
  }

  Future<void> _handleStartupLogic() async {
    if (!mounted) return;

    final notifVM = context.read<NotificationViewModel>();
    final themeProvider = context.read<ThemeProvider>();
    final authVM = context.read<AuthViewModel>();

    unawaited(notifVM.init());
    unawaited(themeProvider.loadTheme());
    unawaited(NotificationService().init());
    unawaited(Stripe.instance.applySettings());
    unawaited(GoogleSignInService.initSignIn());

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final box = Hive.box('app');
    final bool onboardingDone = box.get('onboardingDone', defaultValue: false);

    if (!onboardingDone) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreens()),
      );
      return;
    }

    final results = await Future.wait([
      deepLinkService.getInitialDeepLink(),
      _loadUserIfLoggedIn(authVM),
    ]);

    if (!mounted) return;

    final Uri? uri = results[0] as Uri?;

    if (uri != null && uri.pathSegments.isNotEmpty) {
      if (uri.pathSegments.first == 'product') {
        final slug = uri.pathSegments[1];
        Navigator.pushReplacementNamed(context, '/product', arguments: slug);
        return;
      }
    }

    authService.isLogin(context);
  }

  Future<void> _loadUserIfLoggedIn(AuthViewModel authVM) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await authVM.openUserCart(user.uid);
    if (!mounted) return;
    final storeVM = context.read<StoreViewModel>();
    await authVM.loadUserFromPrefs(storeVM);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: FadeTransition(
        opacity: _fadeIn,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFEEF3FF), Color(0xFFF7F9FF)],
                  ),
                ),
              ),
            ),

            Positioned(
              top: size.height * 0.26,
              left: size.width / 2 - 90,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF4B7BFF).withOpacity(0.12),
                      const Color(0xFF4B7BFF).withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),

            Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LogoCard(shimmer: _shimmer),
                  const SizedBox(height: 28),
                  const Text(
                    'Larkanian Shop',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A2B5E),
                      letterSpacing: -0.3,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Discover · Shop · Deliver',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A9BC4),
                      letterSpacing: 2.2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 52),
                  _DotsLoader(controller: _dotsController),
                ],
              ),
            ),

            Positioned(
              bottom: 38,
              left: 0,
              right: 0,
              child: Text(
                'Powered by Larkanian Inc.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: const Color(0xFF8A9BC4).withOpacity(0.6),
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  final Animation<double> shimmer;
  const _LogoCard({required this.shimmer});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (_, __) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white,
            border: Border.all(color: const Color(0xFFDDE6FF), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4B7BFF).withOpacity(0.10),
                blurRadius: 30,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: const Color(0xFF1A2B5E).withOpacity(0.06),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF5B8DFF), Color(0xFF3A6FE8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4B7BFF).withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/app_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned.fill(
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment(-2.5 + shimmer.value * 5, -1),
                      end: Alignment(-1.5 + shimmer.value * 5, 1),
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.18),
                        Colors.transparent,
                      ],
                    ).createShader(bounds),
                    blendMode: BlendMode.srcOver,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DotsLoader extends StatelessWidget {
  final AnimationController controller;
  const _DotsLoader({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final t = ((controller.value - i * 0.28) % 1.0).clamp(0.0, 1.0);
            final pulse = t < 0.5 ? t * 2 : (1.0 - t) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.lerp(
                  const Color(0xFFBFCFFF),
                  const Color(0xFF4B7BFF),
                  pulse,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4B7BFF).withOpacity(0.06)
      ..strokeWidth = 1;
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
