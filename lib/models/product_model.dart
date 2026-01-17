import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final List<String> productImageUrls;
  final String productName;
  final String productDescription;
  final int productPrice;
  final int productDiscount;
  final DateTime createdAt;
  final String categoryName;
  final String categoryImage;

  ProductModel({
    required this.id,
    required this.productImageUrls,      
    required this.productName,
    required this.productDescription,
    required this.productPrice,
    required this.productDiscount,
    required this.createdAt,
    required this.categoryName,
    required this.categoryImage,
  }); 

  Map<String, dynamic> toMap() {
    return {
      "productImageUrls": productImageUrls,
      "productName": productName,
      "productDescription": productDescription,
      "productPrice": productPrice,
      "productDiscount": productDiscount,
      "createdAt": createdAt,
      "categoryName": categoryName,
      "categoryImage": categoryImage,
    };
  }

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: doc.id,
      productImageUrls: List<String>.from(data["productImageUrls"] ?? []), 
      productName: data["productName"] ?? "",
      productDescription: data["productDescription"] ?? "",
       productPrice: (data["productPrice"] ?? 0).toInt(),
    productDiscount: (data["productDiscount"] ?? 0).toInt(), 
      createdAt: (data["createdAt"] as Timestamp).toDate(),

      // 👇 Category fields
      categoryName: data["categoryName"] ?? "",
      categoryImage: data["categoryImage"] ?? "",
    );
  }

  ProductModel copyWith({
    String? id,
     List<String>? productImageUrls,
    String? productName,
    String? productDescription,
    int? productPrice,
    int? productDiscount,
    DateTime? createdAt,
    String? categoryName,
    String? categoryImage,
  }) {
    return ProductModel(
      id: id ?? this.id,
      productImageUrls: productImageUrls ?? this.productImageUrls,
      productName: productName ?? this.productName,
      productDescription: productDescription ?? this.productDescription,
      productPrice: productPrice ?? this.productPrice,
      productDiscount: productDiscount ?? this.productDiscount,
      createdAt: createdAt ?? this.createdAt,
      categoryName: categoryName ?? this.categoryName,
      categoryImage: categoryImage ?? this.categoryImage,
    );
  }
}
