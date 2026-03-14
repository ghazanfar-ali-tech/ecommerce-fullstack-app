import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecommerceapp/models/cart_item_model.dart';

class OrderModel {
  final String orderId;
  final List<CartItemModel> items;
  final int subtotal;
  final int shipping;
  final int tax;
  final int discount;
  final int totalAmount;
  final String status;
  final DateTime createdAt;
  final String shippingAddress;

  OrderModel({
    required this.orderId,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.discount,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.shippingAddress,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'discount': discount,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'shippingAddress': shippingAddress,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      orderId: map['orderId'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((i) => CartItemModel.fromMap(i as Map<String, dynamic>))
          .toList(),
      subtotal: map['subtotal'] ?? 0,
      shipping: map['shipping'] ?? 0,
      tax: map['tax'] ?? 0,
      discount: map['discount'] ?? 0,
      totalAmount: map['totalAmount'] ?? 0,
      status: map['status'] ?? 'active',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      shippingAddress: map['shippingAddress'] ?? '',
    );
  }
}