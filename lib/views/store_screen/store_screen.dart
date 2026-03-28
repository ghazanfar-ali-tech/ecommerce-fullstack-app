import 'package:ecommerceapp/models/brand_model.dart';
import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/admin_view_model.dart';
import 'package:ecommerceapp/view_model/store_view_model.dart';
import 'package:ecommerceapp/views/store_screen/shimmers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'card_widget.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});


  Widget _buildBrandRow(BrandModel brand, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    brand.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textHint(context),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          brand.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded,
                            color: AppColors.primary, size: 15),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${brand.introProductImages.length} Products',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (brand.introProductImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: brand.introProductImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    brand.introProductImages[i],
                    width: 88,
                    height: 88,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textHint(context),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    Widget buildProductCard(Map<String, dynamic> product, int index) {
      final imageUrl = (product['productImageUrls'] as List).isNotEmpty
          ? product['productImageUrls'][0]
          : null;

      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 300 + index * 80),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.cardBackground(context),
            border: Border.all(color: AppColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow(context),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 140,
                      width: double.infinity,
                      color: AppColors.surfaceVariant(context),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return buildImageShimmer(140);
                              },
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(Icons.image_outlined,
                                    size: 48,
                                    color: AppColors.textHint(context)),
                              ),
                            )
                          : Center(
                              child: Icon(Icons.image_outlined,
                                  size: 48,
                                  color: AppColors.textHint(context)),
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Consumer<StoreViewModel>(
                        builder: (context, viewModel, _) {
                          final isFav =
                              viewModel.isFavValue(product['productName']);
                          return GestureDetector(
                            onTap: () => viewModel.toggleFavValue(product),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: isFav
                                    ? AppColors.error.withOpacity(0.12)
                                    : AppColors.cardBackground(context),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadow(context),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isFav
                                    ? AppColors.error
                                    : AppColors.textSecondary(context),
                                size: 18,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          product['productName'] ?? 'No Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            height: 1.35,
                            color: AppColors.textPrimary(context),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "\$${product['productPrice'] ?? '0'}",
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                gradient: AppColors.accentGradient,
                                borderRadius: BorderRadius.circular(9),
                                boxShadow: AppColors.accentShadow,
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 16,
                                color: Colors.white,
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
        ),
      );
    }

    Widget buildProductGrid(
        List<Map<String, dynamic>> products, String category) {
      if (products.isEmpty) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 58, color: AppColors.textHint(context)),
                const SizedBox(height: 12),
                Text(
                  "No products found for $category",
                  style: TextStyle(
                      color: AppColors.textSecondary(context), fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }

      final rowCount = (products.length / 2).ceil();
      final gridHeight = rowCount * 220.0 + 32;

      return SizedBox(
        height: gridHeight,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.68,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) =>
              buildProductCard(products[index], index),
        ),
      );
    }

    Widget sectionHeader(String title) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ],
          ),
        );


    Widget buildTabContent(String categoryName, String categoryId) {
      return Consumer2<AdminViewModel, StoreViewModel>(
        builder: (context, adminVM, storeVM, child) {
          if (!adminVM.brandsByCategory.containsKey(categoryId)) {
            adminVM.loadBrandsForCategory(categoryId);
          }

          final brands = adminVM.brandsByCategory[categoryId] ?? [];

          Widget brandsSection() {
            if (brands.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionHeader('Brands'),
                  ...brands.map((b) => _buildBrandRow(b, context)),
                  Divider(height: 32, color: AppColors.divider(context)),
                  sectionHeader('All Products'),
                ],
              ),
            );
          }

          final cached = storeVM.getCachedProducts(categoryName);

          if (cached != null) {
            return ColoredBox(
              color: AppColors.background(context),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    brandsSection(),
                    buildProductGrid(cached, categoryName),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: storeVM.fetchProductsByCategory(categoryName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ColoredBox(
                  color: AppColors.background(context),
                  child: buildProductGridShimmer(context),
                );
              }
              if (snapshot.hasError) {
                return ColoredBox(
                  color: AppColors.background(context),
                  child: Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                );
              }
              final products = snapshot.data ?? [];
              return ColoredBox(
                color: AppColors.background(context),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      brandsSection(),
                      buildProductGrid(products, categoryName),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    }

    Widget buildShimmerTab() {
      return Shimmer.fromColors(
        baseColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A2540)
            : Colors.grey[300]!,
        highlightColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2E3D5C)
            : Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Row(
            children: List.generate(4, (_) {
              return Container(
                margin: const EdgeInsets.only(right: 10),
                width: 72,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
          ),
        ),
      );
    }


    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          "Store",
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: AppColors.background(context),
        foregroundColor: AppColors.textPrimary(context),
      ),
      body: Stack(
        children: [
       
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: AppColors.background(context),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
             
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Search in Store",
                      hintStyle:
                          TextStyle(color: AppColors.textHint(context)),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: AppColors.textSecondary(context)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceVariant(context),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 24),

                  sectionHeader("Featured Brands"),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      brandCard(
                        context: context,
                        color: AppColors.iconAdaptive(context),
                        savgImage: "assets/niki.svg",
                        name: "Nike",
                        products: "50 Products",
                      ),
                      brandCard(
                        context: context,
                        color: AppColors.iconAdaptive(context),
                        savgImage: "assets/adidas.svg",
                        name: "Adidas",
                        products: "20 Products",
                      ),
                      brandCard(
                        context: context,
                        color: AppColors.iconAdaptive(context),
                        savgImage: "assets/apple_svg.svg",
                        name: "Apple",
                        products: "15 Products",
                      ),
                      brandCard(
                        context: context,
                        color: AppColors.iconAdaptive(context),
                        savgImage: "assets/samsung.svg",
                        name: "Samsung",
                        products: "10 Products",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),


          Consumer<StoreViewModel>(
            builder: (context, viewModel, child) {

              if (viewModel.categories.isEmpty) {
                if (viewModel.isLoadingFromPrefs) {
                  return Positioned(
                    top: viewModel.tabTop,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: AppColors.cardBackground(context),
                      child: buildShimmerTab(),
                    ),
                  );
                }

     
                viewModel.fetchAndCacheCategories();

                return Positioned(
                  top: viewModel.tabTop,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    color: AppColors.cardBackground(context),
                    child: buildShimmerTab(),
                  ),
                );
              }

              final tabs = viewModel.categories
                  .map((cat) => Tab(text: cat['categoryName']))
                  .toList();

              final tabViews = viewModel.categories
                  .map((cat) => buildTabContent(
                        cat['categoryName'],
                        cat['id'],
                      ))
                  .toList();

              return Positioned(
                top: viewModel.tabTop,
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onVerticalDragUpdate: viewModel.verticalDragUpdate,
                  onVerticalDragEnd: (_) => viewModel.verticalDragEnd(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground(context),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow(context),
                          blurRadius: 8,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: DefaultTabController(
                      length: tabs.length,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            elevation: 0,
                            color: AppColors.cardBackground(context),
                            child: SizedBox(
                              height: 44,
                              child: TabBar(
                                tabs: tabs,
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                indicator: UnderlineTabIndicator(
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  insets: const EdgeInsets.symmetric(
                                      horizontal: 6),
                                ),
                                indicatorSize: TabBarIndicatorSize.label,
                                labelColor: AppColors.primary,
                                unselectedLabelColor:
                                    AppColors.textSecondary(context),
                                labelStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  letterSpacing: 0.1,
                                ),
                                unselectedLabelStyle: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13,
                                ),
                                labelPadding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                dividerColor: AppColors.border(context),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ColoredBox(
                              color: AppColors.background(context),
                              child: TabBarView(children: tabViews),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}