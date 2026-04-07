import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerceapp/models/hive_models/cart_model/cart_model.dart';
import 'package:ecommerceapp/view_model/auth_view_model.dart';
import 'package:ecommerceapp/view_model/product_review_view_model.dart';
import 'package:ecommerceapp/views/detail_screen/check_out_screeen.dart';
import 'package:ecommerceapp/views/detail_screen/detailed_review_screen.dart';
import 'package:ecommerceapp/views/detail_screen/product_reviews.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ecommerceapp/resources/components/appColor.dart';

class DetailScreen extends StatefulWidget {
  final List<String> productImageUrls;
  final String productName;
  final String categoryName;
  final int price;
  final int discount;
  final String description;
  final String productId;

  const DetailScreen({
    super.key,
    required this.productImageUrls,
    required this.productName,
    required this.categoryName,
    required this.price,
    required this.discount,
    required this.description,
    required this.productId,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 1.0);

  int getDiscountedPrice() {
    if (widget.discount <= 0) return widget.price;
    return widget.price - ((widget.price * widget.discount) ~/ 100);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreenImage(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, animation, __) {
          return FadeTransition(
            opacity: animation,
            child: _FullScreenImageViewer(
              imageUrls: widget.productImageUrls,
              initialIndex: initialIndex,
              heroTagPrefix: 'product_image_${widget.productId}',
              productId: widget.productId,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sizeList = ['S', 'M', 'L', 'XL'];
    final screenHeight = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background(context),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: screenHeight * 0.42,
                    child: Stack(
                      children: [
                        CarouselSlider.builder(
                          itemCount: widget.productImageUrls.isNotEmpty
                              ? widget.productImageUrls.length
                              : 1,
                          options: CarouselOptions(
                            height: screenHeight * 0.42,
                            viewportFraction: 1,
                            enlargeCenterPage: true,
                            enlargeStrategy: CenterPageEnlargeStrategy.scale,
                            padEnds: false,

                            enableInfiniteScroll: true,
                            pauseAutoPlayOnTouch: true,
                            onPageChanged: (index, _) =>
                                setState(() => _currentImageIndex = index),
                          ),
                          itemBuilder: (context, index, realIndex) {
                            final url = widget.productImageUrls.isNotEmpty
                                ? widget.productImageUrls[index]
                                : 'https://via.placeholder.com/400';
                            return GestureDetector(
                              onTap: () => _openFullScreenImage(context, index),
                              child: index == 0
                                  ? Hero(
                                      tag: 'product_image_${widget.productId}',
                                      child: Image.network(
                                        url,
                                        width: double.infinity,
                                        height: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey.shade200,
                                          child: const Icon(
                                            Icons.image,
                                            size: 60,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Image.network(
                                      url,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                            );
                          },
                        ),

                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.center,
                                  colors: [
                                    Colors.black.withOpacity(0.55),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.center,
                                  colors: [
                                    Colors.black.withOpacity(0.35),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          left: 16,
                          child: _overlayIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),

                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          right: 16,
                          child: Row(
                            children: [
                              _overlayIconButton(
                                icon: Icons.share_outlined,
                                onTap: () async {
                                  await SharePlus.instance.share(
                                    ShareParams(
                                      text:
                                          'Check this product:\nhttps://ecommerce-app-sand-eight.vercel.app/product/123',
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              _overlayIconButton(
                                icon: Icons.favorite_border_rounded,
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),

                        if (widget.productImageUrls.length > 1)
                          Positioned(
                            bottom: 14,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  widget.productImageUrls.length,
                                  (i) => AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 3,
                                    ),
                                    width: i == _currentImageIndex ? 20 : 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: i == _currentImageIndex
                                          ? AppColors.accent
                                          : Colors.white.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground(context),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.productName,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary(context),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${widget.categoryName} • ${DateTime.now().year}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (widget.discount > 0)
                                  Text(
                                    '\$${widget.price}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary(context),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ShaderMask(
                                  shaderCallback: (bounds) => AppColors
                                      .primaryGradient
                                      .createShader(bounds),
                                  child: Text(
                                    '\$${getDiscountedPrice()}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // IMPORTANT
                                    ),
                                  ),
                                ),
                                if (widget.discount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFB71C1C),
                                          Color(0xFFE53935),
                                          Color(0xFFB71C1C),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${widget.discount}% OFF',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.successLight,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Select Size',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: sizeList.map((size) {
                            final isSelected = size == 'L';
                            return Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? AppColors.primaryGradient
                                    : null,
                                color: isSelected
                                    ? null
                                    : AppColors.surfaceVariant(context),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: isSelected
                                    ? AppColors.primaryShadow
                                    : null,
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            height: 1.55,
                            fontSize: 14,
                          ),
                        ),

                        Consumer<ProductReviewViewModel>(
                          builder: (context, vm, _) {
                            final avgRating = vm.reviews.isEmpty
                                ? 0.0
                                : vm.reviews
                                          .map((r) => r.rating)
                                          .reduce((a, b) => a + b) /
                                      vm.reviews.length;

                            Map<String, int> ratingLabels = {
                              'Excellent': 0,
                              'Good': 0,
                              'Average': 0,
                              'Poor': 0,
                            };
                            for (var review in vm.reviews) {
                              if (review.rating == 5)
                                ratingLabels['Excellent'] =
                                    ratingLabels['Excellent']! + 1;
                              else if (review.rating == 4)
                                ratingLabels['Good'] =
                                    ratingLabels['Good']! + 1;
                              else if (review.rating == 3)
                                ratingLabels['Average'] =
                                    ratingLabels['Average']! + 1;
                              else
                                ratingLabels['Poor'] =
                                    ratingLabels['Poor']! + 1;
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductReviewsScreen(
                                      productId: widget.productId,
                                      productName: widget.productName,
                                      productImage:
                                          widget.productImageUrls.isNotEmpty
                                          ? widget.productImageUrls[0]
                                          : 'https://via.placeholder.com/260',
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.cardBackground(context),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.border(context),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadow(context),
                                      blurRadius: 15,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Customer Feedback',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary(
                                              context,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: AppColors.textSecondary(
                                            context,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              avgRating.toStringAsFixed(1),
                                              style: TextStyle(
                                                fontSize: 48,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary(
                                                  context,
                                                ),
                                                height: 1,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: List.generate(
                                                5,
                                                (i) => Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: i < avgRating.round()
                                                      ? Colors.amber
                                                      : Colors.grey.shade300,
                                                      shadows: Theme.of(context).brightness == Brightness.dark ? [
                Shadow(
                  color: const Color(0xFFFFD000).withOpacity(0.8),
                  blurRadius: 6,
                ),
                Shadow(
                  color: const Color(0xFFFFAA00).withOpacity(0.5),
                  blurRadius: 12,
                ),
              ]
            : [
                Shadow(
                  color: const Color(0xFFFFAA00).withOpacity(0.3),
                  blurRadius: 4,
                ),
              ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${vm.reviews.length} reviews',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: AppColors.textPrimary(
                                                  context,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 20),
                                        if (vm.reviews.isNotEmpty)
                                          Expanded(
                                            child: Column(
                                              children: [
                                                _buildRatingBar(
                                                  context,
                                                  'Excellent',
                                                  ratingLabels['Excellent']!,
                                                  vm.reviews.length,
                                                  AppColors.success,
                                                ),
                                                const SizedBox(height: 6),
                                                _buildRatingBar(
                                                  context,
                                                  'Good',
                                                  ratingLabels['Good']!,
                                                  vm.reviews.length,
                                                  AppColors.primary,
                                                ),
                                                const SizedBox(height: 6),
                                                _buildRatingBar(
                                                  context,
                                                  'Average',
                                                  ratingLabels['Average']!,
                                                  vm.reviews.length,
                                                  AppColors.warning,
                                                ),
                                                const SizedBox(height: 6),
                                                _buildRatingBar(
                                                  context,
                                                  'Poor',
                                                  ratingLabels['Poor']!,
                                                  vm.reviews.length,
                                                  AppColors.error,
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (vm.reviews.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceVariant(
                                            context,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              radius: 18,
                                              backgroundColor:
                                                  AppColors.primaryLight,
                                              backgroundImage: NetworkImage(
                                                'https://ui-avatars.com/api/?name=${vm.reviews.first.userName}&background=random',
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        vm
                                                            .reviews
                                                            .first
                                                            .userName,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              AppColors.textPrimary(
                                                                context,
                                                              ),
                                                        ),
                                                      ),
                                                     Row(
  children: List.generate(
    5,
    (i) => Container(
      decoration: BoxDecoration(
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? [
                BoxShadow(
                  color: const Color(0xFFFFD000).withOpacity(0.8),
                  blurRadius: 6,
                ),
                BoxShadow(
                  color: const Color(0xFFFFAA00).withOpacity(0.5),
                  blurRadius: 12,
                ),
              ]
            : [
                BoxShadow(
                  color: const Color(0xFFFFAA00).withOpacity(0.3),
                  blurRadius: 4,
                ),
              ],
      ),
      child: Icon(
        Icons.star,
        size: 12,
        color: i < vm.reviews.first.rating
            ? const Color(0xFFFFD000)
            : Colors.grey.shade100,
      ),
    ),
  ),
)
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    vm
                                                            .reviews
                                                            .first
                                                            .comment
                                                            .isNotEmpty
                                                        ? vm
                                                              .reviews
                                                              .first
                                                              .comment
                                                        : 'Great product! Highly recommended.',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          AppColors.textSecondary(
                                                            context,
                                                          ),
                                                      height: 1.4,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 42,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            final user = FirebaseAuth
                                                .instance
                                                .currentUser;
                                            if (user == null) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                    ),
                                                    'Please login to write a review',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            final userReview = vm.reviews
                                                .firstWhereOrNull(
                                                  (r) => r.userId == user.uid,
                                                );
                                            showDialog(
                                              context: context,
                                              builder: (_) => ReviewDialog(
                                                productId: widget.productId,
                                                existingReview: userReview,
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.transparent, // IMPORTANT
                                            shadowColor: Colors.transparent,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: const Text(
                                            'Write a review',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
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

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow(context),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => addToCart(context),
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return AppColors.primaryGradient.createShader(bounds);
                        },
                        child: Icon(
                          Icons.add_shopping_cart_rounded,
                          size: 20,
                          color: Colors.white, // IMPORTANT: keep this white
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add To Cart',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: GestureDetector(
                onTap: () {
                  final singleItem = CartModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    productName: widget.productName,
                    productCategory: widget.categoryName,
                    productPrice: getDiscountedPrice(),
                    productImage: widget.productImageUrls.isNotEmpty
                        ? widget.productImageUrls.first
                        : 'https://st5.depositphotos.com/90358332/74974/v/450/depositphotos_749740000-stock-illustration-photo-thumbnail-graphic-element-found.jpg',
                    quantity: 1,
                    stock: 10,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckOutScreen(singleItem: singleItem),
                    ),
                  );
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.primaryShadow,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_checkout_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Buy Now',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Colors.white,
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
    );
  }

  Widget _overlayIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  void addToCart(BuildContext context, {int stock = 10}) async {
    try {
      final cartBox = context.read<AuthViewModel>().getCartBox();
      int? existingIndex;
      for (var i = 0; i < cartBox.length; i++) {
        if (cartBox.getAt(i)!.productName == widget.productName) {
          existingIndex = i;
          break;
        }
      }
      if (existingIndex != null) {
        final existingItem = cartBox.getAt(existingIndex)!;
        if (existingItem.quantity < stock) {
          existingItem.quantity += 1;
          await existingItem.save();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added another item to cart')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum stock reached')),
          );
        }
      } else {
        final cartItem = CartModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          productName: widget.productName,
          productCategory: widget.categoryName,
          productPrice: widget.price,
          productImage: widget.productImageUrls.isNotEmpty
              ? widget.productImageUrls.first
              : 'https://via.placeholder.com/260',
          quantity: 1,
          stock: stock,
        );
        await cartBox.add(cartItem);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Added to cart')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Widget _buildRatingBar(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final percentage = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.border(context),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String heroTagPrefix;
  final String productId;

  const _FullScreenImageViewer({
    required this.imageUrls,
    required this.initialIndex,
    required this.heroTagPrefix,
    required this.productId,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer>
    with TickerProviderStateMixin {
  late int _currentIndex;
  late PageController _controller;
  late AnimationController _bgAnimController;
  late CarouselSliderController _carouselController;
  late AnimationController _slideAnimController;
  late Animation<double> _bgAnim;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _carouselController = CarouselSliderController();
    _controller = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 1.0,
    );

    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _bgAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bgAnimController, curve: Curves.easeOut),
    );
    _bgAnimController.forward();

    _slideAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _bgAnimController.dispose();
    _slideAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bgAnim,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(_bgAnim.value),
          body: child,
        );
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: CarouselSlider.builder(
              carouselController: _carouselController,
              itemCount: widget.imageUrls.length,
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1,
                enlargeCenterPage: true,
                enlargeStrategy: CenterPageEnlargeStrategy.scale,
                padEnds: false,
                enableInfiniteScroll: false,
                initialPage: widget.initialIndex,
                onPageChanged: (index, _) =>
                    setState(() => _currentIndex = index),
              ),
              itemBuilder: (context, index, realIndex) {
                return Hero(
                  tag: 'product_img_${widget.productId}_$index',
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          widget.imageUrls[index],
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.25),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.imageUrls.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 38),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.85), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.imageUrls.length > 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.imageUrls.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _currentIndex ? 20 : 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: i == _currentIndex
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (widget.imageUrls.length > 1)
                    SizedBox(
                      height: 64,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.imageUrls.length,
                        itemBuilder: (context, index) {
                          final isActive = index == _currentIndex;
                          return GestureDetector(
                            onTap: () {
                              _carouselController.animateToPage(index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 10),
                              width: isActive ? 70 : 58,
                              height: isActive ? 64 : 54,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.25),
                                  width: isActive ? 2 : 1,
                                ),
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.3),
                                          blurRadius: 8,
                                        ),
                                      ]
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Image.network(
                                  widget.imageUrls[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade800,
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
