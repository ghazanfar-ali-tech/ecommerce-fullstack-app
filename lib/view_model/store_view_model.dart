import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/models/hive_models/cart_model/cart_model.dart';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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

  String? _currentUid;

  StoreViewModel() {
    tabTop = unPinnedTop;
    productRef = _firebaseStore.collection('products');
    _loadCategoriesFromPrefs();
  }


Future<void> initForUser(String uid) async {
  _currentUid = uid;
  _favList.clear();
  await _loadFavoritesFromPrefs();
  notifyListeners();
}

Future<void> clearFavorites() async {
  _favList.clear();
  _currentUid = null;
  notifyListeners();
}

String get _favKey => 'favorites_${_currentUid ?? 'guest'}';

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

     categories = snapshot.docs.map((doc) {
  final data = doc.data();
  data['id'] = doc.id;
  return data;
}).toList();
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


  bool isFavValue(String productName) {
    return _favList.any((product) => product['productName'] == productName);
  }

  void toggleFavValue(Map<String, dynamic> product) async{
    final productName = product['productName'];
    
    if (isFavValue(productName)) {
      _favList.removeWhere((p) => p['productName'] == productName);
    } else {
      _favList.add(product);
    }
    
  await  _saveFavoritesToPrefs();
    notifyListeners();
  }

  void removeFromFavorites(String productName)async {
    _favList.removeWhere((product) => product['productName'] == productName);
  await   _saveFavoritesToPrefs();
    notifyListeners();
  }

 Future<void> addAllToCart(Box<CartModel> cartBox) async {
  for (final product in _favList) {
    final productName = product['productName'] ?? '';
    
   
    final exists = cartBox.values.any((item) => item.productName == productName);
    if (exists) continue;

    final cartItem = CartModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productName: productName,
      productCategory: product['categoryName'] ?? '',
      productPrice: (product['productPrice'] is double)
          ? (product['productPrice'] as double).toInt()
          : (product['productPrice'] ?? 0) as int,
      productImage: (product['productImageUrls'] as List?)?.isNotEmpty == true
          ? product['productImageUrls'][0]
          : '',
      quantity: 1,
      stock: 10,
    );

    await cartBox.add(cartItem);
  }
}


Future<void> addSingleToCart(Map<String, dynamic> product, Box<CartModel> cartBox) async {
  final productName = product['productName'] ?? '';
  

  final exists = cartBox.values.any((item) => item.productName == productName);
  if (exists) return;

  final cartItem = CartModel(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    productName: productName,
    productCategory: product['categoryName'] ?? '',
   productPrice: int.tryParse(product['productPrice'].toString()) ?? 0,
    productImage: (product['productImageUrls'] as List?)?.isNotEmpty == true
        ? product['productImageUrls'][0]
        : '',
    quantity: 1,
    stock: 10,
  );

  await cartBox.add(cartItem);
}

 
  Future<void> _loadFavoritesFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
       print('🔍 Loading favorites with key: $_favKey');
      final cachedFavorites = prefs.getString(_favKey); 
       print('🔍 Found data: ${cachedFavorites != null ? "YES" : "NO"}');
      if (cachedFavorites != null) {
        _favList.clear();
        
        final decoded = List<Map<String, dynamic>>.from(json.decode(cachedFavorites));
        
    
        final restoredFavList = decoded.map((product) {
          final restored = Map<String, dynamic>.from(product);
          
          restored.forEach((key, value) {
            if (value is String && 
                (key.toLowerCase().contains('date') || 
                 key.toLowerCase().contains('time') ||
                 key == 'createdAt' || 
                 key == 'updatedAt')) {
              try {
                restored[key] = DateTime.parse(value);
              } catch (e) {
                // // debugging line has removed from this code
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

 Future<void> _saveFavoritesToPrefs() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    final sanitizedFavList = _favList.map((product) {
      return product.map((key, value) {
        if (value is DateTime) {
          return MapEntry(key, value.toIso8601String());
        }
        if (value is Timestamp) {
          return MapEntry(key, value.toDate().toIso8601String());
        }
   
        if (value is List) {
          return MapEntry(key, value.map((v) {
            if (v is DateTime) return v.toIso8601String();
            if (v is Timestamp) return v.toDate().toIso8601String();
            return v;
          }).toList());
        }
        return MapEntry(key, value);
      });
    }).toList();

    print('💾 Sanitized list: $sanitizedFavList');
    await prefs.setString(_favKey, json.encode(sanitizedFavList));
    print('💾 Saved successfully!');
  } catch (e) {
    debugPrint('Error saving favorites: $e');
  }
}


}