import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/home_view_mode.dart';
import 'package:ecommerceapp/view_model/product_review_view_model.dart';
import 'package:ecommerceapp/views/detail_screen/detail_screen.dart';
import 'package:ecommerceapp/views/home_screen/components/ribbon_clipper.dart';
import 'package:ecommerceapp/views/home_screen/curve_clipper.dart';
import 'package:ecommerceapp/views/home_screen/components/category_header.dart';
import 'package:ecommerceapp/views/home_screen/search_screen.dart';
import 'package:ecommerceapp/views/home_screen/widgets/category_items_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
                              transitionDuration: const Duration(
                                milliseconds: 220,
                              ),
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
                                Icon(
                                  Icons.search_rounded,
                                  color: AppColors.info,
                                  size: 20,
                                ),
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
                                Container(
                                  width: 1,
                                  height: 20,
                                  color: AppColors.border(context),
                                ),

                                Container(
                                  width: 55,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primaryDark,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(14),
                                      bottomRight: Radius.circular(14),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.tune_rounded,
                                    color: Colors.white,
                                    size: 19,
                                  ),
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
    return AnimatedCategoryHeader(
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
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          final categories = snapshot.data!.docs;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = categories[index].data() as Map<String, dynamic>;
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
      top: 60,
      left: 24,
      right: 24,
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
        onPageChanged: (index, _) => viewModel.currentCarouselIndex = index,
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
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: AppColors.primary,
              ),
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
              Icon(Icons.search_off_rounded, size: 48, color: AppColors.info),
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
        final productImageUrls =
            (p['productImageUrls'] as List<dynamic>?)
                ?.map((u) => u.toString())
                .toList() ??
            [];
        final productImage = productImageUrls.isNotEmpty
            ? productImageUrls[0]
            : '';

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
            context.read<ProductReviewViewModel>().fetchReviews(productId);
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
                      child: Stack(
                        children: [
                          ClipPath(
                            clipper: RibbonClipper(),
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 14,
                                right: 14,
                                top: 4,
                                bottom: 4,
                              ),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 226, 71, 71),
                                    Color.fromARGB(255, 235, 116, 114),
                                    Color.fromARGB(255, 226, 71, 71),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              child: Text(
                                '$productDiscount% OFF',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Color(0x88000000),
                                      blurRadius: 3,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          ClipPath(
                            clipper: RibbonClipper(),
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 14,
                                right: 14,
                                top: 4,
                                bottom: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.22),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.10),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Text(
                                '$productDiscount% OFF',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: Colors.transparent,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
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

                    Consumer<ProductReviewViewModel>(
                      builder: (context, vm, child) {
                        final avgRating = vm.reviews.isEmpty
                            ? 0.0
                            : vm.reviews
                                      .map((r) => r.rating)
                                      .reduce((a, b) => a + b) /
                                  vm.reviews.length;
                        return Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.star,
                              size: 16,
                              color: i < avgRating.round()
                                  ? Colors.amber
                                  : Colors.grey.shade300,
                            ),
                          ),
                        );
                      },
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 48,
        color: AppColors.primary.withOpacity(0.4),
      ),
    );
  }
}
