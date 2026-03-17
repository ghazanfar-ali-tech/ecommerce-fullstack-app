import 'package:cloud_firestore/cloud_firestore.dart';

class BrandModel {
  final String id;
  final String name;
  final String imageUrl;
  final String categoryId;
  final int productCount;
  final List<String> introProductImages;
  final DateTime createdAt;

  BrandModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.categoryId,
    this.productCount = 0,
    this.introProductImages = const [],
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'imageUrl': imageUrl,
        'categoryId': categoryId,
        'productCount': productCount,
        'introProductImages': introProductImages,
        'createdAt': createdAt,
      };

  factory BrandModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BrandModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      categoryId: data['categoryId'] ?? '',
      productCount: (data['productCount'] ?? 0).toInt(),
      introProductImages: List<String>.from(data['introProductImages'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  BrandModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? categoryId,
    int? productCount,
    List<String>? introProductImages,
    DateTime? createdAt,
  }) {
    return BrandModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      productCount: productCount ?? this.productCount,
      introProductImages: introProductImages ?? this.introProductImages,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}