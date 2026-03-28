import 'package:ecommerceapp/models/see_all_model.dart';
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/store_view_model.dart';
import 'package:ecommerceapp/views/home_screen/components/product_rating_starts.dart';
import 'package:ecommerceapp/views/home_screen/components/ribbon_clipper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductGridCard extends StatelessWidget {
  final SeeAllProductModel product;
  final VoidCallback? onTap;
  const ProductGridCard({super.key, required this.product, this.onTap});


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    product.productImageUrls.isNotEmpty
                        ? Image.network(
                            product.productImageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder(),
                          )
                        : _placeholder(),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0x22000000), Colors.transparent],
                          ),
                        ),
                      ),
                    ),

                    if (product.productDiscount > 0)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Stack(
                          children: [
                            ClipPath(
                              clipper: RibbonClipper(),
                              child: Container(
                                padding: const EdgeInsets.only(
                                  left: 10,
                                  right: 14,
                                  top: 4,
                                  bottom: 4,
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
                                  '${product.productDiscount}% OFF',
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
                                  left: 10,
                                  right: 14,
                                  top: 4,
                                  bottom: 4,
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
                      top: 8,
                      right: 8,
                      child: Consumer<StoreViewModel>(
                        builder: (context, viewModel, child) {
                          final isFavorite = viewModel.isFavValue(
                            product.productName,
                          );

                          return GestureDetector(
                            onTap: () {
                              viewModel.toggleFavValue({
                                'id': product.id,
                                'productName': product.productName,
                                'productPrice': product.productPrice,
                                'discountedPrice': product.discountedPrice,
                                'productDiscount': product.productDiscount,
                                'productDescription':
                                    product.productDescription,
                                'categoryName': product.categoryName,
                                'productImageUrls': product.productImageUrls,
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
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 15,
                                color: isFavorite ? Colors.red : Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.categoryName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.productName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText(context),
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    ProductRatingStars(productId: product.id),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (product.productDiscount > 0)
                               Text(
                                '\$${product.discountedPrice.toStringAsFixed(0)}',
                                style:  TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryText(context),
                                  height: 1.1,
                                ),
                              ),
                                Text(
                                  '\$${product.productPrice.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade400,
                                    decoration: TextDecoration.lineThrough,
                                    height: 1,
                                  ),
                                ),
                             
                            ],
                          ),
                        ),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            size: 17,
                            color: Colors.white,
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
      ),
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFFF4F4F8),
    child: const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFFCCCCD8),
        size: 28,
      ),
    ),
  );
}


class ProductListCard extends StatelessWidget {
  final SeeAllProductModel product;
  const ProductListCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: product.productImageUrls.isNotEmpty
                        ? Image.network(
                            product.productImageUrls.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFF0F0F5),
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFF0F0F5),
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                  if (product.productDiscount > 0)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Stack(
                        children: [
                          ClipPath(
                            clipper: RibbonClipper(),
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 14,
                                top: 4,
                                bottom: 4,
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
                                '${product.productDiscount}% OFF',
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
                                left: 10,
                                right: 14,
                                top: 4,
                                bottom: 4,
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
                ],
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.categoryName,
                    style: TextStyle(
                     fontSize: 9,
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.productName,
                    style:  TextStyle(
                     fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText(context),
                       
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.productDescription,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                      height: 1.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  ProductRatingStars(productId: product.id),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '\$ ${product.discountedPrice.toStringAsFixed(0)}',
                        style:  TextStyle(
                          fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryText(context),
                                  height: 1.1,
                        ),
                      ),
                      if (product.productDiscount > 0) ...[
                        const SizedBox(width: 6),
                        Text(
                          '\$ ${product.productPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                      const Spacer(),
                      Consumer<StoreViewModel>(
                        builder: (context, viewModel, child) {
                          final isFavorite = viewModel.isFavValue(
                            product.productName,
                          );

                          return GestureDetector(
                            onTap: () {
                              viewModel.toggleFavValue({
                                'id': product.id,
                                'productName': product.productName,
                                'productPrice': product.productPrice,
                                'discountedPrice': product.discountedPrice,
                                'productDiscount': product.productDiscount,
                                'productDescription':
                                    product.productDescription,
                                'categoryName': product.categoryName,
                                'productImageUrls': product.productImageUrls,
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
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 15,
                                color: isFavorite
                                    ? Colors.red
                                    : const Color(0xFF6C63FF),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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
