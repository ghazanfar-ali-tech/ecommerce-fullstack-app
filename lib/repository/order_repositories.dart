import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _ordersCollection() {
    final uid = _auth.currentUser!.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('orders');
  }

  Future<String> placeOrder(OrderModel order) async {
    try {
      final docRef = _ordersCollection().doc(order.orderId);
      await docRef.set(order.toMap());
      return order.orderId;
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  Future<List<OrderModel>> fetchOrders() async {
    try {
      final snapshot = await _ordersCollection()
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _ordersCollection().doc(orderId).update({'status': status});
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }
}