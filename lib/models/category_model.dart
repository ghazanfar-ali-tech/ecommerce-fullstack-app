import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String categoryName;
  final String imageUrl;
  final DateTime createdAt;
  int totalItems;

  Category({
    required this.id,
    required this.categoryName,
    required this.imageUrl,
    required this.createdAt,
    this.totalItems = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'categoryName': categoryName,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'totalItems': totalItems,
    };
  }

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      categoryName: data['categoryName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      totalItems: (data['totalItems'] ?? 0).toInt(),
    );
  }

  Category copyWith({
    String? id,
    String? categoryName,
    String? imageUrl,
    DateTime? createdAt,
    int? totalItems,
  }) {
    return Category(
      id: id ?? this.id,
      categoryName: categoryName ?? this.categoryName,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}