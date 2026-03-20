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
    with SingleTickerProviderStateMixin {

  final GlobalKey<CartIconKey> _cartKey       = GlobalKey<CartIconKey>();
  late Function(GlobalKey)     _runAnimation;
  int                          _cartCount     = 0;
  final List<GlobalKey>        _imageKeys     = [];

  late AnimationController _cartBounceCtrl;
  late Animation<double>   _cartBounce;

  @override
  void initState() {
    super.initState();
    _cartBounceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _cartBounce = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _cartBounceCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _cartBounceCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleAddToCart(
      GlobalKey imageKey, String name, StoreViewModel viewModel) async {
    final authVM  = Provider.of<AuthViewModel>(context, listen: false);
    final cartBox = authVM.getCartBox();
    final exists  = cartBox.values.any((i) => i.productName == name);

    if (exists) {
      _showSnack('$name already in cart', AppColors.warning);
      return;
    }

    await _runAnimation(imageKey);
    await _cartKey.currentState!
        .runCartAnimation((++_cartCount).toString());
    _cartBounceCtrl.forward(from: 0);

    final product = viewModel.favList.firstWhere(
      (p) => p['productName'] == name,
      orElse: () => {},
    );
    if (product.isNotEmpty) {
      await viewModel.addSingleToCart(
          Map<String, dynamic>.from(product), cartBox);
    }

    if (mounted) _showSnack('Added $name to cart', AppColors.success);
  }

  Future<void> _handleAddAll(StoreViewModel viewModel) async {
    final favList = viewModel.favList;
    for (int i = 0; i < favList.length; i++) {
      if (i >= _imageKeys.length) break;
      final name = favList[i]['productName'] ?? '';
      final key  = _imageKeys[i];
      if (key.currentContext != null) {
        await _handleAddToCart(key, name, viewModel);
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      duration: const Duration(seconds: 1),
    ));
  }

  void _syncKeys(int count) {
    while (_imageKeys.length < count) _imageKeys.add(GlobalKey());
    while (_imageKeys.length > count) _imageKeys.removeLast();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoreViewModel>(
      builder: (context, viewModel, _) {
        final favList  = viewModel.favList;
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
          createAddToCartAnimation: (fn) => _runAnimation = fn,
          child: Scaffold(
            backgroundColor: AppColors.background(context),
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [

                SliverPersistentHeader(
                  pinned: true,
                  delegate: _HeaderDelegate(
                    cartKey:    _cartKey,
                    cartBounce: _cartBounce,
                    favCount:   favCount,
                    viewModel:  viewModel,
                    onAddAll:   () => _handleAddAll(viewModel),
                  ),
                ),

                if (favCount == 0)
                  SliverFillRemaining(child: _buildEmpty(context))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _WishlistCard(
                          product:    Map<String, dynamic>.from(favList[index]),
                          index:      index,
                          viewModel:  viewModel,
                          imageKey:   _imageKeys[index],
                          onAddToCart: (key, name) =>
                              _handleAddToCart(key, name, viewModel),
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
class _HeaderDelegate extends SliverPersistentHeaderDelegate {
  final GlobalKey<CartIconKey> cartKey;
  final Animation<double>      cartBounce;
  final int                    favCount;
  final StoreViewModel         viewModel;
  final VoidCallback           onAddAll;

  _HeaderDelegate({
    required this.cartKey,
    required this.cartBounce,
    required this.favCount,
    required this.viewModel,
    required this.onAddAll,
  });

  @override double get minExtent => 72;
  @override double get maxExtent => favCount > 0 ? 200 : 160;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final t   = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final top = MediaQuery.of(context).padding.top;

    return _HeaderWidget(
      shrinkT:    t,
      top:        top,
      cartKey:    cartKey,
      cartBounce: cartBounce,
      favCount:   favCount,
      viewModel:  viewModel,
      onAddAll:   onAddAll,
    );
  }

  @override
  bool shouldRebuild(_HeaderDelegate old) =>
      old.favCount != favCount;
}

class _HeaderWidget extends StatefulWidget {
  final double                 shrinkT;
  final double                 top;
  final GlobalKey<CartIconKey> cartKey;
  final Animation<double>      cartBounce;
  final int                    favCount;
  final StoreViewModel         viewModel;
  final VoidCallback           onAddAll;

  const _HeaderWidget({
    required this.shrinkT,
    required this.top,
    required this.cartKey,
    required this.cartBounce,
    required this.favCount,
    required this.viewModel,
    required this.onAddAll,
  });

  @override
  State<_HeaderWidget> createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<_HeaderWidget>
    with TickerProviderStateMixin {

  late AnimationController _entryCtrl;
  late AnimationController _floatCtrl;
  late AnimationController _auroraCtrl;
  late Animation<double>   _fade1;
  late Animation<Offset>   _slide1;
  late Animation<double>   _fade2;
  late Animation<Offset>   _slide2;

  @override
  void initState() {
    super.initState();
    _entryCtrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 900))..forward();
    _floatCtrl  = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 4000))..repeat(reverse: true);
    _auroraCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1600))..forward();

    _fade1  = CurvedAnimation(parent: _entryCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut));
    _slide1 = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)));
    _fade2  = CurvedAnimation(parent: _entryCtrl,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut));
    _slide2 = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entryCtrl,
            curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic)));
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _floatCtrl.dispose();
    _auroraCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final collapsed = widget.shrinkT > 0.85;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(collapsed ? 0 : 28),
          bottomRight: Radius.circular(collapsed ? 0 : 28),
        ),
        boxShadow: [BoxShadow(
          color: Colors.black
              .withOpacity(0.12 + widget.shrinkT * 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        )],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [

          if (!collapsed) ..._rings(),

   
          if (!collapsed)
            Positioned(
              top: 30, left: 60,
              child: AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, __) => Opacity(
                  opacity: 0.15 +
                      0.1 * math.sin(_floatCtrl.value * math.pi),
                  child: CustomPaint(
                    painter: _DotsPainter(),
                    size: const Size(60, 40),
                  ),
                ),
              ),
            ),

          if (widget.shrinkT < 0.5)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _auroraCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _AuroraPainter(progress: _auroraCtrl.value),
                ),
              ),
            ),

   
          Positioned(
            top: widget.top + 8,
            left: 16, right: 16,
            bottom: 12,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

             
                      FadeTransition(
                        opacity: _fade1,
                        child: SlideTransition(
                          position: _slide1,
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: collapsed ? 16 : 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                            child: const Text('My Wishlist'),
                          ),
                        ),
                      ),

                      if (!collapsed) ...[
                        const SizedBox(height: 4),

                    
                        FadeTransition(
                          opacity: _fade2,
                          child: SlideTransition(
                            position: _slide2,
                            child: Text(
                              '${widget.favCount} ${widget.favCount == 1 ? 'item' : 'items'} saved',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.72),
                                  fontSize: 13),
                            ),
                          ),
                        ),

                        if (widget.favCount > 0) ...[
                          const SizedBox(height: 10),

              
                          FadeTransition(
                            opacity: _fade1,
                            child: _AddAllBtn(onTap: widget.onAddAll),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

         
                AnimatedBuilder(
                  animation: widget.cartBounce,
                  builder: (_, child) => Transform.scale(
                    scale: widget.cartBounce.value,
                    child: child,
                  ),
                  child: AddToCartIcon(
                    key: widget.cartKey,
                    icon: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 0.8),
                      ),
                      child: const Icon(Icons.shopping_cart_rounded,
                          color: Colors.white, size: 22),
                    ),
                    badgeOptions: BadgeOptions(
                      active: true,
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      width: 20,
                      height: 20,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _rings() => [
    Positioned(
      top: -20, right: -20,
      child: AnimatedBuilder(
        animation: _floatCtrl,
        builder: (_, __) => Transform.translate(
          offset: Offset(
            4 * math.sin(_floatCtrl.value * math.pi),
            -3 * math.cos(_floatCtrl.value * math.pi),
          ),
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.08), width: 1),
            ),
          ),
        ),
      ),
    ),
    Positioned(
      bottom: -30, left: -30,
      child: AnimatedBuilder(
        animation: _floatCtrl,
        builder: (_, __) => Transform.translate(
          offset: Offset(
            -3 * math.cos(_floatCtrl.value * math.pi),
            4 * math.sin(_floatCtrl.value * math.pi + 1),
          ),
          child: Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.06), width: 1),
            ),
          ),
        ),
      ),
    ),
  ];
}

