import 'dart:math' as math;
import 'package:add_to_cart_animation/add_to_cart_animation.dart';
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/auth_view_model.dart';
import 'package:ecommerceapp/view_model/store_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen>
    with TickerProviderStateMixin {

  final GlobalKey<CartIconKey> _cartKey   = GlobalKey<CartIconKey>();
  late Function(GlobalKey)     _runAnim;
  int                          _cartCount = 0;


  final List<GlobalKey> _imageKeys = [];

 
  bool _cancelled = false;


  late AnimationController _bounceCtrl;
  late Animation<double>   _bounce;

  late AnimationController _auroraCtrl;

  late AnimationController _floatCtrl;

  @override
  void initState() {
    super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final cartBox = authVM.getCartBox();
    if (mounted) {
      setState(() {
        _cartCount = cartBox.length;
      });
      _cartKey.currentState?.updateBadge(_cartCount.toString());
    }
  });

    _bounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _bounce = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeOut));

    _auroraCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..forward();

    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cancelled = true;
    _bounceCtrl.dispose();
    _auroraCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _syncKeys(int count) {
    while (_imageKeys.length < count) _imageKeys.add(GlobalKey());
    while (_imageKeys.length > count) _imageKeys.removeLast();
  }

  Future<void> _addToCart(
      GlobalKey imageKey, String name, StoreViewModel vm) async {
    if (!mounted || _cancelled) return;

    final authVM  = Provider.of<AuthViewModel>(context, listen: false);
    final cartBox = authVM.getCartBox();
    final exists  = cartBox.values.any((i) => i.productName == name);

    if (exists) {
      if (mounted) _snack('$name already in cart', AppColors.warning);
      return;
    }

    if (!mounted || _cancelled) return;

    
    try {
      await _runAnim(imageKey);
    } catch (_) {
      return;
    }

    if (!mounted || _cancelled) return;

    try {
      await _cartKey.currentState
          ?.runCartAnimation((++_cartCount).toString());
    } catch (_) {
      return;
    }

    if (!mounted || _cancelled) return;
    _bounceCtrl.forward(from: 0);

    final product = vm.favList.firstWhere(
      (p) => p['productName'] == name,
      orElse: () => {},
    );
    if (product.isNotEmpty) {
      await vm.addSingleToCart(Map<String, dynamic>.from(product), cartBox);
    }

    if (mounted && !_cancelled) {
      _snack('Added $name to cart', AppColors.success);
    }
  }

  Future<void> _addAll(StoreViewModel vm) async {
  final snapshot = List.from(vm.favList);

  for (int i = 0; i < snapshot.length; i++) {
    if (!mounted || _cancelled) return;
    if (i >= _imageKeys.length) break;

    final name = snapshot[i]['productName'] ?? '';
    final key  = _imageKeys[i];

    if (key.currentContext == null) continue;

    await _addToCart(key, name, vm);

    if (!mounted || _cancelled) return;
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted || _cancelled) return;
  }


  if (mounted) {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final cartBox = authVM.getCartBox();
    setState(() => _cartCount = cartBox.length);
  }
}

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreViewModel>(
      builder: (context, vm, _) {
        final favList  = vm.favList;
        final favCount = favList.length;
        _syncKeys(favCount);

        return AddToCartAnimation(
          cartKey: _cartKey,
          height: 30,
          width: 30,
          opacity: 0.85,
          dragAnimation: const DragToCartAnimationOptions(
            rotation: true,
            curve: Curves.fastOutSlowIn,
            duration: Duration(milliseconds: 700),
          ),
          jumpAnimation: const JumpAnimationOptions(
            active: true,
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: 180),
          ),
          createAddToCartAnimation: (fn) => _runAnim = fn,
          child: Scaffold(
            backgroundColor: AppColors.background(context),
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [

                SliverAppBar(
                  pinned: true,
                  expandedHeight: 0,
                  backgroundColor: AppColors.background(context),
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Text('My Wishlist',
                      style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  actions: [
            
                    AnimatedBuilder(
                      animation: _bounce,
                      builder: (_, child) => Transform.scale(
                        scale: _bounce.value,
                        child: child,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Container(
                          padding:const EdgeInsets.only(right: 10) ,
                          width: 60, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.border(context), width: 0.5),
                          ),
                          child: AddToCartIcon(
                            key: _cartKey,
                            icon: Icon(Icons.shopping_cart_rounded,
                                color: AppColors.textPrimary(context),
                                size: 18),
                          badgeOptions: BadgeOptions(
  active: _cartCount > 0,
  backgroundColor: AppColors.accent,
  foregroundColor: Colors.white,
  width: 18,
  height: 18,
  fontSize: 9,
),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              
                SliverToBoxAdapter(
                  child: _buildHeroCard(context, vm, favCount),
                ),

             
                if (favCount == 0)
                  SliverFillRemaining(child: _buildEmpty(context))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _WishlistCard(
                          product:
                              Map<String, dynamic>.from(favList[index]),
                          index:    index,
                          viewModel: vm,
                          imageKey:  _imageKeys[index],
                          onAddToCart: (key, name) =>
                              _addToCart(key, name, vm),
                        ),
                        childCount: favCount,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroCard(
      BuildContext context, StoreViewModel vm, int favCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.primaryShadow,
        ),
        child: Stack(
          children: [

            Positioned(
              right: -8, top: -8,
              child: AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _BlobPainter(progress: _floatCtrl.value),
                  size: const Size(100, 100),
                ),
              ),
            ),

       
            Positioned(
              left: 0, bottom: 0,
              child: AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, __) => Opacity(
                  opacity: 0.1 + _floatCtrl.value * 0.08,
                  child: CustomPaint(
                    painter: _DotsPainter(),
                    size: const Size(80, 50),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AnimatedBuilder(
                  animation: _auroraCtrl,
                  builder: (_, __) => CustomPaint(
                    painter: _AuroraPainter(progress: _auroraCtrl.value),
                  ),
                ),
              ),
            ),

            Row(
              children: [

                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withOpacity(0.4), width: 1.5),
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: Colors.white, size: 28),
                ),

                const SizedBox(width: 16),

         
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      const Text('My Wishlist',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2)),

                      const SizedBox(height: 3),

                      Text(
                        '$favCount ${favCount == 1 ? 'item' : 'items'} saved',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 12),
                      ),

                      if (favCount > 0) ...[
                        const SizedBox(height: 10),
                        _AddAllBtn(onTap: () => _addAll(vm)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88, height: 88,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer(context),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.favorite_border_rounded,
                size: 42, color: AppColors.primaryText(context)),
          ),
          const SizedBox(height: 20),
          Text('Your wishlist is empty',
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Save items you love and find them here',
              style: TextStyle(
                  color: AppColors.textSecondary(context), fontSize: 14)),
        ],
      ),
    );
  }
}

class _AddAllBtn extends StatefulWidget {
  final Future<void> Function() onTap;
  const _AddAllBtn({required this.onTap});

  @override
  State<_AddAllBtn> createState() => _AddAllBtnState();
}

class _AddAllBtnState extends State<_AddAllBtn>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  late Animation<double>   _scale;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _ctrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.93)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { if (!_running && mounted) _ctrl.forward(); },
      onTapUp: (_) async {
        if (!mounted) return;
        _ctrl.reverse();
        if (_running) return;
        if (mounted) setState(() => _running = true);
        try {
          await widget.onTap();
        } catch (_) {}
        if (mounted) setState(() => _running = false);
      },
      onTapCancel: () { if (mounted) _ctrl.reverse(); },
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedOpacity(
          opacity: _running ? 0.65 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.white.withOpacity(0.3), width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _running
                    ? const SizedBox(
                        width: 12, height: 12,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.shopping_cart_checkout_rounded,
                        color: Colors.white, size: 14),
                const SizedBox(width: 6),
                Text(
                  _running ? 'Adding...' : 'Add all to Cart',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WishlistCard extends StatefulWidget {
  final Map<String, dynamic>               product;
  final int                                index;
  final StoreViewModel                     viewModel;
  final GlobalKey                          imageKey;
  final Future<void> Function(GlobalKey, String) onAddToCart;

  const _WishlistCard({
    required this.product,
    required this.index,
    required this.viewModel,
    required this.imageKey,
    required this.onAddToCart,
  });

  @override
  State<_WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<_WishlistCard>
    with TickerProviderStateMixin {

  late AnimationController _entryCtrl;
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  late AnimationController _pressCtrl;
  late Animation<double>   _pressScale;
  late Animation<double>   _elevate;

  bool _adding = false;

  @override
  void initState() {
    super.initState();

    _entryCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 500));
    _fade  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryCtrl, curve: Curves.easeOutCubic));

    _pressCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 140));
    _pressScale = Tween<double>(begin: 1.0, end: 1.03)
        .animate(CurvedAnimation(
            parent: _pressCtrl, curve: Curves.easeOut));
    _elevate = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
            parent: _pressCtrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.index * 80),
        () { if (mounted) _entryCtrl.forward(); });
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name     = widget.product['productName']      ?? 'Unknown';
    final price    = (widget.product['productPrice']    ?? 0).toString();
    final category = widget.product['categoryName']     ?? '';
    final images   = widget.product['productImageUrls'] as List?;
    final imageUrl =
        (images != null && images.isNotEmpty) ? images[0] : null;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: (_) => _pressCtrl.forward(),
          onTapUp:   (_) => _pressCtrl.reverse(),
          onTapCancel: () => _pressCtrl.reverse(),
          child: AnimatedBuilder(
            animation: _pressCtrl,
            builder: (_, child) => Transform.scale(
              scale: _pressScale.value,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground(context),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.border(context), width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow(context),
                      blurRadius: 8 + _elevate.value * 14,
                      offset: Offset(0, 2 + _elevate.value * 5),
                    ),
                    if (_elevate.value > 0.5)
                      BoxShadow(
                        color: AppColors.primary
                            .withOpacity(_elevate.value * 0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: child,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: Hero(
                    tag: 'fav_img_${widget.index}',
                    child: Container(
                      key: widget.imageKey,
                      width: 110, height: 120,
                      color: AppColors.surfaceVariant(context),
                      child: imageUrl != null
                          ? Image.network(imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                  Icons.image_outlined,
                                  size: 40,
                                  color: AppColors.textHint(context)))
                          : Icon(Icons.image_outlined,
                              size: 40,
                              color: AppColors.textHint(context)),
                    ),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(name,
                            style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontSize: 14,
                                fontWeight: FontWeight.w600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),

                        const SizedBox(height: 5),

                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer(context),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(category,
                              style: TextStyle(
                                  color: AppColors.primaryText(context),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500)),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                     
                            ShaderMask(
                              shaderCallback: (b) =>
                                  AppColors.primaryGradient.createShader(b),
                              child: Text('\$$price',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                            ),

                            Row(
                              children: [

                               
                                _Btn(
                                  icon: _adding
                                      ? Icons.hourglass_top_rounded
                                      : Icons.shopping_cart_outlined,
                                  gradient: AppColors.primaryGradient,
                                  shadow: AppColors.primary,
                                  disabled: _adding,
                                  onTap: () async {
                                    if (_adding || !mounted) return;
                                    setState(() => _adding = true);
                                    await widget.onAddToCart(
                                        widget.imageKey, name);
                                    if (mounted) {
                                      setState(() => _adding = false);
                                    }
                                  },
                                ),

                                const SizedBox(width: 8),

                       
                                _Btn(
                                  icon: Icons.delete_outline_rounded,
                                  color: AppColors.error,
                                  shadow: AppColors.error,
                                  onTap: () {
                                    widget.viewModel
                                        .removeFromFavorites(name);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'Removed $name from wishlist'),
                                      backgroundColor: AppColors.error,
                                      duration:
                                          const Duration(seconds: 1),
                                    ));
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _Btn extends StatelessWidget {
  final IconData        icon;
  final LinearGradient? gradient;
  final Color?          color;
  final Color           shadow;
  final VoidCallback    onTap;
  final bool            disabled;

  const _Btn({
    required this.icon,
    this.gradient,
    this.color,
    required this.shadow,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedOpacity(
        opacity: disabled ? 0.5 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            gradient: gradient,
            color: color,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [BoxShadow(
                color: shadow.withOpacity(0.28),
                blurRadius: 6,
                offset: const Offset(0, 3))],
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double progress;
  _AuroraPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final x    = size.width * 1.5 * progress - size.width * 0.25;
    final peak = math.sin(progress * math.pi);
    canvas.drawPath(
      Path()
        ..moveTo(x - 100, 0)
        ..lineTo(x + 60,  0)
        ..lineTo(x + 30,  size.height)
        ..lineTo(x - 130, size.height)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.white.withOpacity(0.06 * peak),
            Colors.white.withOpacity(0.14 * peak),
            Colors.white.withOpacity(0.06 * peak),
            Colors.transparent,
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        ).createShader(Rect.fromLTWH(x - 100, 0, 200, size.height)),
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter o) => o.progress != progress;
}

class _BlobPainter extends CustomPainter {
  final double progress;
  _BlobPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;
    final path = Path();
    const pts = 8;
    for (int i = 0; i <= pts; i++) {
      final a = (i / pts) * 2 * math.pi;
      final r = 36 +
          12 * math.sin(a * 3 + progress * math.pi * 2) +
          7  * math.cos(a * 2 + progress * math.pi);
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BlobPainter o) => o.progress != progress;
}

class _DotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white..style = PaintingStyle.fill;
    const cols = 4; const rows = 3;
    final gx = size.width / cols;
    final gy = size.height / rows;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
            Offset(gx * c + gx / 2, gy * r + gy / 2), 1.2, p);
      }
    }
  }

  @override
  bool shouldRepaint(_DotsPainter o) => false;
}