import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/auth_view_model.dart';
import 'package:ecommerceapp/view_model/home_view_mode.dart';
import 'package:ecommerceapp/view_model/product_review_view_model.dart';
import 'package:ecommerceapp/views/detail_screen/detail_screen.dart';
import 'package:ecommerceapp/views/home_screen/cart_screen/cart_screen.dart';
import 'package:ecommerceapp/views/home_screen/curve_clipper.dart';
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
            // Dismiss keyboard when tapping outside search
            onTap: () => FocusScope.of(context).unfocus(),
            child: CustomScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                // ── Header ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _buildHeaderSection(context, viewModel),
                ),
                // ── Search Bar (sticky below header) ───────────────────
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SearchBarDelegate(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    isFocused: _isSearchFocused,
                     onChanged: (value) {
      viewModel.onSearch(value);
      setState(() => _isSearching = value.trim().isNotEmpty);  // ← add
    },
                     onClear: () {
      _searchController.clear();
      viewModel.onSearch('');
      setState(() => _isSearching = false);                    // ← add
    },
                  ),
                ),
                // ── Body content ────────────────────────────────────────
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

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeaderSection(BuildContext context, HomeViewModel viewModel) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.32,
      width: MediaQuery.of(context).size.width,
      child: ClipPath(
        clipper: CurveClipper(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.32,
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
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.primaryDark),
        Positioned(
          top: -80, right: -60,
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -100, right: -40,
          child: Container(
            width: 260, height: 260,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
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
                    Text(
                      "Good Morning",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                           viewModel.isUsernameLoaded
      ? (viewModel.username ?? "")
      : "Loading...",
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
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    const Icon(Icons.shopping_bag_outlined,
                                        color: Colors.white, size: 22),
                                    if (cartItemCount > 0)
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryButton,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '$cartItemCount',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 8,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
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
                    const SizedBox(height: 16),
                    Text(
                      'Shop by Category',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              _buildCategoriesList(viewModel),
            ],
          ),
        ),
      ],
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
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item =
                  categories[index].data() as Map<String, dynamic>;
              return buildCategoryItemFromFirestore(
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

  // ── Product Section ───────────────────────────────────────────────────────

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
          const SizedBox(height: 12),
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
        height: 160,
        viewportFraction: 1,
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

// ─── Sticky Search Bar Delegate ────────────────────────────────────────────────

class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBarDelegate({
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.onChanged,
    required this.onClear,
  });

  @override
  double get minExtent => 68;
  @override
  double get maxExtent => 68;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background(context),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFocused
                ? AppColors.primary.withOpacity(0.5)
                : AppColors.border(context),
            width: isFocused ? 1.5 : 1,
          ),
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
              color: isFocused ? AppColors.primary : AppColors.info,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary(context),
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            // Clear button when typing
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: onClear,
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 14, color: AppColors.info),
                ),
              ),
            // Filter button
            Container(
              width: 1,
              height: 20,
              color: AppColors.border(context),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 50,
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
                child: const Icon(Icons.tune_rounded,
                    color: Colors.white, size: 19),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SearchBarDelegate old) =>
      isFocused != old.isFocused ||
      controller.text != old.controller.text;
}

// ─── Product Card ──────────────────────────────────────────────────────────────

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
            // ── Image Section ──────────────────────────────────────────
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  // Image fills entire top portion
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

                  // Discount badge — top left
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

                  // Favorite — top right
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

            // ── Info Section ───────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Product name
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

                    // Price + Add to Cart
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
                              color: AppColors.primaryButton,
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