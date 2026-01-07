import 'package:hive_flutter/hive_flutter.dart';
part 'cart_model.g.dart';

@HiveType(typeId: 1)
class CartModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String productName;

  @HiveField(2)
  String productCategory;

  @HiveField(3)
  int productPrice; 

  @HiveField(4)
  String productImage;

  @HiveField(5)
  int quantity; // quantity in cart

  @HiveField(6)
  int stock; // maximum available stock for this product

  CartModel({
    required this.id,
    required this.productName,
    required this.productCategory,
    required this.productPrice,
    required this.productImage,
    this.quantity = 1,
    this.stock = 10, // default stock
  });
}
