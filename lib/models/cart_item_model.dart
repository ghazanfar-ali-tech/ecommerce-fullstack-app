
class CartItemModel {
  final String productName;
  final String productPic;
  final int price;
  final int quantity;
  final String categoryName;

  CartItemModel({
    required this.productName,
    required this.productPic,
    required this.price,
    required this.quantity,
    required this.categoryName,
  });

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'productPic': productPic,
      'price': price,
      'quantity': quantity,
      'categoryName':categoryName
    };
  }

  // Create from Map (useful for deserialization)
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productName: map['productName'] ?? '',
      productPic: map['productPic'] ?? '',
      price: map['price'] ?? 0,
      quantity: map['quantity'] ?? 1,
      categoryName: map['categoryName'] ?? '',
    );
  }

  // Create a copy with modifications
  CartItemModel copyWith({
    String? productName, categoryName,
    String? productPic,
    int? price,
    int? quantity,
  }) {
    return CartItemModel(
      productName: productName ?? this.productName,
      productPic: productPic ?? this.productPic,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      categoryName: categoryName ?? this.categoryName,

    );
  }
}