import 'package:ecommerceapp/models/filter_model.dart';
import 'package:ecommerceapp/models/product_model.dart';
import 'package:ecommerceapp/view_model/see_all_view_model.dart';
import 'package:ecommerceapp/views/home_screen/see_all_section/filter_bottom_sheet.dart';
import 'package:ecommerceapp/views/home_screen/see_all_section/product_grid_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class SeeAllScreen extends StatelessWidget {
  final String title;
  const SeeAllScreen({super.key, this.title = 'All Products'});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SeeAllViewModel()..fetchProductsFromFirestore(),
      child: _SeeAllView(title: title),
    );
  }
}

// ── Inner stateless view ───────────────────────────────────────────────────────
class _SeeAllView extends StatelessWidget {
  final String title;
  const _SeeAllView({required this.title});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SeeAllViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, vm),
            _buildSearchBar(context, vm),
            _buildFilterChips(context, vm),
            _buildResultsBar(context, vm),
            Expanded(child: _buildProductList(context, vm)),
          ],
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, SeeAllViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF1A1A2E), size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
                letterSpacing: -0.3,
              ),
            ),
          ),
          // View toggle
          GestureDetector(
            onTap: () => vm.toggleViewMode(),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey(vm.viewMode),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  vm.viewMode == ViewMode.grid
                      ? Icons.view_list_rounded
                      : Icons.grid_view_rounded,
                  color: const Color(0xFF6C63FF),
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search Bar ────────────────────────────────────────────────────────────
  Widget _buildSearchBar(BuildContext context, SeeAllViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: vm.updateSearch,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A1A2E),
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF6C63FF),
                    size: 22,
                  ),
                  suffixIcon: vm.searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () => vm.updateSearch(''),
                          child: Icon(Icons.close_rounded,
                              color: Colors.grey.shade400, size: 18),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Filter Button
          GestureDetector(
            onTap: () => _openFilterSheet(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: vm.hasActiveFilters
                    ? const Color(0xFF6C63FF)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    color: vm.hasActiveFilters
                        ? Colors.white
                        : const Color(0xFF6C63FF),
                    size: 22,
                  ),
                  if (vm.hasActiveFilters)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4757),
                          shape: BoxShape.circle,
                        ),
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

  // ── Active Filter Chips ───────────────────────────────────────────────────
  Widget _buildFilterChips(BuildContext context, SeeAllViewModel vm) {
    if (!vm.hasActiveFilters && vm.searchQuery.isEmpty) {
      return const SizedBox(height: 12);
    }

    return Container(
      height: 42,
      margin: const EdgeInsets.only(top: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (vm.selectedCategory != null)
            _chip(
              label: vm.selectedCategory!,
              icon: Icons.category_rounded,
              onRemove: () => vm.selectCategory(null),
            ),
          if (vm.priceRange.start > 0 || vm.priceRange.end < vm.maxPrice)
            _chip(
              label:
                  'Rs ${vm.priceRange.start.toStringAsFixed(0)} - Rs ${vm.priceRange.end.toStringAsFixed(0)}',
              icon: Icons.attach_money_rounded,
              onRemove: () =>
                  vm.updatePriceRange(RangeValues(0, vm.maxPrice)),
            ),
          if (vm.hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: GestureDetector(
                onTap: vm.clearFilters,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4757).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFFF4757).withOpacity(0.3)),
                  ),
                  child: const Center(
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF4757),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required VoidCallback onRemove,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF6C63FF)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 14, color: Color(0xFF6C63FF)),
          ),
        ],
      ),
    );
  }

  // ── Results Bar ───────────────────────────────────────────────────────────
  Widget _buildResultsBar(BuildContext context, SeeAllViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${vm.totalResults} ',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                TextSpan(
                  text: vm.totalResults == 1 ? 'product' : 'products',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            vm.selectedSort.label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Product List / Grid ───────────────────────────────────────────────────
  Widget _buildProductList(BuildContext context, SeeAllViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
      );
    }

    final products = vm.filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                vm.updateSearch('');
                vm.clearFilters();
              },
              child: const Text(
                'Clear all',
                style: TextStyle(color: Color(0xFF6C63FF)),
              ),
            ),
          ],
        ),
      );
    }

    if (vm.viewMode == ViewMode.grid) {
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: products.length,
        itemBuilder: (_, i) => ProductGridCard(product: products[i]),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
        itemCount: products.length,
        itemBuilder: (_, i) => ProductListCard(product: products[i]),
      );
    }
  }

  void _openFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<SeeAllViewModel>(),
        child: const FilterBottomSheet(),
      ),
    );
  }
}

