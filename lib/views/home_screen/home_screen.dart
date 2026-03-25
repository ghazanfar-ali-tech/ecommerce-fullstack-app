import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/auth_view_model.dart';
import 'package:ecommerceapp/view_model/home_view_mode.dart';
import 'package:ecommerceapp/view_model/product_review_view_model.dart';
import 'package:ecommerceapp/views/detail_screen/detail_screen.dart';
import 'package:ecommerceapp/views/home_screen/cart_screen/cart_screen.dart';
import 'package:ecommerceapp/views/home_screen/curve_clipper.dart';
import 'package:ecommerceapp/views/home_screen/search_screen.dart';
import 'package:ecommerceapp/views/home_screen/widgets/category_items_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as badges;
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  bool _isSearching = false; 

  

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().initialize();
    });
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });
  }
  

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
 body: Consumer<HomeViewModel>(
  builder: (context, viewModel, child) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
         SliverToBoxAdapter(
  child: Stack(
    clipBehavior: Clip.none, 
    children: [
   
      _buildHeaderSection(context, viewModel),

     Positioned(
  bottom: -2,
  left: 16,
  right: 16,
  child: GestureDetector(
    onTap: () => Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SearchScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    ),
    child: Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, color: AppColors.info, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Search products...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
          Container(width: 1, height: 20, color: AppColors.border(context)),
          
          Container(
            width: 55,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(14),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 19),
          ),
        ],
      ),
    ),
  ),
),
    ],
  ),
),

        
          SliverToBoxAdapter(
            child: _buildProductSection(context, viewModel),
          ),
        ],
      ),
    );
  },
),
    );
  }


  Widget _buildHeaderSection(BuildContext context, HomeViewModel viewModel) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.36,
      width: MediaQuery.of(context).size.width,
      child: ClipPath(
        clipper: CurveClipper(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.30,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildHeaderContent(context, viewModel),
              if (!viewModel.showCategories &&
                  !viewModel.hasVideoError &&
                  viewModel.isVideoInitialized)
                _buildVideoOverlay(),
              if (!viewModel.showCategories &&
                  !viewModel.hasVideoError &&
                  viewModel.isVideoInitialized)
                _buildPromotionalText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context, HomeViewModel viewModel) {
    if (viewModel.showCategories || viewModel.hasVideoError) {
      return _buildCategoriesView(context, viewModel);
    } else if (viewModel.isVideoInitialized) {
      return _buildVideoPlayer(viewModel);
    } else {
      return _buildLoadingState();
    }
  }

  Widget _buildCategoriesView(BuildContext context, HomeViewModel viewModel) {
    return _AnimatedCategoryHeader(
    viewModel: viewModel,
    categoriesList: _buildCategoriesList(viewModel), 
  );
  }

  Widget _buildCategoriesList(HomeViewModel viewModel) {
    return SizedBox(
      height: 85,
      child: StreamBuilder<QuerySnapshot>(
        stream: viewModel.getCategoriesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.white));
          }
          final categories = snapshot.data!.docs;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item =
                  categories[index].data() as Map<String, dynamic>;
              return buildCategoryItemFromFirestore(
                context,  
                item['imageUrl'] ?? '',
                item['categoryName'] ?? 'Unknown',
                
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVideoPlayer(HomeViewModel viewModel) {
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: viewModel.videoController!.value.size.width,
        height: viewModel.videoController!.value.size.height,
        child: VideoPlayer(viewModel.videoController!),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildVideoOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.5),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionalText() {
    return Positioned(
      top: 60, left: 24, right: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New Collection',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Up to 50% OFF',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProductSection(BuildContext context, HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
         if (!_isSearching) ...[
          _buildCarouselSlider(viewModel),
          const SizedBox(height: 10),
          _buildCarouselIndicator(viewModel),
          const SizedBox(height: 4),
        ],
    
          _buildSectionHeader(context),
          const SizedBox(height: 10),
          _buildProductGrid(context, viewModel),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCarouselSlider(HomeViewModel viewModel) {
    final List<String> carouselImages = [
      "https://img.freepik.com/free-vector/gradient-shopping-discount-horizontal-sale-banner_23-2150321996.jpg?w=740&q=80",
      "https://img.freepik.com/premium-vector/sport-collection-promotion-social-media-facebook-banner-template_252779-280.jpg?w=740&q=80",
      "https://m.media-amazon.com/images/S/stores-image-uploads-na-prod/3/AmazonStores/ATVPDKIKX0DER/74883b9609f8c50ea9c18969a7a85267.w1900.h600.png",
      "https://img.freepik.com/free-psd/black-friday-super-sale-facebook-cover-banner-template_120329-5177.jpg?w=740&q=80",
      "https://images.unsplash.com/photo-1512436991641-6745cdb1723f",
    ];

    return CarouselSlider(
      items: carouselImages.map((url) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey.shade200,
              child: Icon(Icons.image, size: 60, color: Colors.grey.shade400),
            ),
          ),
        );
      }).toList(),
      options: CarouselOptions(
       height: 185,
      viewportFraction: 1,
      enlargeCenterPage: true,
      enlargeStrategy: CenterPageEnlargeStrategy.scale,
      padEnds: false,
      autoPlay: true,
      enableInfiniteScroll: true,
      pauseAutoPlayOnTouch: true,
        onPageChanged: (index, _) =>
            viewModel.currentCarouselIndex = index,
      ),
    );
  }

  Widget _buildCarouselIndicator(HomeViewModel viewModel) {
    return Center(
      child: AnimatedSmoothIndicator(
        activeIndex: viewModel.currentCarouselIndex,
        count: 5,
        effect: ExpandingDotsEffect(
          dotHeight: 5,
          dotWidth: 5,
          spacing: 5,
          expansionFactor: 4,
          activeDotColor: AppColors.primary,
          dotColor: Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Featured Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
            letterSpacing: -0.3,
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            children: [
              Text(
                'See All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 11, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(BuildContext context, HomeViewModel viewModel) {
    final products = viewModel.filteredProducts;

    if (products.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded,
                  size: 48, color: AppColors.info),
              const SizedBox(height: 12),
              Text(
                'No products found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        final productId = p['id'];
        final productName = p['productName'] ?? 'N/A';
        final productPrice = (p['productPrice'] ?? 0).toString();
        final productDescription = p['productDescription'] ?? '';
        final productDiscount = p['productDiscount'] ?? 0;
        final categoryName = p['categoryName'] ?? 'Uncategorized';
        final productImageUrls = (p['productImageUrls'] as List<dynamic>?)
                ?.map((u) => u.toString())
                .toList() ??
            [];
        final productImage =
            productImageUrls.isNotEmpty ? productImageUrls[0] : '';

        return _ProductCard(
          productId: productId,
          productName: productName,
          productPrice: productPrice,
          productDescription: productDescription,
          productDiscount: productDiscount,
          productImage: productImage,
          productImageUrls: productImageUrls,
          categoryName: categoryName,
          onTap: () {
            context
                .read<ProductReviewViewModel>()
                .fetchReviews(productId);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(
                  productId: productId,
                  productName: productName,
                  price: double.parse(productPrice).toInt(),
                  discount: productDiscount,
                  productImageUrls: productImageUrls,
                  description: productDescription,
                  categoryName: categoryName,
                ),
              ),
            );
          },
          onAddToCart: () => viewModel.onAddToCart(productId),
          onFavorite: () => viewModel.onFavoriteTap(productId),
        );
      },
    );
  }
}




class _ProductCard extends StatelessWidget {
  final String productId;
  final String productName;
  final String productPrice;
  final String productDescription;
  final int productDiscount;
  final String productImage;
  final List<String> productImageUrls;
  final String categoryName;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onFavorite;

  const _ProductCard({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productDescription,
    required this.productDiscount,
    required this.productImage,
    required this.productImageUrls,
    required this.categoryName,
    required this.onTap,
    required this.onAddToCart,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: productImage.isNotEmpty
                        ? Image.network(
                            productImage,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _imageFallback(context),
                          )
                        : _imageFallback(context),
                  ),

                  if (productDiscount > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$productDiscount% OFF',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onFavorite,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_border_rounded,
                          size: 15,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context),
                        height: 1.3,
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$$productPrice',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
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
    );
  }

  Widget _imageFallback(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 48,
        color: AppColors.primary.withOpacity(0.4),
      ),
    );
  }
}








