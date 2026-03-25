class SeeAllProductModel {
  final String id;
  final String categoryImage;
  final String categoryName;
  final String productDescription;
  final int productDiscount;
  final List<String> productImageUrls;
  final String productName;
  final double productPrice;
  final DateTime createdAt;

  SeeAllProductModel({
    required this.id,
    required this.categoryImage,
    required this.categoryName,
    required this.productDescription,
    required this.productDiscount,
    required this.productImageUrls,
    required this.productName,
    required this.productPrice,
    required this.createdAt,
  });

  double get discountedPrice =>
      productPrice - (productPrice * productDiscount / 100);

  factory SeeAllProductModel.fromMap(Map<String, dynamic> map, String id) {
    return SeeAllProductModel(
      id: id,
      categoryImage: map['categoryImage'] ?? '',
      categoryName: map['categoryName'] ?? '',
      productDescription: map['productDescription'] ?? '',
      productDiscount: map['productDiscount'] ?? 0,
      productImageUrls: List<String>.from(map['productImageUrls'] ?? []),
      productName: map['productName'] ?? '',
      productPrice: (map['productPrice'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}