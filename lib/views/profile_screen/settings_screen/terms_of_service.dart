import 'dart:math' as math;
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen>
    with TickerProviderStateMixin {


  late AnimationController _waveCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _heroCtrl;
  late AnimationController _listCtrl;
  late AnimationController _shimmerCtrl;
  late AnimationController _rotateCtrl;


  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _floatY;
  late Animation<double> _pulse;
  late Animation<double> _shimmer;
  late Animation<double> _badgeRotate;



  late AnimationController _typeCtrl;
late AnimationController _glowCtrl;
late AnimationController _letterCtrl;

  final List<_TermSection> _sections = [
    _TermSection(Icons.storefront_rounded,     'Use of the App',   'Browse products, place test orders, and interact for demonstration purposes.',                   const Color(0xFF003DB5)),
    _TermSection(Icons.manage_accounts_rounded,'User Accounts',    'You are responsible for maintaining the confidentiality of your account credentials.',           const Color(0xFF0284C7)),
    _TermSection(Icons.dashboard_rounded,      'Admin Panel',      'Product data and orders are controlled via an admin panel and may change without notice.',        const Color(0xFF0057E7)),
    _TermSection(Icons.block_rounded,          'Limitations',      'This app does not process real payments or guarantee product availability or delivery.',          const Color(0xFFFF6B35)),
    _TermSection(Icons.shield_rounded,         'Liability',        'The developer is not responsible for any losses arising from use of this demo application.',      const Color(0xFF003DB5)),
    _TermSection(Icons.gavel_rounded,          'Termination',      'Accounts may be suspended or removed if misuse of the application is detected.',                 const Color(0xFF0284C7)),
  ];

  @override
  void initState() {
    super.initState();

    _waveCtrl    = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _floatCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat(reverse: true);
    _pulseCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..repeat(reverse: true);
    _heroCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _listCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
    _rotateCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat();

    _heroFade  = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _floatY    = Tween<double>(begin: -8.0, end: 8.0)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _pulse     = Tween<double>(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _shimmer   = Tween<double>(begin: -1.5, end: 2.5).animate(_shimmerCtrl);
    _badgeRotate = Tween<double>(begin: -0.04, end: 0.04)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

        _typeCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
_glowCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
_letterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

_typeCtrl.forward();
Future.delayed(const Duration(milliseconds: 400), () {
  if (mounted) _letterCtrl.forward();
});

    _heroCtrl.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _listCtrl.forward();
    });
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _heroCtrl.dispose();
    _listCtrl.dispose();
    _shimmerCtrl.dispose();
    _rotateCtrl.dispose();
    _typeCtrl.dispose();
_glowCtrl.dispose();
_letterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [

          CustomScrollView(
            slivers: [

              SliverToBoxAdapter(child: _buildHero(context, size, isDark)),

              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _heroFade,
                  child: _buildInfoCard(context),
                ),
              ),

         
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 60),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _buildCard(context, i),
                    childCount: _sections.length,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, Size size, bool isDark) {
    return SizedBox(
      height: size.height * 0.46,
      child: Stack(
        children: [

        
          Positioned.fill(
            child: Image.network(
              'htps://www.shipbob.com/wp-content/uploads/2025/02/2ddd3c8dcfc2c55052e065ef225596c1.jpg?w=1024?w=292px',
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, progress) => progress == null
                  ? child
                  : Container(
                      decoration: BoxDecoration(gradient: AppColors.heroGradient),
                      child: const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                    ),
              errorBuilder: (_, __, ___) =>
                  Container(decoration: BoxDecoration(gradient: AppColors.heroGradient)),
            ),
          ),

      
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.78)],
                ),
              ),
            ),
          ),

          Positioned(
            top: -40, right: -40,
            child: AnimatedBuilder(
              animation: _rotateCtrl,
              builder: (_, __) => Transform.rotate(
                angle: _rotateCtrl.value * 2 * math.pi,
                child: CustomPaint(
                  painter: _OrbitPainter(),
                  size: const Size(200, 200),
                ),
              ),
            ),
          ),

          ..._buildParticles(size),

          Positioned(
            left: 0, right: 0, bottom: 0,
            child: AnimatedBuilder(
              animation: _waveCtrl,
              builder: (_, __) => CustomPaint(
                painter: _WavePainter(
                  progress: _waveCtrl.value,
                  color: AppColors.background(context),
                ),
                size: Size(size.width, 90),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.35), width: 0.8),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 17),
              ),
            ),
          ),

        
          Positioned(
            bottom: 62, left: 0, right: 0,
            child: SlideTransition(
              position: _heroSlide,
              child: FadeTransition(
                opacity: _heroFade,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_floatY, _badgeRotate, _pulse]),
                  builder: (_, child) => Transform.translate(
                    offset: Offset(0, _floatY.value),
                    child: Transform.rotate(
                      angle: _badgeRotate.value,
                      child: Transform.scale(
                        scale: _pulse.value,
                        child: child,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [

                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(0.2),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [

                            AnimatedBuilder(
                              animation: _pulseCtrl,
                              builder: (_, __) => Container(
                                width: 220,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3 + _pulseCtrl.value * 0.3),
                                      blurRadius: 30 + _pulseCtrl.value * 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),

Container(
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
  decoration: BoxDecoration(
    gradient: AppColors.primaryGradient,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Colors.white.withOpacity(0.3), width: 0.8),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.5),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [

      AnimatedBuilder(
        animation: _rotateCtrl,
        builder: (_, child) => Transform.rotate(
          angle: _rotateCtrl.value * 2 * math.pi,
          child: child,
        ),
        child: AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, child) => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2 + _glowCtrl.value * 0.4),
                  blurRadius: 8 + _glowCtrl.value * 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          ),
          child: const Icon(Icons.verified_rounded, color: Colors.white, size: 22),
        ),
      ),

      const SizedBox(width: 10),


      _AnimatedTextRow(
        text: 'Terms of Service',
        controller: _letterCtrl,
      ),
    ],
  ),
),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      Text('Demo E-Commerce · March 2025',
                          style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  List<Widget> _buildParticles(Size size) {
    final particles = [
      _Particle(top: 60,  left: 30,  radius: 4,  delay: 0.0),
      _Particle(top: 100, left: 120, radius: 3,  delay: 0.3),
      _Particle(top: 80,  right: 60, radius: 5,  delay: 0.6),
      _Particle(top: 150, right: 30, radius: 3,  delay: 0.2),
      _Particle(top: 50,  right: 140,radius: 2,  delay: 0.8),
      _Particle(top: 180, left: 60,  radius: 4,  delay: 0.5),
    ];

    return particles.map((p) {
      return Positioned(
        top: p.top, left: p.left, right: p.right,
        child: AnimatedBuilder(
          animation: _floatCtrl,
          builder: (_, __) {
            final t = (_floatCtrl.value + p.delay) % 1.0;
            final y = -12 * math.sin(t * math.pi);
            return Transform.translate(
              offset: Offset(0, y),
              child: Opacity(
                opacity: 0.4 + 0.3 * math.sin(t * math.pi),
                child: Container(
                  width: p.radius * 2,
                  height: p.radius * 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 6)],
                  ),
                ),
              ),
            );
          },
        ),
      );
    }).toList();
  }

  Widget _buildInfoCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryContainer(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.info_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This is a demo project built for learning and portfolio purposes only.',
                style: TextStyle(color: AppColors.primaryText(context), fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, int index) {
    final section = _sections[index];
    final delay   = index * 0.14;

    return AnimatedBuilder(
      animation: _listCtrl,
      builder: (context, child) {
        final raw      = (_listCtrl.value - delay) / (1.0 - delay);
        final progress = Curves.easeOutCubic.transform(raw.clamp(0.0, 1.0));
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(40 * (1 - progress), 0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border(context), width: 0.5),
          boxShadow: [BoxShadow(color: AppColors.shadow(context), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, child) {
                  final t = (_floatCtrl.value + index * 0.15) % 1.0;
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(-0.2 + 0.1 * math.sin(t * math.pi * 2))
                      ..rotateX(0.1 + 0.05 * math.cos(t * math.pi * 2)),
                    child: child,
                  );
                },
                child: Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: section.color,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(color: section.color.withOpacity(0.5), blurRadius: 14, offset: const Offset(0, 6)),
                      BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 4, offset: const Offset(-2, -2)),
                    ],
                  ),
                  child: Icon(section.icon, color: Colors.white, size: 22),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title,
                        style: TextStyle(color: AppColors.textPrimary(context),
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 5),
                    Text(section.body,
                        style: TextStyle(color: AppColors.textSecondary(context),
                            fontSize: 13, height: 1.5)),
                  ],
                ),
              ),

              
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Transform.translate(
                  offset: Offset(3 * _pulseCtrl.value, 0),
                  child: Icon(Icons.arrow_forward_ios_rounded,
                      color: AppColors.primaryText(context), size: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;
  _WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void drawWave(double heightFactor, double amplitude, double speed,
        double phase, double opacity) {
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      final path = Path();
      path.moveTo(0, h);
      for (double x = 0; x <= w; x += 2) {
        final y = h * heightFactor +
            amplitude * math.sin((x / w * 2 * math.pi * 2) +
                progress * 2 * math.pi * speed + phase);
        path.lineTo(x, y);
      }
      path.lineTo(w, h);
      path.close();
      canvas.drawPath(path, paint);
    }

    drawWave(0.55, 16, 1.0, 0.0,   1.0);
    drawWave(0.45, 12, 1.3, 1.2,   0.6);
    drawWave(0.35, 10, 0.8, 2.4,   0.35);
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.progress != progress || old.color != color;
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint  = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawCircle(center, 60,  paint);
    canvas.drawCircle(center, 90,  paint..color = Colors.white.withOpacity(0.05));
    canvas.drawCircle(center, 100, paint..color = Colors.white.withOpacity(0.03));
  }

  @override
  bool shouldRepaint(_OrbitPainter old) => false;
}



class _TermSection {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  const _TermSection(this.icon, this.title, this.body, this.color);
}

class _Particle {
  final double top;
  final double? left;
  final double? right;
  final double radius;
  final double delay;
  const _Particle({required this.top, this.left, this.right,
      required this.radius, required this.delay});
}

class _AnimatedTextRow extends StatelessWidget {
  final String text;
  final AnimationController controller;

  const _AnimatedTextRow({required this.text, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(text.length, (index) {
     
            final start = (index / text.length) * 0.6;
            final end   = start + 0.4;
            final t     = ((controller.value - start) / (end - start)).clamp(0.0, 1.0);

            final bounce = Curves.elasticOut.transform(t);
            final fade   = Curves.easeOut.transform(t);

            return Opacity(
              opacity: fade,
              child: Transform.translate(
                offset: Offset(0, -20 * (1 - bounce)), 
                child: Transform.scale(
                  scale: 0.5 + 0.5 * bounce,          
                  child: Text(
                    text[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}