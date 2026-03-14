import 'package:ecommerceapp/enums/order_status.dart';

class OrderItem {
  final String orderId;
  final String productName;
  final String productImage;
  final int quantity;
  final double totalPrice;
  final OrderStatus status;
  final DateTime orderDate;
 
  const OrderItem({
    required this.orderId,
    required this.productName,
    required this.productImage,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
  });
}