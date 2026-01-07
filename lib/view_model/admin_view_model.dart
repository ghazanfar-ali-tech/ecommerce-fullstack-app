import 'dart:io';
import 'package:ecommerceapp/models/category_model.dart';
import 'package:ecommerceapp/models/product_model.dart';
import 'package:ecommerceapp/services/category_services.dart';
import 'package:ecommerceapp/services/cloudinary_services.dart';
import 'package:ecommerceapp/services/product_services.dart';
import 'package:flutter/material.dart';

class AdminViewModel extends ChangeNotifier {
  int _selectIndex = 0;
  String? _productCategoryName;
  String? _productCategoryImage;
  File? _selectedImage;

  File? get selectedImage => _selectedImage;
  String? get productCategoryName => _productCategoryName;
  String? get productCategoryImage => _productCategoryImage;
  int get selectIndex => _selectIndex;

  final List<File> _productImages = [];
  List<File> get productImages => _productImages;

  void addProductImage(File image) {
    _productImages.add(image);
    notifyListeners();
  }

  void removeProductImage(int index) {
    _productImages.removeAt(index);
    notifyListeners();
  }

  void setSelectedImage(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  void setProductCategoryMethod(String categoryName) {
    _productCategoryName = categoryName;

    final selected = _categories.firstWhere(
      (c) => c.categoryName == categoryName,
    );

    _productCategoryImage = selected.imageUrl;
    notifyListeners();
  }

  void updateScreen(BuildContext context, int index) {
    _selectIndex = index;
    notifyListeners();
  }

  final ProductServices _productServices = ProductServices();
  final CategoryService _categoryService = CategoryService();

  List<Category> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectCategory;
  List<ProductModel> _products = [];

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedCategory => _selectCategory;
  List<ProductModel> get products => _products;

  void loadProducts() {
    _productServices.getProducts().listen(
      (products) {
        _products = products;
        _updateCategoryCounts();
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Error loading products: $error';
        notifyListeners();
      },
    );
  }

  void _updateCategoryCounts() {
    for (var category in _categories) {
      final count = _products.where((p) => p.categoryName == category.categoryName).length;
      category.totalItems = count;
    }
  }

  void loadCategories() {
    _categoryService.getCategories().listen(
      (categories) {
        _categories = categories;
        
        loadProducts();
        
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Error loading categories: $error';
        notifyListeners();
      },
    );
  }

  void setSelectCategory(String? category) {
    _selectCategory = category;
    notifyListeners();
  }

  Future<bool> addProduct(
    String productName,
    int productDiscount,
    int productPrice,
    String productDescription,
    String productCategoryName,
    String productCategoryImage,
    List<File?> imageFile,
  ) async {
    if (productName.isEmpty) {
      _errorMessage = 'Product name cannot be empty';
      notifyListeners();
      return false;
    }

    if (_productImages.isEmpty) {
      _errorMessage = 'Please select at least one image';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<String> uploadedUrls = [];

      for (var img in _productImages) {
        final url = await CloudinaryService.uploadImage(img);
        if (url != null) {
          uploadedUrls.add(url);
        }
      }

      ProductModel product = ProductModel(
        id: '',
        productName: productName,
        productPrice: productPrice,
        productDescription: productDescription,
        productImageUrls: uploadedUrls,
        productDiscount: productDiscount,
        createdAt: DateTime.now(),
        categoryImage: productCategoryImage,
        categoryName: productCategoryName,
      );

      bool success = await _productServices.addProduct(product);

      if (!success) {
        _errorMessage = 'Failed to add product';
      } else {
        _errorMessage = null;
        _productImages.clear();
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addCategory(String categoryName, File? imageFile) async {
    if (categoryName.isEmpty) {
      _errorMessage = 'Category name cannot be empty';
      notifyListeners();
      return false;
    }

    if (imageFile == null) {
      _errorMessage = 'Please select an image';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? imageUrl = await CloudinaryService.uploadImage(imageFile);

      if (imageUrl == null) {
        _errorMessage = 'Failed to upload image';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      Category category = Category(
        id: '',
        categoryName: categoryName,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        totalItems: 0, // Initialize with 0
      );

      bool success = await _categoryService.addCategory(category);

      if (success) {
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to add category';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCategory(
    String categoryId,
    String categoryName,
    File? newImageFile,
    String currentImageUrl,
  ) async {
    if (categoryName.isEmpty) {
      _errorMessage = 'Category name cannot be empty';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String imageUrl = currentImageUrl;

      if (newImageFile != null) {
        String? uploadedUrl = await CloudinaryService.uploadImage(newImageFile);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        }
      }

      Map<String, dynamic> updates = {
        'categoryName': categoryName,
        'imageUrl': imageUrl,
      };

      bool success = await _categoryService.updateCategory(categoryId, updates);

      if (success) {
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to update category';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(String categoryId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      bool success = await _categoryService.deleteCategory(categoryId);

      if (success) {
        _errorMessage = null;
      } else {
        _errorMessage = 'Failed to delete category';
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}