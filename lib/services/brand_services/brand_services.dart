import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/models/brand_model.dart';

class BrandService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // subcollection path: categories/{categoryId}/brands
  CollectionReference _brandsRef(String categoryId) =>
      _firestore.collection('categories').doc(categoryId).collection('brands');

  Stream<List<BrandModel>> getBrands(String categoryId) {
    return _brandsRef(categoryId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BrandModel.fromFirestore(doc)).toList());
  }

  Future<bool> addBrand(BrandModel brand) async {
    try {
      await _brandsRef(brand.categoryId).add(brand.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBrand(
      String categoryId, String brandId, Map<String, dynamic> updates) async {
    try {
      await _brandsRef(categoryId).doc(brandId).update(updates);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBrand(String categoryId, String brandId) async {
    try {
      await _brandsRef(categoryId).doc(brandId).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}