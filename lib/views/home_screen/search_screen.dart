import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecommerceapp/resources/components/appColor.dart';
import 'package:ecommerceapp/view_model/home_view_model.dart';
import 'package:ecommerceapp/view_model/product_review_view_model.dart';
import 'package:ecommerceapp/views/detail_screen/detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late String _uid;
 String get _prefsKey => 'recent_searches_$_uid';

  List<String> _recentSearches = [];
  late final AnimationController _animCtrl;
  late final HomeViewModel _homeViewModel;

  @override
  void initState() {
    super.initState();
      _uid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    )..forward();
    _loadRecent();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeViewModel = context.read<HomeViewModel>();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    Future.microtask(() => _homeViewModel.onSearch(''));
    _controller.dispose();
    _focusNode.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList(_prefsKey) ?? [];
    });
  }

  Future<void> _saveRecent(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, list);
  }

  void _addToRecent(String query) {
    if (query.trim().isEmpty) return;
    final updated = [
      query.trim(),
      ..._recentSearches.where((s) => s != query.trim()),
    ].take(10).toList();
    setState(() => _recentSearches = updated);
    _saveRecent(updated);
  }

  void _removeRecent(String query) {
    final updated = _recentSearches.where((s) => s != query).toList();
    setState(() => _recentSearches = updated);
    _saveRecent(updated);
  }

  void _clearAll() {
    setState(() => _recentSearches = []);
    _saveRecent([]);
  }

  void _submitSearch(String query) {
    if (query.trim().isEmpty) return;
    HapticFeedback.lightImpact();
    _addToRecent(query.trim());
    context.read<HomeViewModel>().onSearch(query.trim());
    _focusNode.unfocus();
  }

  void _onChipTap(String query) {
    _controller.text = query;
    _controller.selection =
        TextSelection.collapsed(offset: query.length);
    context.read<HomeViewModel>().onSearch(query);
  }

  void _clearSearch() {
    _controller.clear();
    context.read<HomeViewModel>().onSearch('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) {},
      child: Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(context),
            Expanded(
              child: Consumer<HomeViewModel>(
                builder: (context, vm, _) {
                  final query = _controller.text.trim();
                  final hasQuery = query.isNotEmpty;
                  return hasQuery
                      ? _buildResults(context, vm)
                      : _buildRecentAndTrending(context);
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.cardBackground(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: AppColors.textPrimary(context)),
            ),
          ),
          const SizedBox(width: 10),
      
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.cardBackground(context),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppColors.primary.withOpacity(0.55)
                      : AppColors.border(context),
                  width: _focusNode.hasFocus ? 1.5 : 1,
                ),
                boxShadow: _focusNode.hasFocus
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.12),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 13),
                  Icon(Icons.search_rounded,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.search,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary(context),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search products…',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary(context),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (v) {
                        context.read<HomeViewModel>().onSearch(v);
                        setState(() {});
                      },
                      onSubmitted: _submitSearch,
                    ),
                  ),
                  if (_controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close_rounded,
                            size: 13, color: AppColors.info),
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

  Widget _buildRecentAndTrending(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
       
        if (_recentSearches.isNotEmpty) ...[
          _SectionHeader(
            title: 'Recent Searches',
            onClearAll: _clearAll,
          ),
          const SizedBox(height: 12),
          ..._recentSearches
              .asMap()
              .entries
              .map((e) => _RecentItem(
                    query: e.value,
                    delay: e.key * 40,
                    onTap: () => _onChipTap(e.value),
                    onRemove: () => _removeRecent(e.value),
                  )),
          const SizedBox(height: 24),
        ],

        _SectionHeader(title: 'Trending Now'),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _trendingTags
              .map((t) => _TrendingChip(
                    label: t,
                    onTap: () => _onChipTap(t),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildResults(BuildContext context, HomeViewModel vm) {
    final products = vm.filteredProducts;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded,
                size: 56, color: AppColors.info.withOpacity(0.5)),
            const SizedBox(height: 14),
            Text('No results found',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary(context),
                )),
            const SizedBox(height: 6),
            Text('Try a different keyword',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary(context),
                )),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.fromLTRB(16, 14, 16, 4),
          child: Text(
            '${products.length} result${products.length == 1 ? '' : 's'} for '
            '"${_controller.text.trim()}"',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
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
              final productPrice =
                  (p['productPrice'] ?? 0).toString();
              final productDescription =
                  p['productDescription'] ?? '';
              final productDiscount = p['productDiscount'] ?? 0;
              final categoryName =
                  p['categoryName'] ?? 'Uncategorized';
              final productImageUrls =
                  (p['productImageUrls'] as List<dynamic>?)
                          ?.map((u) => u.toString())
                          .toList() ??
                      [];
              final productImage = productImageUrls.isNotEmpty
                  ? productImageUrls[0]
                  : '';

              return _SearchProductCard(
                productName: productName,
                productPrice: productPrice,
                productImage: productImage,
                productDiscount: productDiscount,
                onTap: () {
                  _submitSearch(_controller.text);
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
                onAddToCart: () =>
                    vm.onAddToCart(productId),
                onFavorite: () =>
                    vm.onFavoriteTap(productId),
              );
            },
          ),
        ),
      ],
    );
  }

  static const List<String> _trendingTags = [
    'Sneakers',
    'Hoodies',
    'Watches',
    'Bags',
    'Sunglasses',
    'Jackets',
    'Dresses',
    'Perfumes',
  ];
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClearAll;

  const _SectionHeader({required this.title, this.onClearAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary(context),
            letterSpacing: -0.2,
          ),
        ),
        if (onClearAll != null)
          GestureDetector(
            onTap: onClearAll,
            child: Text(
              'Clear all',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _RecentItem extends StatefulWidget {
  final String query;
  final int delay;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RecentItem({
    required this.query,
    required this.delay,
    required this.onTap,
    required this.onRemove,
  });

  @override
  State<_RecentItem> createState() => _RecentItemState();
}

class _RecentItemState extends State<_RecentItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(-0.06, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 11, horizontal: 4),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground(context),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.border(context)),
                      ),
                      child: Icon(Icons.history_rounded,
                          size: 16, color: AppColors.info),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.query,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget.onRemove,
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.close_rounded,
                            size: 15, color: AppColors.info),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrendingChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TrendingChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: AppColors.primary.withOpacity(0.20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.trending_up_rounded,
                size: 13, color: AppColors.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchProductCard extends StatelessWidget {
  final String productName;
  final String productPrice;
  final String productImage;
  final int productDiscount;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onFavorite;

  const _SearchProductCard({
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.productDiscount,
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
                        top: Radius.circular(16)),
                    child: productImage.isNotEmpty
                        ? Image.network(
                            productImage,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _fallback(context),
                          )
                        : _fallback(context),
                  ),
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
                              color: Colors.white),
                        ),
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
                            )
                          ],
                        ),
                        child: const Icon(
                            Icons.favorite_border_rounded,
                            size: 15,
                            color: Colors.redAccent),
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
                    Text(productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                          height: 1.3,
                        )),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$$productPrice',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                           color: AppColors.accent,
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: const Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 16,
                                color: Colors.white),
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

  Widget _fallback(BuildContext context) => Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Icon(Icons.shopping_bag_outlined,
            size: 48,
            color: AppColors.primary.withOpacity(0.4)),
      );
}