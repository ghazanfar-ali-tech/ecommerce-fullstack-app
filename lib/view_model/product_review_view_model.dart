import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/models/product_review_model.dart';
import 'package:flutter/material.dart';


class ProductReviewViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductReview> _reviews = [];
  List<ProductReview> get reviews => _reviews;

  bool isLoading = false;

  Future<void> addReview(ProductReview review) async {
    try {
      await _firestore
          .collection('products')
          .doc(review.productId)
          .collection('reviews')
          .add(review.toMap());

      await fetchReviews(review.productId);
    } catch (e) {
      debugPrint("Add review error: $e");
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
    } catch (e) {
      debugPrint("Fetch review error: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> editReview(ProductReview review) async {
    try {

      await _firestore
          .collection('products')
          .doc(review.productId)
          .collection('reviews')
          .doc(review.id)
          .update(review.toMap());

      await fetchReviews(review.productId);
    } catch (e) {
      debugPrint("Edit review error: $e");
    }
  }

  // Delete review
  Future<void> deleteReview(String productId, String reviewId) async {
    try {
      await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .doc(reviewId)
          .delete();

      await fetchReviews(productId);
    } catch (e) {
      debugPrint("Delete review error: $e");
    }
  }

}
