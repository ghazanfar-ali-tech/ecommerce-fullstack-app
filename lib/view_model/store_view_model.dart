import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoreViewModel extends ChangeNotifier {
  final FirebaseFirestore _firebaseStore = FirebaseFirestore.instance;
 
  
 final bool _isLoading = false;

  List<Map<String, dynamic>> categoryWiseProducts = [];
  List<Map<String, dynamic>> categories = [];
  bool _isFetching = false;
  bool _isLoadingFromPrefs = true;

  

  final List<Map<String, dynamic>> _favList = [];

  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> get favList => _favList;
  bool get isLoadingFromPrefs => _isLoadingFromPrefs;
  bool get isFetching => _isFetching;

  late CollectionReference productRef;

  final double pinnedTop = 0;
  final double unPinnedTop = 320;

  late double tabTop;

  StoreViewModel() {
    tabTop = unPinnedTop;
    productRef = _firebaseStore.collection('products');
    _loadCategoriesFromPrefs();
    _loadFavoritesFromPrefs();
  }

  void verticalDragUpdate(DragUpdateDetails details) {
    tabTop += details.delta.dy;
    tabTop = tabTop.clamp(pinnedTop, unPinnedTop);
    notifyListeners();
  }

  void verticalDragEnd() {
    if (tabTop < unPinnedTop / 2) {
      tabTop = pinnedTop;
    } else {
      tabTop = unPinnedTop;
    }
    notifyListeners();
  }

  Future<void> _loadCategoriesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedCategories = prefs.getString('categories');
    if (cachedCategories != null) {
      categories = List<Map<String, dynamic>>.from(
        json.decode(cachedCategories),
      );
    }
    _isLoadingFromPrefs = false;
    notifyListeners();
  }

  Future<void> fetchAndCacheCategories() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      final snapshot = await _firebaseStore
          .collection('categories')
          .orderBy('createdAt', descending: true)
          .limit(4)
          .get();

      categories = snapshot.docs.map((doc) => doc.data()).toList();
      await _saveCategoriesToPrefs(categories);
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<void> _saveCategoriesToPrefs(
    List<Map<String, dynamic>> categories,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('categories', json.encode(categories));
  }

  final Map<String, List<Map<String, dynamic>>> _productsCache = {};
  final Map<String, bool> _loadingStates = {};

  bool isLoadingProducts(String category) => _loadingStates[category] ?? false;

  List<Map<String, dynamic>>? getCachedProducts(String category) {
    return _productsCache[category];
  }

  Future<List<Map<String, dynamic>>> fetchProductsByCategory(
    String categoryName,
  ) async {
    if (_productsCache.containsKey(categoryName)) {
      return _productsCache[categoryName]!;
    }
    try {
      final snapshot = await productRef
          .where('categoryName', isEqualTo: categoryName)
          .get();

      final products = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      _productsCache[categoryName] = products;

      return products;
    } catch (e) {
      debugPrint('Error fetching products for $categoryName: $e');
      return [];
    }
  }

  // FIXED: Check if product is in favorites by productName
  bool isFavValue(String productName) {
    return _favList.any((product) => product['productName'] == productName);
  }

  // FIXED: Toggle favorite with complete product object
  void toggleFavValue(Map<String, dynamic> product) {
    final productName = product['productName'];
    
    if (isFavValue(productName)) {
      _favList.removeWhere((p) => p['productName'] == productName);
    } else {
      _favList.add(product);
    }
    
    _saveFavoritesToPrefs();
    notifyListeners();
  }

  // Remove product from favorites
  void removeFromFavorites(String productName) {
    _favList.removeWhere((product) => product['productName'] == productName);
    _saveFavoritesToPrefs();
    notifyListeners();
  }

  // Add all favorites to cart
  void addAllToCart() {
    // Implement your cart logic here
    debugPrint('Adding ${_favList.length} items to cart');
  }

  // Load favorites from SharedPreferences
  Future<void> _loadFavoritesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedFavorites = prefs.getString('favorites');
      if (cachedFavorites != null) {
        _favList.clear();
        
        final decoded = List<Map<String, dynamic>>.from(json.decode(cachedFavorites));
        
        // Convert ISO strings back to DateTime if needed
        final restoredFavList = decoded.map((product) {
          final restored = Map<String, dynamic>.from(product);
          
          // Convert ISO string back to DateTime for timestamp fields
          restored.forEach((key, value) {
            if (value is String && 
                (key.toLowerCase().contains('date') || 
                 key.toLowerCase().contains('time') ||
                 key == 'createdAt' || 
                 key == 'updatedAt')) {
              try {
                restored[key] = DateTime.parse(value);
              } catch (e) {
                // If parsing fails, keep the original string
              }
            }
          });
          
          return restored;
        }).toList();
        
        _favList.addAll(restoredFavList);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  // Save favorites to SharedPreferences
  Future<void> _saveFavoritesToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert Timestamp objects to ISO strings before encoding
      final sanitizedFavList = _favList.map((product) {
        final sanitized = Map<String, dynamic>.from(product);
        
        // Convert all Timestamp fields to strings
        sanitized.forEach((key, value) {
          if (value is Timestamp) {
            sanitized[key] = value.toDate().toIso8601String();
          }
        });
        
        return sanitized;
      }).toList();
      
      prefs.setString('favorites', json.encode(sanitizedFavList));
    } catch (e) {
      debugPrint('Error saving favorites: $e');
    }
  }


}