import 'dart:math' as math;
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with TickerProviderStateMixin {

  late AnimationController _waveCtrl;
  late AnimationController _heroCtrl;
  late AnimationController _listCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _morphCtrl;

  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _floatY;
  late Animation<double> _glow;
  late Animation<double> _morph;

  final List<_PolicySection> _sections = [
    _PolicySection(
      icon: Icons.data_usage_rounded,
      title: 'Data Collection',
      body: 'The app may collect basic user information such as name, email address, and order details to demonstrate core e-commerce functionality.',
      color: const Color(0xFF003DB5),
      tag: 'Minimal',
      tagColor: const Color(0xFF003DB5),
    ),
    _PolicySection(
      icon: Icons.cloud_rounded,
      title: 'Backend & Third-Party',
      body: 'This app uses Firebase services and a Django REST API backend. Data is processed only to support authentication, product management, and order handling.',
      color: const Color(0xFF0284C7),
      tag: 'Firebase',
      tagColor: const Color(0xFF0284C7),
    ),
    _PolicySection(
      icon: Icons.manage_search_rounded,
      title: 'Data Usage',
      body: 'Collected data is used solely for app functionality and is not sold or shared with third parties for marketing purposes.',
      color: const Color(0xFF0057E7),
      tag: 'No Ads',
      tagColor: const Color(0xFF0057E7),
    ),
    _PolicySection(
      icon: Icons.lock_rounded,
      title: 'Data Security',
      body: 'Reasonable measures are taken to protect user data. However, this app is not intended for production use.',
      color: const Color(0xFFFF6B35),
      tag: 'Demo',
      tagColor: const Color(0xFFFF6B35),
    ),
    _PolicySection(
      icon: Icons.contact_support_rounded,
      title: 'Contact',
      body: 'For any questions regarding this privacy policy, please contact the developer directly.',
      color: const Color(0xFF003DB5),
      tag: 'Support',
      tagColor: const Color(0xFF003DB5),
    ),
  ];

  // track expanded cards
  final Set<int> _expanded = {};

  @override
  void initState() {
    super.initState();

    _waveCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    _heroCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _listCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat(reverse: true);
    _glowCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
    _morphCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4000))..repeat(reverse: true);

    _heroFade  = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));
    _floatY    = Tween<double>(begin: -6.0, end: 6.0)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _glow      = Tween<double>(begin: 0.3, end: 0.8)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
    _morph     = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _morphCtrl, curve: Curves.easeInOut));

    _heroCtrl.forward();
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _listCtrl.forward();
    });
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    _heroCtrl.dispose();
    _listCtrl.dispose();
    _floatCtrl.dispose();
    _glowCtrl.dispose();
    _morphCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: CustomScrollView(
        slivers: [

          // ── Hero
          SliverToBoxAdapter(child: _buildHero(context, size)),

          // ── Info badge
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _heroFade,
              child: _buildInfoBadge(context),
            ),
          ),

          // ── Cards
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
    );
  }

  // ──────────────────────────────────────────
  // HERO
  // ──────────────────────────────────────────
  Widget _buildHero(BuildContext context, Size size) {
    return SizedBox(
      height: size.height * 0.44,
      child: Stack(
        children: [

          // background image
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=800&q=80',
              fit: BoxFit.cover,
              loadingBuilder: (ctx, child, progress) => progress == null
                  ? child
                  : Container(
                      decoration: BoxDecoration(gradient: AppColors.heroGradient),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      ),
                    ),
              errorBuilder: (_, __, ___) =>
                  Container(decoration: BoxDecoration(gradient: AppColors.heroGradient)),
            ),
          ),

          // overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.75),
                  ],
                ),
              ),
            ),
          ),

          // morphing blob (CustomPainter — no rotation)
          Positioned(
            top: 20, right: -20,
            child: AnimatedBuilder(
              animation: _morph,
              builder: (_, __) => CustomPaint(
                painter: _MorphBlobPainter(progress: _morph.value),
                size: const Size(160, 160),
              ),
            ),
          ),

          // animated dots grid (no rotation — breathing scale)
          Positioned(
            top: 30, left: 20,
            child: AnimatedBuilder(
              animation: _glowCtrl,
              builder: (_, __) => CustomPaint(
                painter: _DotGridPainter(opacity: _glow.value),
                size: const Size(120, 100),
              ),
            ),
          ),

          // wave bottom
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

          // back button
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
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 17),
              ),
            ),
          ),

          // ── Hero badge — NO rotation, uses breathing + float
          Positioned(
            bottom: 58, left: 0, right: 0,
            child: SlideTransition(
              position: _heroSlide,
              child: FadeTransition(
                opacity: _heroFade,
                child: Column(
                  children: [

                    // breathing glow behind badge
                    AnimatedBuilder(
                      animation: Listenable.merge([_floatY, _glow]),
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _floatY.value),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [

                            // pulsing glow ring — no rotation
                            AnimatedBuilder(
                              animation: _glowCtrl,
                              builder: (_, __) => Container(
                                width: 220,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(_glow.value * 0.5),
                                      blurRadius: 28 + _glow.value * 16,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // badge with sliding gradient stripe
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Stack(
                                children: [

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 13),
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                          color: Colors.white.withOpacity(0.3),
                                          width: 0.8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [

                                        // shield icon with breathing scale
                                        AnimatedBuilder(
                                          animation: _glowCtrl,
                                          builder: (_, child) => Transform.scale(
                                            scale: 0.92 + _glowCtrl.value * 0.16,
                                            child: child,
                                          ),
                                          child: const Icon(Icons.privacy_tip_rounded,
                                              color: Colors.white, size: 22),
                                        ),

                                        const SizedBox(width: 10),

                                        // letter bounce text
                                        _AnimatedTextRow(
                                          text: 'Privacy Policy',
                                          controller: _heroCtrl,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // horizontal light sweep (no rotation)
                                  AnimatedBuilder(
                                    animation: _glowCtrl,
                                    builder: (_, __) => Positioned(
                                      top: 0, bottom: 0,
                                      left: -60 + _glowCtrl.value * 320,
                                      child: Container(
                                        width: 60,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              Colors.white.withOpacity(0.18),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      child: const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 10),
                    Text(
                      'Demo E-Commerce App · March 2025',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.75), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // INFO BADGE
  // ──────────────────────────────────────────
  Widget _buildInfoBadge(BuildContext context) {
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
              child: const Icon(Icons.privacy_tip_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Your privacy matters. This policy explains how demo data is handled.',
                style: TextStyle(
                    color: AppColors.primaryText(context),
                    fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // EXPANDABLE SECTION CARD
  // ──────────────────────────────────────────
  Widget _buildCard(BuildContext context, int index) {
    final section    = _sections[index];
    final delay      = index * 0.14;
    final isExpanded = _expanded.contains(index);

    return AnimatedBuilder(
      animation: _listCtrl,
      builder: (context, child) {
        final raw      = (_listCtrl.value - delay) / (1.0 - delay);
        final progress = Curves.easeOutCubic.transform(raw.clamp(0.0, 1.0));
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 36 * (1 - progress)), // slides up from below
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => setState(() {
          if (isExpanded) {
            _expanded.remove(index);
          } else {
            _expanded.add(index);
          }
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground(context),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isExpanded
                  ? AppColors.primary.withOpacity(0.4)
                  : AppColors.border(context),
              width: isExpanded ? 1.0 : 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isExpanded
                    ? AppColors.primary.withOpacity(0.12)
                    : AppColors.shadow(context),
                blurRadius: isExpanded ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [

              // header row
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [

                    // 3D icon — uses float not rotation
                    AnimatedBuilder(
                      animation: _floatCtrl,
                      builder: (_, child) {
                        final t = (_floatCtrl.value + index * 0.18) % 1.0;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(-0.15 + 0.08 * math.sin(t * math.pi * 2))
                            ..rotateX(0.08 + 0.04 * math.cos(t * math.pi * 2)),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: section.color,
                          borderRadius: BorderRadius.circular(13),
                          boxShadow: [
                            BoxShadow(
                                color: section.color.withOpacity(0.45),
                                blurRadius: 14,
                                offset: const Offset(0, 6)),
                            BoxShadow(
                                color: Colors.white.withOpacity(0.18),
                                blurRadius: 4,
                                offset: const Offset(-2, -2)),
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
                              style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),

                          // tag pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: section.tagColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: section.tagColor.withOpacity(0.3),
                                  width: 0.5),
                            ),
                            child: Text(section.tag,
                                style: TextStyle(
                                    color: section.tagColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),

                    // animated expand arrow — translate not rotate
                    AnimatedSlide(
                      offset: isExpanded
                          ? const Offset(0, 0.1)
                          : const Offset(0, 0),
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.25 : 0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: Icon(Icons.arrow_forward_ios_rounded,
                            color: isExpanded
                                ? AppColors.primary
                                : AppColors.iconDefault(context),
                            size: 14),
                      ),
                    ),
                  ],
                ),
              ),

              // expanded body — animated height
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 300),
                crossFadeState: isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(color: AppColors.border(context), height: 1),
                      const SizedBox(height: 12),
                      Text(
                        section.body,
                        style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 13,
                            height: 1.6),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────
// LETTER BOUNCE WIDGET
// ──────────────────────────────────────────
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
            final start   = (index / text.length) * 0.6;
            final end     = start + 0.4;
            final t       = ((controller.value - start) / (end - start)).clamp(0.0, 1.0);
            final bounce  = Curves.elasticOut.transform(t);
            final fade    = Curves.easeOut.transform(t);
            return Opacity(
              opacity: fade,
              child: Transform.translate(
                offset: Offset(0, -18 * (1 - bounce)),
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

// ──────────────────────────────────────────
// WAVE PAINTER
// ──────────────────────────────────────────
class _WavePainter extends CustomPainter {
  final double progress;
  final Color color;
  _WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void drawWave(double hf, double amp, double speed, double phase, double opacity) {
      final paint = Paint()..color = color.withOpacity(opacity)..style = PaintingStyle.fill;
      final path  = Path();
      path.moveTo(0, h);
      for (double x = 0; x <= w; x += 2) {
        final y = h * hf +
            amp * math.sin((x / w * 2 * math.pi * 2) + progress * 2 * math.pi * speed + phase);
        path.lineTo(x, y);
      }
      path.lineTo(w, h);
      path.close();
      canvas.drawPath(path, paint);
    }

    drawWave(0.55, 16, 1.0, 0.0,  1.0);
    drawWave(0.45, 12, 1.3, 1.2,  0.6);
    drawWave(0.35, 10, 0.8, 2.4,  0.35);
  }

  @override
  bool shouldRepaint(_WavePainter old) =>
      old.progress != progress || old.color != color;
}

// ──────────────────────────────────────────
// MORPHING BLOB PAINTER (no rotation)
// Blob morphs between different shapes
// ──────────────────────────────────────────
class _MorphBlobPainter extends CustomPainter {
  final double progress;
  _MorphBlobPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    final path = Path();
    final points = 8;

    for (int i = 0; i <= points; i++) {
      final angle  = (i / points) * 2 * math.pi;
      // radius morphs between two shapes using sin
      final r = 55 +
          18 * math.sin(angle * 3 + progress * math.pi * 2) +
          10 * math.cos(angle * 2 + progress * math.pi);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);

    // second inner blob
    final paint2 = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;
    final path2 = Path();
    for (int i = 0; i <= points; i++) {
      final angle = (i / points) * 2 * math.pi;
      final r = 35 +
          12 * math.sin(angle * 2 + progress * math.pi * 1.5) +
          8  * math.cos(angle * 4 + progress * math.pi * 0.8);
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) path2.moveTo(x, y); else path2.lineTo(x, y);
    }
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(_MorphBlobPainter old) => old.progress != progress;
}

// ──────────────────────────────────────────
// DOT GRID PAINTER — breathes, no rotation
// ──────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  final double opacity;
  _DotGridPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(opacity * 0.3);
    const cols = 5;
    const rows = 4;
    final gx   = size.width  / cols;
    final gy   = size.height / rows;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(gx * c + gx / 2, gy * r + gy / 2),
          2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.opacity != opacity;
}

// ──────────────────────────────────────────
// DATA MODELS
// ──────────────────────────────────────────
class _PolicySection {
  final IconData icon;
  final String title;
  final String body;
  final Color color;
  final String tag;
  final Color tagColor;

  const _PolicySection({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
    required this.tag,
    required this.tagColor,
  });
}