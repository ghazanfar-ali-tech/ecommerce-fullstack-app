import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/models/product_model.dart';

class ProductServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'products';

  CollectionReference get _productCollection =>
      _firestore.collection(collectionName);

  Future<bool> addProduct(ProductModel product) async {
    try {
      await _productCollection.add(product.toMap());
      return true;
    } catch (e) {
      print('Error adding product: $e');
      return false;
    }
  }

  Stream<List<ProductModel>> getProducts() {
    return _productCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<ProductModel?> getProductById(String productId) async {
    try {
      DocumentSnapshot doc = await _productCollection.doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      return null;
    }
  }

  Future<bool> updateCategory(String productId, Map<String, dynamic> updates) async {
    try {
      await _productCollection.doc(productId).update(updates);
      return true;
    } catch (e) {
      print('Error updating product: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _productCollection.doc(productId).delete();
      return true;
    } catch (e) {
      print('Error deleting product: $e');
      return false;
    }
  }

  Future<int> getProductCount() async {
    try {
      QuerySnapshot snapshot = await _productCollection.get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting category count: $e');
      return 0;
    }
  }
}