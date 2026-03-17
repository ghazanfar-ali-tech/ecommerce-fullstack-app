import 'package:ecommerceapp/models/brand_model.dart';
import 'package:ecommerceapp/view_model/admin_view_model.dart';
import 'package:ecommerceapp/view_model/store_view_model.dart';
import 'package:ecommerceapp/views/store_screen/shimmers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'card_widget.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  Widget _buildBrandRow(BrandModel brand) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    brand.imageUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
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
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.check_circle,
                            color: Colors.blue, size: 15),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${brand.introProductImages.length} Products',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (brand.introProductImages.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: brand.introProductImages.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    brand.introProductImages[i],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image),
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
  
    Widget buildProductCard(Map<String, dynamic> product) {
      final imageUrl = (product['productImageUrls'] as List).isNotEmpty
          ? product['productImageUrls'][0]
          : null;

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
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
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return buildImageShimmer(140);
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                child: Icon(Icons.image_outlined,
                                    size: 50, color: Colors.grey[400]),
                              ),
                            )
                          : Center(
                              child: Icon(Icons.image_outlined,
                                  size: 50, color: Colors.grey[400]),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<StoreViewModel>(
                      builder: (context, viewModel, child) {
                        final isFavorite =
                            viewModel.isFavValue(product['productName']);
                        return GestureDetector(
                          onTap: () => viewModel.toggleFavValue(product),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.red
                                  : Colors.grey[700],
                              size: 20,
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
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product['productName'] ?? 'No Name',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.3,
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
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              size: 18,
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
                    size: 60, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  "No products found for $category",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.68,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) =>
              buildProductCard(products[index]),
        ),
      );
    }

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
                  const Text(
                    'Brands',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...brands.map((b) => _buildBrandRow(b)),
                  const Divider(height: 32),
                  const Text(
                    'All Products',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }

          final cached = storeVM.getCachedProducts(categoryName);

          if (cached != null) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  brandsSection(),
                  buildProductGrid(cached, categoryName),
                ],
              ),
            );
          }

          return FutureBuilder<List<Map<String, dynamic>>>(
            future: storeVM.fetchProductsByCategory(categoryName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return buildProductGridShimmer();
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }
              final products = snapshot.data ?? [];
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    brandsSection(),
                    buildProductGrid(products, categoryName),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("Store",
              style: TextStyle(fontWeight: FontWeight.bold)),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Search in Store",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        prefixIcon:
                            Icon(Icons.search, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Featured Brands",
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        brandCard(
                          color: Colors.grey.shade300,
                          savgImage: "assets/niki.svg",
                          name: "Nike",
                          products: "50 Products",
                        ),
                        brandCard(
                          color: Colors.grey.shade300,
                          savgImage: "assets/adidas.svg",
                          name: "Adidas",
                          products: "20 Products",
                        ),
                        brandCard(
                          color: Colors.grey.shade300,
                          savgImage: "assets/apple_svg.svg",
                          name: "Apple",
                          products: "15 Products",
                        ),
                        brandCard(
                          color: Colors.grey.shade300,
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
                      child: Material(
                        elevation: 2,
                        color: Colors.white,
                        child: buildShimmerTab(),
                      ),
                    );
                  }

                  viewModel.fetchAndCacheCategories();

                  return Positioned(
                    top: viewModel.tabTop,
                    left: 0,
                    right: 0,
                    child: Material(
                      elevation: 2,
                      color: Colors.white,
                      child: buildShimmerTab(),
                    ),
                  );
                }

                final tabs = viewModel.categories
                    .map((cat) => Tab(text: cat['categoryName'], height: 50))
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
                    child: DefaultTabController(
                      length: tabs.length,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            elevation: 2,
                            color: Colors.white,
                            child: TabBar(
                              tabs: tabs,
                              labelColor: Colors.blue,
                              unselectedLabelColor: Colors.grey,
                              indicatorColor: Colors.blue,
                              indicatorWeight: 3,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TabBarView(children: tabViews),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}