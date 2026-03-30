import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/store_view_model.dart';
import 'package:ecommerceapp/views/home_screen/components/product_rating_starts.dart';
import 'package:ecommerceapp/views/home_screen/components/ribbon_clipper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductCard extends StatelessWidget {
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
  

  const ProductCard({
    super.key,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

      final discountedPrice = (double.parse(productPrice) -
      (double.parse(productPrice) * productDiscount / 100)).toStringAsFixed(0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground(context),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
           
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.35)
                  : AppColors.primary.withOpacity(0.10),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
         
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.20)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 6,
              spreadRadius: 0,
              offset: const Offset(0, 2),
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
               
               Hero(
  tag: 'product_image_$productId', 
  child: ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
    child: productImage.isNotEmpty
        ? Image.network(
            productImage,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imageFallback(context),
          )
        : _imageFallback(context),
  ),
),

                 
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.18),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),

                
                    Positioned(
                      top: 10, left: 10,
                      child: Stack(
                        children: [
                          ClipPath(
                            clipper: RibbonClipper(),
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 10, right: 14, top: 4, bottom: 4,
                              ),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFB71C1C),
                                    Color(0xFFE53935),
                                    Color(0xFFB71C1C),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              child: Text(
                                '$productDiscount% OFF',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                          ClipPath(
                            clipper: RibbonClipper(),
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 10, right: 14, top: 4, bottom: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withOpacity(0.20),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.08),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: const Text(
                                ' ',
                                style: TextStyle(fontSize: 9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

            
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: onFavorite,
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.12)
                              : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child:Consumer<StoreViewModel>(
  builder: (context, viewModel, child) {
    final isFavorite = viewModel.isFavValue(productName);

    return GestureDetector(
      onTap: () {
        viewModel.toggleFavValue({
          'id': productId,
          'productName': productName,
          'productPrice': productPrice,
          'discountedPrice': discountedPrice,
          'productDiscount': productDiscount,
          'productDescription': productDescription,
          'categoryName': categoryName,
          'productImageUrls': productImageUrls,
        });
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isFavorite
              ? Colors.red.withOpacity(0.1)
              : const Color(0xFF6C63FF).withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 15,
          color: isFavorite ? Colors.red : Colors.red,
        ),
      ),
    );
  },
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
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary(context),
                        height: 1.3,
                      ),
                    ),

             
                    ProductRatingStars(productId: productId),

                
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
  '\$$discountedPrice', 
  style: TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryText(context),
  ),
),
if (productDiscount > 0)
  Text(
    '\$$productPrice',  
    style: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary(context),
      decoration: TextDecoration.lineThrough,
      decorationColor: AppColors.textSecondary(context),
    ),
  )
                          ],
                        ),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primaryDark,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        size: 48,
        color: AppColors.primary.withOpacity(0.4),
      ),
    );
  }
}