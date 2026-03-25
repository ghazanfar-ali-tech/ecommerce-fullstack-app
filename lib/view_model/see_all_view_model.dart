import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/models/filter_model.dart';
import 'package:ecommerceapp/models/see_all_model.dart';
import 'package:flutter/material.dart';



class SeeAllViewModel extends ChangeNotifier {

  List<SeeAllProductModel> _allProducts = [];

  String _searchQuery = '';
  SortOption _selectedSort = SortOption.newest;
  ViewMode _viewMode = ViewMode.grid;
  String? _selectedCategory;
  RangeValues _priceRange = const RangeValues(0, 100000);
  double _maxPrice = 100000;
  bool _isLoading = false;

  String get searchQuery => _searchQuery;
  SortOption get selectedSort => _selectedSort;
  ViewMode get viewMode => _viewMode;
  String? get selectedCategory => _selectedCategory;
  RangeValues get priceRange => _priceRange;
  double get maxPrice => _maxPrice;
  bool get isLoading => _isLoading;

  List<String> get categories {
    final cats = _allProducts.map((p) => p.categoryName).toSet().toList();
    cats.sort();
    return cats;
  }

  List<SeeAllProductModel> get filteredProducts {
    List<SeeAllProductModel> result = List.from(_allProducts);

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) {
        return p.productName.toLowerCase().contains(q) ||
            p.categoryName.toLowerCase().contains(q) ||
            p.productDescription.toLowerCase().contains(q);
      }).toList();
    }

    if (_selectedCategory != null) {
      result = result
          .where((p) => p.categoryName == _selectedCategory)
          .toList();
    }

    result = result.where((p) {
      return p.discountedPrice >= _priceRange.start &&
          p.discountedPrice <= _priceRange.end;
    }).toList();

    switch (_selectedSort) {
      case SortOption.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.priceLowToHigh:
        result.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
        break;
      case SortOption.priceHighToLow:
        result.sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
        break;
      case SortOption.nameAZ:
        result.sort(
            (a, b) => a.productName.compareTo(b.productName));
        break;
      case SortOption.nameZA:
        result.sort(
            (a, b) => b.productName.compareTo(a.productName));
        break;
      case SortOption.highestDiscount:
        result.sort(
            (a, b) => b.productDiscount.compareTo(a.productDiscount));
        break;
    }

    return result;
  }

  int get totalResults => filteredProducts.length;
  bool get hasActiveFilters =>
      _selectedCategory != null ||
      _priceRange.start > 0 ||
      _priceRange.end < _maxPrice;


  void loadProducts(List<SeeAllProductModel> products) {
    _allProducts = products;
    if (products.isNotEmpty) {
      final prices = products.map((p) => p.productPrice).toList();
      _maxPrice = prices.reduce((a, b) => a > b ? a : b);
      _priceRange = RangeValues(0, _maxPrice);
    }
    notifyListeners();
  }

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateSort(SortOption sort) {
    _selectedSort = sort;
    notifyListeners();
  }

  void toggleViewMode() {
    _viewMode =
        _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
    notifyListeners();
  }

  void selectCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void updatePriceRange(RangeValues values) {
    _priceRange = values;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = null;
    _priceRange = RangeValues(0, _maxPrice);
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchProductsFromFirestore() async {
  try {
    setLoading(true);

    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .get();

    final products = snapshot.docs.map((doc) {
      return SeeAllProductModel.fromMap(doc.data(), doc.id);
    }).toList();

    loadProducts(products);
  } catch (e) {
    debugPrint("Error fetching products: $e");
  } finally {
    setLoading(false);
  }
}
}