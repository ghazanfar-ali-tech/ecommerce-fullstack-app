import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/home_view_model.dart';
import 'package:ecommerceapp/view_model/product_review_view_model.dart';
import 'package:ecommerceapp/views/detail_screen/detail_screen.dart';
import 'package:ecommerceapp/views/home_screen/components/product_card.dart';
import 'package:ecommerceapp/views/home_screen/curve_clipper.dart';
import 'package:ecommerceapp/views/home_screen/components/category_header.dart';
import 'package:ecommerceapp/views/home_screen/search_screen.dart';
import 'package:ecommerceapp/views/home_screen/see_all_section/see_all_screen.dart';
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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchFocused = false;
  bool _isSearching = false;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().initialize();
    });
    
    _searchFocusNode.addListener(() {
      setState(() => _isSearchFocused = _searchFocusNode.hasFocus);
    });

     _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  _controller.forward();
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
              GestureDetector(
                onTap: (){
                  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SeeAllScreen(title: 'All Products'),
      
      ),
    );
                },
                child: Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: AppColors.textPrimary(context),
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

  final productImageUrls =
      (p['productImageUrls'] as List<dynamic>?)
          ?.map((u) => u.toString())
          .toList() ?? [];

  final animation = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (index / products.length), // 👈 stagger start
        1.0,
        curve: Curves.easeOut,
      ),
    ),
  );

  return AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
      return Opacity(
        opacity: animation.value,
        child: Transform.translate(
          offset: Offset(0, 50 * (1 - animation.value)),
          child: child,
        ),
      );
    },
    child: ProductCard(
      productId: p['id'],
      productName: p['productName'] ?? 'N/A',
      productPrice: (p['productPrice'] ?? 0).toString(),
      productDescription: p['productDescription'] ?? '',
      productDiscount: p['productDiscount'] ?? 0,
      productImage: productImageUrls.isNotEmpty ? productImageUrls[0] : '',
      productImageUrls: productImageUrls,
      categoryName: p['categoryName'] ?? 'Uncategorized',
      onTap: () {
        context.read<ProductReviewViewModel>().fetchReviews(p['id']);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(
              productId: p['id'],
              productName: p['productName'] ?? 'N/A',
              price: double.parse((p['productPrice'] ?? 0).toString()).toInt(),
              discount: p['productDiscount'] ?? 0,
              productImageUrls: productImageUrls,
              description: p['productDescription'] ?? '',
              categoryName: p['categoryName'] ?? 'Uncategorized',
            ),
          ),
        );
      },
      onAddToCart: () => viewModel.onAddToCart(p['id']),
      onFavorite: () => viewModel.onFavoriteTap(p['id']),
    ),
  );
},
);
  }
}