class _AnimatedCategoryHeader extends StatefulWidget {
  final HomeViewModel viewModel;
  final Widget categoriesList;
  const _AnimatedCategoryHeader({required this.viewModel,required this.categoriesList,});

  @override
  State<_AnimatedCategoryHeader> createState() =>
      _AnimatedCategoryHeaderState();
}

class _AnimatedCategoryHeaderState extends State<_AnimatedCategoryHeader>
    with TickerProviderStateMixin {

  late AnimationController _starCtrl;   
  late AnimationController _floatCtrl; 
  late AnimationController _cloudCtrl;  
  late AnimationController _rayCtrl;    
  late AnimationController _shootCtrl;  

  late AnimationController _bgCtrl;

  final _rand = math.Random(42);


  late final List<_Star> _stars = List.generate(28, (i) => _Star(
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
      painter: _GeometricBgPainter(
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
    painter: _CrescentMoonPainter(),
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
                      painter: _SunRayPainter(color: sunColor),
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

class _Star {
  final double x, y, r, phase, speed;
  const _Star({required this.x, required this.y, required this.r,
      required this.phase, required this.speed});
}


class _SunRayPainter extends CustomPainter {
  final Color color;
  _SunRayPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    const rays   = 8;
    const inner  = 20.0;
    const outer  = 28.0;

    for (int i = 0; i < rays; i++) {
      final angle = (i / rays) * 2 * math.pi;
      canvas.drawLine(
        Offset(center.dx + inner * math.cos(angle),
               center.dy + inner * math.sin(angle)),
        Offset(center.dx + outer * math.cos(angle),
               center.dy + outer * math.sin(angle)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SunRayPainter old) => old.color != color;
}


class _CrescentMoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE8EAF6);

    final double r = size.width / 2;
    final center = Offset(r, r);


    final path = Path()..addOval(Rect.fromCircle(center: center, radius: r));

   
    final cutPath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(r + r * 0.45, r - r * 0.1),
        radius: r * 0.85,
      ));

    final crescent = Path.combine(PathOperation.difference, path, cutPath);
    canvas.drawPath(crescent, paint);

    
    final craterPaint = Paint()..color = Colors.white.withOpacity(0.25);
    canvas.drawCircle(Offset(r * 0.45, r * 0.65), 2.5, craterPaint);
    canvas.drawCircle(Offset(r * 0.3, r * 0.9), 1.5, craterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GeometricBgPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _GeometricBgPainter({required this.progress, required this.isDark});

  double get t => progress * 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawGlow(canvas, Offset(w - 30 + 6 * math.sin(t * 0.7), 10 + 5 * math.cos(t * 0.5)), 90, isDark);
    _drawGlow(canvas, Offset(18 + 5 * math.cos(t * 0.6), h - 28 + 6 * math.sin(t * 0.8)), 70, isDark);
    _drawGlow(canvas, Offset(w * 0.5 + 10 * math.sin(t * 0.4), h * 0.5 + 8 * math.cos(t * 0.3)), 50, isDark);

    final hexScale1 = 1.0 + 0.06 * math.sin(t * 0.9);
    _drawHexagon(
      canvas,
      center: Offset(w - 38 + 4 * math.sin(t * 0.5), -10 + 4 * math.cos(t * 0.4)),
      radius: 58 * hexScale1,
      rotation: t * 0.15,
      paint: Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(isDark ? 0.18 : 0.22),
            Colors.white.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: Offset(w - 38, -10), radius: 58))
        ..style = PaintingStyle.fill,
    );

    _drawHexagon(
      canvas,
      center: Offset(w - 95 + 5 * math.cos(t * 0.7), 55 + 6 * math.sin(t * 0.6)),
      radius: 32,
      rotation: -t * 0.2,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.13 : 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    _drawHexagon(
      canvas,
      center: Offset(w - 22 + 8 * math.sin(t * 0.5 + 1.0), h - 22 + 6 * math.cos(t * 0.6)),
      radius: 22,
      rotation: t * 0.3,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.10 : 0.14)
        ..style = PaintingStyle.fill,
    );

    _drawHexagon(
      canvas,
      center: Offset(22 + 6 * math.sin(t * 0.4 + 0.5), h * 0.4 + 10 * math.cos(t * 0.5)),
      radius: 18,
      rotation: -t * 0.25,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.08 : 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    _drawTriangle(
      canvas,
      center: Offset(18 + 5 * math.cos(t * 0.6), h - 28 + 7 * math.sin(t * 0.5)),
      size: 48,
      rotation: 0.3 + t * 0.1,
      paint: Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(isDark ? 0.16 : 0.20),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: Offset(18, h - 28), radius: 48))
        ..style = PaintingStyle.fill,
    );

    final triScale1 = 1.0 + 0.08 * math.sin(t * 1.1);
    _drawTriangle(
      canvas,
      center: Offset(30 + 4 * math.sin(t * 0.8), 30 + 4 * math.cos(t * 0.7)),
      size: 22 * triScale1,
      rotation: -0.5 - t * 0.15,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.12 : 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    _drawTriangle(
      canvas,
      center: Offset(w - 25 + 7 * math.cos(t * 0.5), h - 70 + 8 * math.sin(t * 0.6)),
      size: 28,
      rotation: 1.2 + t * 0.2,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.10 : 0.13)
        ..style = PaintingStyle.fill,
    );

    _drawTriangle(
      canvas,
      center: Offset(w - 15 + 5 * math.sin(t * 0.9), h * 0.5 + 10 * math.cos(t * 0.4)),
      size: 20,
      rotation: t * 0.25,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.09 : 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    _drawDiamond(
      canvas,
      center: Offset(w * 0.25 + 8 * math.sin(t * 0.5), 20 + 6 * math.cos(t * 0.6)),
      size: 14,
      rotation: t * 0.2,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.10 : 0.14)
        ..style = PaintingStyle.fill,
    );
    _drawDiamond(
      canvas,
      center: Offset(w * 0.75 + 6 * math.cos(t * 0.7), h - 18 + 5 * math.sin(t * 0.5)),
      size: 12,
      rotation: -t * 0.3,
      paint: Paint()
        ..color = Colors.white.withOpacity(isDark ? 0.09 : 0.13)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    final dotPaint = Paint()..style = PaintingStyle.fill;
    final dotData = [
      [w - 130.0, 22.0, 2.5, 0.0],
      [w - 115.0, 38.0, 1.8, 0.5],
      [w - 148.0, 42.0, 1.5, 1.0],
      [55.0, h - 95, 2.5, 1.5],
      [38.0, h - 110, 1.8, 2.0],
      [70.0, h - 112, 1.5, 2.5],
      [w * 0.3, h * 0.15, 2.0, 3.0],
      [w * 0.7, h * 0.85, 1.8, 3.5],
    ];
    for (final d in dotData) {
      final pulse = 0.15 + 0.10 * math.sin(t + d[3]);
      dotPaint.color = Colors.white.withOpacity(isDark ? pulse : pulse + 0.05);
      final dx = d[0] + 4 * math.sin(t * 0.6 + d[3]);
      final dy = d[1] + 4 * math.cos(t * 0.5 + d[3]);
      canvas.drawCircle(Offset(dx, dy), d[2], dotPaint);
    }

    final linePaint = Paint()..strokeWidth = 1.0;

    linePaint.color = Colors.white.withOpacity(isDark ? 0.08 : 0.11);
    canvas.drawLine(
      Offset(w - 110 + 3 * math.sin(t * 0.4), 0),
      Offset(w - 60 + 3 * math.cos(t * 0.4), 80),
      linePaint,
    );
    canvas.drawLine(
      Offset(0, h - 80 + 3 * math.sin(t * 0.5)),
      Offset(80, h - 20 + 3 * math.cos(t * 0.5)),
      linePaint,
    );
    
    linePaint.color = Colors.white.withOpacity(isDark ? 0.06 : 0.09);
    canvas.drawLine(
      Offset(w * 0.2 + 4 * math.sin(t * 0.3), 0),
      Offset(w * 0.35 + 4 * math.cos(t * 0.3), h * 0.3),
      linePaint,
    );
  }

  void _drawGlow(Canvas canvas, Offset center, double radius, bool isDark) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(isDark ? 0.10 : 0.13),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center, radius, paint);
  }

  void _drawHexagon(Canvas canvas, {required Offset center, required double radius, required double rotation, required Paint paint}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (math.pi / 3) * i - math.pi / 6;
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawTriangle(Canvas canvas, {required Offset center, required double size, required double rotation, required Paint paint}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final path = Path()
      ..moveTo(0, -size)
      ..lineTo(size * 0.866, size * 0.5)
      ..lineTo(-size * 0.866, size * 0.5)
      ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawDiamond(Canvas canvas, {required Offset center, required double size, required double rotation, required Paint paint}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final path = Path()
      ..moveTo(0, -size)
      ..lineTo(size * 0.6, 0)
      ..lineTo(0, size)
      ..lineTo(-size * 0.6, 0)
      ..close();
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GeometricBgPainter old) =>
      old.progress != progress || old.isDark != isDark;
}