class _AddAllBtn extends StatefulWidget {
  final VoidCallback onTap;
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
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) { if (!_running) _ctrl.forward(); },
      onTapUp: (_) async {
        _ctrl.reverse();
        if (_running) return;
        setState(() => _running = true);
        widget.onTap();
       
        await Future.delayed(const Duration(seconds: 4));
        if (mounted) setState(() => _running = false);
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedOpacity(
          opacity: _running ? 0.65 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                  color: Colors.white.withOpacity(0.25), width: 0.8),
              boxShadow: AppColors.accentShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _running
                    ? const SizedBox(
                        width: 14, height: 14,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                    : const Icon(
                        Icons.shopping_cart_checkout_rounded,
                        color: Colors.white, size: 15),
                const SizedBox(width: 7),
                Text(
                  _running ? 'Adding...' : 'Add all to Cart',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
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
  late Animation<double>   _scale;
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
        .animate(CurvedAnimation(parent: _entryCtrl,
            curve: Curves.easeOutCubic));

    _pressCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 140));
    _scale   = Tween<double>(begin: 1.0, end: 1.03)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
    _elevate = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));

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
              scale: _scale.value,
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
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
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
                                    if (_adding) return;
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
  final IconData         icon;
  final LinearGradient?  gradient;
  final Color?           color;
  final Color            shadow;
  final VoidCallback     onTap;
  final bool             disabled;

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