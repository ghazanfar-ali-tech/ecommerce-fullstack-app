import 'package:cloud_firestore/cloud_firestore.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeaderSection(context, viewModel),
                _buildProductSection(context, viewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, HomeViewModel viewModel) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.38,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          ClipPath(
            clipper: CurveClipper(),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.34,
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
          _buildSearchBar(context, viewModel),
        ],
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
         Container(
        color: const Color.fromARGB(255, 21, 123, 219),
      ),

      Positioned(
        top: -80,
        right: -60,
        child: Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            color: const Color.fromARGB(92, 255, 255, 255),
            shape: BoxShape.circle,
          ),
        ),
      ),
      Positioned(
        bottom: -100,
        right: -40,
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            color: const Color.fromARGB(92, 255, 255, 255),
            shape: BoxShape.circle,
          ),
        ),
      ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.65),
              ],
            ),
          ),
        ),
        Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good Morning",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.6),
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          viewModel.isUsernameLoaded
                              ? "${viewModel.username}"
                              : "Loading...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black.withOpacity(0.6),
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                        ),
                Consumer<AuthViewModel>(
  builder: (context, authViewModel, child) {
    final cartItemCount = authViewModel.getCartItemCount();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => CartScreen()),
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: badges.Badge(
          key: ValueKey<int>(cartItemCount), 
          alignment: Alignment.topRight,
          isLabelVisible: cartItemCount > 0,
          label: Text(
            '$cartItemCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: Colors.white,
            size: 25,
          ),
        ),
      ),
    );
  },
)

                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Shop by Category',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.6),
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
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
      height: 90,
      child: StreamBuilder<QuerySnapshot>(
        stream: viewModel.getCategoriesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final categories = snapshot.data!.docs;

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final item = categories[index].data() as Map<String, dynamic>;
              final categoryName = item['categoryName'] ?? 'Unknown';
              final categoryImage = item['imageUrl'] ?? '';

              return buildCategoryItemFromFirestore(
                categoryImage,
                categoryName,
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
          colors: [
            Colors.blue.shade300,
            Colors.purple.shade300,
          ],
        ),
      ),
      child: Center(
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
          Text(
            'New Collection',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Up to 50% OFF',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  blurRadius: 10.0,
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, HomeViewModel viewModel) {
    return Positioned(
      top: 230,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(15),
          child: TextFormField(
            onChanged: viewModel.onSearch,
            decoration: InputDecoration(
              hintText: "Search products...",
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon: Icon(Icons.tune, color: Colors.grey[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductSection(BuildContext context, HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCarouselSlider(viewModel),
          SizedBox(height: 12),
          _buildCarouselIndicator(viewModel),
          _buildSectionHeader(),
          _buildProductGrid(viewModel),
        ],
      ),
    );
  }

Widget _buildCarouselSlider(HomeViewModel viewModel) {
  // List of carousel images
  final List<String> carouselImages = [
    "https://img.freepik.com/free-vector/gradient-shopping-discount-horizontal-sale-banner_23-2150321996.jpg?semt=ais_hybrid&w=740&q=80",
    "https://img.freepik.com/premium-vector/sport-collection-promotion-social-media-facebook-banner-template_252779-280.jpg?semt=ais_hybrid&w=740&q=80",
    "https://m.media-amazon.com/images/S/stores-image-uploads-na-prod/3/AmazonStores/ATVPDKIKX0DER/74883b9609f8c50ea9c18969a7a85267.w1900.h600.png",
    "https://img.freepik.com/free-psd/black-friday-super-sale-facebook-cover-banner-template_120329-5177.jpg?semt=ais_hybrid&w=740&q=80",
    "https://images.unsplash.com/photo-1512436991641-6745cdb1723f",
  ];

  return CarouselSlider(
    items: carouselImages.map((imageUrl) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey[300],
                child: Icon(Icons.image, size: 60, color: Colors.grey[400]),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList(),
    options: CarouselOptions(
      height: 180,
      viewportFraction: 1,
      enlargeCenterPage: true,
      enlargeStrategy: CenterPageEnlargeStrategy.scale,
      padEnds: false,
      autoPlay: true,
      enableInfiniteScroll: true,
      pauseAutoPlayOnTouch: true,
      onPageChanged: (index, reason) {
        viewModel.currentCarouselIndex = index;
      },
    ),
  );
}


  Widget _buildCarouselIndicator(HomeViewModel viewModel) {
    return Center(
      child: AnimatedSmoothIndicator(
        activeIndex: viewModel.currentCarouselIndex,
        count: 6,
        effect: ExpandingDotsEffect(
          dotHeight: 6,
          dotWidth: 6,
          spacing: 6,
          expansionFactor: 4,
          activeDotColor: Colors.blue,
          dotColor: Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Featured Products',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text('See All'),
        ),
      ],
    );
  }

Widget _buildProductGrid(HomeViewModel viewModel) {
  final products = viewModel.filteredProducts;

  if (products.isEmpty) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Text(
        'No products found',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    padding: const EdgeInsets.symmetric(horizontal: 0),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.72,
    ),
    itemCount: products.length,
    itemBuilder: (context, index) {
      final productData = products[index];
      final productId = productData['id'];
      final productName = productData['productName'] ?? 'N/A';
      final productPrice = (productData['productPrice'] ?? 0).toString();
      final productDescription = productData['productDescription'] ?? '';
      final productDiscount = productData['productDiscount'] ?? 0;
      final categoryName = productData['categoryName'] ?? 'Uncategorized';
      
      // Extract image URLs array
      final productImageUrls = (productData['productImageUrls'] as List<dynamic>?)
          ?.map((url) => url.toString())
          .toList() ?? [];
      
      // For grid display, use first image
      final productImage = productImageUrls.isNotEmpty 
          ? productImageUrls[0] 
          : '';

      return _buildProductCard(
        viewModel,
        productId,
        productDescription,
        productName,
        productPrice,
        productDiscount,
        productImage,
        productImageUrls, 
        categoryName
      );
    },
  );
}



  Widget _buildShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(
    HomeViewModel viewModel,
  String productId,
  String productDescription,
  String productName,
  String productPrice,
  int productDiscount,
  String productImage,
  List<String> productImageUrls,
  String categoryName,

  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      // onTap: () => viewModel.onProductTap(productId),
      onTap: (){
        context.read<ProductReviewViewModel>().fetchReviews(productId);
        Navigator.push(context, MaterialPageRoute(builder: (_)=> DetailScreen(
          productId: productId,
          productName: productName,
            price: int.parse(productPrice),
            discount:productDiscount,
            productImageUrls: productImageUrls, 
            description: productDescription,
            categoryName: categoryName,
        )));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.blue.shade50,
                      Colors.blue.shade100,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: productImage.isNotEmpty
                          ? Image.network(
                              productImage,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.image,
                                color: Colors.grey.shade400,
                                size: 60,
                              ),
                            )
                          : Icon(
                              Icons.shopping_bag_outlined,
                              size: 60,
                              color: Colors.blue.shade300,
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => viewModel.onFavoriteTap(productId),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.favorite_border,
                            size: 16,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),

                      Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        height: 20,
                        width: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          shape: BoxShape.rectangle,
                          color: Colors.amberAccent
                        ),
                        child: Center(child: Text("$productDiscount%",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w500), ))
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$productPrice',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => viewModel.onAddToCart(productId),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}