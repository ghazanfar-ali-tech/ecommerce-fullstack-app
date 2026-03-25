import 'dart:math' as math;
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/auth_view_model.dart';
import 'package:ecommerceapp/view_model/home_view_model.dart';
import 'package:ecommerceapp/views/home_screen/cart_screen/cart_screen.dart';
import 'package:ecommerceapp/views/home_screen/components/geomatricBgPainter.dart';
import 'package:ecommerceapp/views/home_screen/components/sun_and_moon_painter.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimatedCategoryHeader extends StatefulWidget {
  final HomeViewModel viewModel;
  final Widget categoriesList;
  
  const AnimatedCategoryHeader({super.key, required this.viewModel,required this.categoriesList,});

  @override
  State<AnimatedCategoryHeader> createState() =>
      AnimatedCategoryHeaderState();
}

class AnimatedCategoryHeaderState extends State<AnimatedCategoryHeader>
    with TickerProviderStateMixin {

  late AnimationController _starCtrl;   
  late AnimationController _floatCtrl; 
  late AnimationController _cloudCtrl;  
  late AnimationController _rayCtrl;    
  late AnimationController _shootCtrl;  

  late AnimationController _bgCtrl;

  final _rand = math.Random(42);


  late final List<Star> _stars = List.generate(28, (i) => Star(
    x: _rand.nextDouble(),
    y: _rand.nextDouble() * 0.85,
    r: 0.8 + _rand.nextDouble() * 1.8,
    phase: _rand.nextDouble(),
    speed: 0.4 + _rand.nextDouble() * 0.6,
  ));

  @override
  void initState() {
    super.initState();
    
 _bgCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

    _starCtrl  = AnimationController(vsync: this,
        duration: const Duration(seconds: 3))..repeat(reverse: true);
    _floatCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 5))..repeat(reverse: true);
    _cloudCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 40))..repeat();
    _rayCtrl   = AnimationController(vsync: this,
        duration: const Duration(seconds: 8))..repeat();
    _shootCtrl = AnimationController(vsync: this,
    duration: const Duration(seconds: 12))..repeat();
  }

  @override
  void dispose() {
   _bgCtrl.dispose();
  _starCtrl.dispose();
  _floatCtrl.dispose();
  _cloudCtrl.dispose();
  _rayCtrl.dispose();
  _shootCtrl.dispose();
  super.dispose();
  }


  _TimeOfDay get _timeOfDay {
    final h = DateTime.now().hour;
    if (h >= 5  && h < 8)  return _TimeOfDay.dawn;
    if (h >= 8  && h < 18) return _TimeOfDay.day;
    if (h >= 18 && h < 21) return _TimeOfDay.dusk;
    return _TimeOfDay.night;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tod    = _timeOfDay;

    return Stack(
      fit: StackFit.expand,
      children: [

      
        _buildBackground(isDark, tod),

        
        if (isDark || tod == _TimeOfDay.night || tod == _TimeOfDay.dawn)
          ..._buildStars(context),

        if (isDark || tod == _TimeOfDay.night)
          _buildShootingStar(context),

  
        if (isDark || tod == _TimeOfDay.night || tod == _TimeOfDay.dawn)
          _buildMoon(context)
        else
          _buildSun(context, tod),

       Positioned.fill(
  child: AnimatedBuilder(
    animation: _bgCtrl,
    builder: (_, __) => CustomPaint(
      painter: GeometricBgPainter(
        progress: _bgCtrl.value,
        isDark: isDark,
      ),
    ),
  ),
),

        Positioned(
          top: 40, left: 0, right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        Text(
                          _greeting(tod),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _timeChip(tod),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.viewModel.isUsernameLoaded
                              ? (widget.viewModel.username ?? '')
                              : 'Loading...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Consumer<AuthViewModel>(
                          builder: (context, authViewModel, child) {
                            final cartItemCount =
                                authViewModel.getCartItemCount();
                            return GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => CartScreen())),
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 0.5),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(Icons.shopping_bag_outlined,
                                        color: Colors.white, size: 22),
                                    if (cartItemCount > 0)
                                      Positioned(
                                        top: 6, right: 6,
                                        child: Container(
                                          width: 14, height: 14,
                                          decoration: BoxDecoration(
                                            color: AppColors.accent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text('$cartItemCount',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 8,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                   

                    Text('Shop by Category',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        )),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              widget.categoriesList,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackground(bool isDark, _TimeOfDay tod) {
    final colors = _bgColors(isDark, tod);
    return AnimatedContainer(
      duration: const Duration(seconds: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
    );
  }

  List<Color> _bgColors(bool isDark, _TimeOfDay tod) {
    if (isDark) {
      return [const Color.fromARGB(255, 6, 79, 187), const Color(0xFF020D28)];
    }
    switch (tod) {
      case _TimeOfDay.dawn:
        return [const Color(0xFF1A237E), const Color(0xFFFF7043)];
      case _TimeOfDay.day:
        return [const Color(0xFF1565C0), const Color(0xFF003DB5)];
      case _TimeOfDay.dusk:
        return [const Color(0xFF4A148C), const Color(0xFFE65100)];
      case _TimeOfDay.night:
        return [const Color(0xFF010B1A), const Color(0xFF020D28)];
    }
  }

  List<Widget> _buildStars(BuildContext context) {
    return _stars.map((s) {
      return Positioned(
        left:  s.x * MediaQuery.sizeOf(context).width,
        top:   s.y * 200,
        child: AnimatedBuilder(
          animation: _starCtrl,
          builder: (_, __) {
            final flicker = (0.3 +
    0.7 * math.sin(
        (_starCtrl.value + s.phase) * math.pi * s.speed * 2))
    .clamp(0.0, 1.0);
            return Opacity(
              opacity:flicker,
              child: Container(
                width: s.r * 2,
                height: s.r * 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.6 * flicker),
                      blurRadius: s.r * 3,
                      spreadRadius: s.r * 0.5,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildShootingStar(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return AnimatedBuilder(
      animation: _shootCtrl,
      builder: (_, __) {
        final t = _shootCtrl.value;
        if (t < 0.0 || t > 0.25) return const SizedBox.shrink();
        final progress = t / 0.25;
        final x = w * 0.2 + w * 0.6 * progress;
        final y = 20.0 + 60.0 * progress;
        return Positioned(
          left: x, top: y,
          child: Opacity(
            opacity: (1 - progress) * 0.9,
            child: Transform.rotate(
              angle: math.pi / 4,
              child: Container(
                width: 60, height: 1.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMoon(BuildContext context) {
  return Positioned(
    top: 20, right: 24,
    child: AnimatedBuilder(
      animation: _floatCtrl,
      builder: (_, __) {
        final float = -4 * math.sin(_floatCtrl.value * math.pi);
        return Transform.translate(
          offset: Offset(0, float),
          child: Stack(
            alignment: Alignment.center,
            children: [
        
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.12),
                      blurRadius: 20,
                      spreadRadius: 6,
                    ),
                  ],
                ),
              ),
             Transform.rotate(
  angle: -math.pi / 5,
  child: CustomPaint(
    size: const Size(38, 38),
    painter: CrescentMoonPainter(),
  ),
),
            ],
          ),
        );
      },
    ),
  );
}


  Widget _buildSun(BuildContext context, _TimeOfDay tod) {
    final sunColor = tod == _TimeOfDay.dawn
        ? const Color(0xFFFFB74D)
        : tod == _TimeOfDay.dusk
            ? const Color(0xFFFF7043)
            : const Color(0xFFFFD600);

    return Positioned(
      top: 16, right: 20,
      child: AnimatedBuilder(
        animation: Listenable.merge([_floatCtrl, _rayCtrl]),
        builder: (_, __) {
          final float = -3 * math.sin(_floatCtrl.value * math.pi);
          return Transform.translate(
            offset: Offset(0, float),
            child: SizedBox(
              width: 60, height: 60,
              child: Stack(
                alignment: Alignment.center,
                children: [

           
                  Transform.rotate(
                    angle: _rayCtrl.value * 2 * math.pi,
                    child: CustomPaint(
                      painter: SunRayPainter(color: sunColor),
                      size: const Size(60, 60),
                    ),
                  ),

               
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: sunColor.withOpacity(0.5),
                          blurRadius: 18,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),

               
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: sunColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }




  String _greeting(_TimeOfDay tod) {
    switch (tod) {
      case _TimeOfDay.dawn:  return 'Good Morning ✨';
      case _TimeOfDay.day:   return 'Good Day ☀️';
      case _TimeOfDay.dusk:  return 'Good Evening 🌅';
      case _TimeOfDay.night: return 'Good Night 🌙';
    }
  }

  Widget _timeChip(_TimeOfDay tod) {
    final now = DateTime.now();
    final h   = now.hour.toString().padLeft(2, '0');
    final m   = now.minute.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Colors.white.withOpacity(0.2), width: 0.5),
      ),
      child: Text('$h:$m',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600)),
    );
  }
}

enum _TimeOfDay { dawn, day, dusk, night }

class Star {
  final double x, y, r, phase, speed;
  const Star({required this.x, required this.y, required this.r,
      required this.phase, required this.speed});
}

