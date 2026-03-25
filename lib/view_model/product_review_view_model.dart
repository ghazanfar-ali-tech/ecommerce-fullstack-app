import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/models/product_review_model.dart';
import 'package:flutter/material.dart';

class ProductReviewViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductReview> _reviews = [];
  List<ProductReview> get reviews => _reviews;


  final Map<String, List<ProductReview>> _reviewsCache = {};

  bool isLoading = false;

  List<ProductReview> getReviewsForProduct(String productId) {
    return _reviewsCache[productId] ?? [];
  }

  Future<void> fetchReviewsForProduct(String productId) async {
    if (_reviewsCache.containsKey(productId)) return;

    try {
      final snapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      _reviewsCache[productId] =
          snapshot.docs.map((e) => ProductReview.fromFirestore(e)).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("Fetch reviews for product error: $e");
      _reviewsCache[productId] = [];
    }
  }

  Future<void> fetchReviews(String productId) async {
    try {
      isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      _reviews =
          snapshot.docs.map((e) => ProductReview.fromFirestore(e)).toList();

    
      _reviewsCache[productId] = _reviews;
    } catch (e) {
      debugPrint("Fetch review error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> addReview(ProductReview review) async {
    try {
      await _firestore
          .collection('products')
          .doc(review.productId)
          .collection('reviews')
          .add(review.toMap());

      
      _reviewsCache.remove(review.productId);

      await fetchReviews(review.productId);
    } catch (e) {
      debugPrint("Add review error: $e");
    }
  }

  Future<void> editReview(ProductReview review) async {
    try {
      await _firestore
          .collection('products')
          .doc(review.productId)
          .collection('reviews')
          .doc(review.id)
          .update(review.toMap());

  
      _reviewsCache.remove(review.productId);

      await fetchReviews(review.productId);
    } catch (e) {
      debugPrint("Edit review error: $e");
    }
  }

  Future<void> deleteReview(String productId, String reviewId) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .doc(reviewId)
          .delete();

      _reviewsCache.remove(productId);

      await fetchReviews(productId);
    } catch (e) {
      debugPrint("Delete review error: $e");
    }
  }
}