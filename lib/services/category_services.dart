import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'categories';

  // Get reference to categories collection
  CollectionReference get _categoriesCollection =>
      _firestore.collection(collectionName);

  // Create a new category
  Future<bool> addCategory(Category category) async {
    try {
      await _categoriesCollection.add(category.toMap());
      return true;
    } catch (e) {
      print('Error adding category: $e');
      return false;
    }
  }

  // Read all categories
  Stream<List<Category>> getCategories() {
    return _categoriesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Category.fromFirestore(doc))
          .toList();
    });
  }

  // Read a single category by ID
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      DocumentSnapshot doc = await _categoriesCollection.doc(categoryId).get();
      if (doc.exists) {
        return Category.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting category: $e');
      return null;
    }
  }

  // Update an existing category
  Future<bool> updateCategory(String categoryId, Map<String, dynamic> updates) async {
    try {
      await _categoriesCollection.doc(categoryId).update(updates);
      return true;
    } catch (e) {
      print('Error updating category: $e');
      return false;
    }
  }

  // Delete a category
  Future<bool> deleteCategory(String categoryId) async {
    try {
      await _categoriesCollection.doc(categoryId).delete();
      return true;
    } catch (e) {
      print('Error deleting category: $e');
      return false;
    }
  }

  // Get total count of categories
  Future<int> getCategoryCount() async {
    try {
      QuerySnapshot snapshot = await _categoriesCollection.get();
      return snapshot.docs.length;
    } catch (e) {
      print('Error getting category count: $e');
      return 0;
    }
  }
}