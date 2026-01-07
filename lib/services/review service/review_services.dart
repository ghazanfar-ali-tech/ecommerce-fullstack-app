import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/models/product_review_model.dart';

class ProductReviewService {
  final CollectionReference _reviewsCollection =
      FirebaseFirestore.instance.collection('productReviews');

  Future<String> addReview(ProductReview review) async {
    try {
      final existingReview = await getUserReviewForProduct(
        review.productId,
        review.userId,
      );

      if (existingReview != null) {
        throw Exception('You have already reviewed this product');
      }

      final docRef = await _reviewsCollection.add(review.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add review: $e');
    }
  }

  Future<void> updateReview(String reviewId, ProductReview updatedReview) async {
    try {
      await _reviewsCollection.doc(reviewId).update({
        'rating': updatedReview.rating,
        'comment': updatedReview.comment,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _reviewsCollection.doc(reviewId).delete();
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  // Modified to not require composite index
  Future<List<ProductReview>> getProductReviews(String productId) async {
    try {
      final querySnapshot = await _reviewsCollection
          .where('productId', isEqualTo: productId)
          .get();

      // Sort in memory instead of using orderBy (which requires composite index)
      final reviews = querySnapshot.docs
          .map((doc) => ProductReview.fromFirestore(doc))
          .toList();
      
      // Sort by createdAt descending
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return reviews;
    } catch (e) {
      print('Error fetching reviews: $e');
      throw Exception('Failed to fetch reviews: $e');
    }
  }

  Stream<List<ProductReview>> getProductReviewsStream(String productId) {
    return _reviewsCollection
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
          final reviews = snapshot.docs
              .map((doc) => ProductReview.fromFirestore(doc))
              .toList();
          
          // Sort in memory
          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  Future<ProductReview?> getUserReviewForProduct(String productId, String userId) async {
    try {
      final querySnapshot = await _reviewsCollection
          .where('productId', isEqualTo: productId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return ProductReview.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error getting user review: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getProductRatingStats(String productId) async {
    try {
      final querySnapshot = await _reviewsCollection
          .where('productId', isEqualTo: productId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'averageRating': 0.0,
          'totalReviews': 0,
          'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        };
      }

      List<int> ratings = querySnapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)['rating'] as int)
          .toList();

      double averageRating = ratings.reduce((a, b) => a + b) / ratings.length;

      Map<int, int> ratingDistribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (int rating in ratings) {
        ratingDistribution[rating] = (ratingDistribution[rating] ?? 0) + 1;
      }

      return {
        'averageRating': averageRating,
        'totalReviews': ratings.length,
        'ratingDistribution': ratingDistribution,
      };
    } catch (e) {
      print('Error getting rating stats: $e');
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
      };
    }
  }

  Future<List<ProductReview>> getUserReviews(String userId) async {
    try {
      final querySnapshot = await _reviewsCollection
          .where('userId', isEqualTo: userId)
          .get();

      final reviews = querySnapshot.docs
          .map((doc) => ProductReview.fromFirestore(doc))
          .toList();
      
      // Sort in memory
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return reviews;
    } catch (e) {
      throw Exception('Failed to fetch user reviews: $e');
    }
  }

  Future<List<ProductReview>> getPaginatedProductReviews({
    required String productId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      Query query = _reviewsCollection
          .where('productId', isEqualTo: productId)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();
      final reviews = querySnapshot.docs
          .map((doc) => ProductReview.fromFirestore(doc))
          .toList();
      
      // Sort in memory
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return reviews;
    } catch (e) {
      throw Exception('Failed to fetch paginated reviews: $e');
    }
  }
}