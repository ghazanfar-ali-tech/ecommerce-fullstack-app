import 'package:ecommerceapp/repository/order_repositories.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/order_model.dart';
import '../models/cart_item_model.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _repository = OrderRepository();

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;


  List<OrderModel> get activeOrders =>
      _orders.where((o) => o.status == 'active').toList();

  List<OrderModel> get completedOrders =>
      _orders.where((o) => o.status == 'completed').toList();

  List<OrderModel> get cancelledOrders =>
      _orders.where((o) => o.status == 'cancelled').toList();


  Future<bool> placeOrder({
    required List<CartItemModel> items,
    required int subtotal,
    required int shipping,
    required int tax,
    required int discount,
    required int totalAmount,
    required String shippingAddress,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final orderId = 'ORD-${const Uuid().v4().substring(0, 8).toUpperCase()}';

      final order = OrderModel(
        orderId: orderId,
        items: items,
        subtotal: subtotal,
        shipping: shipping,
        tax: tax,
        discount: discount,
        totalAmount: totalAmount,
        status: 'active',
        createdAt: DateTime.now(),
        shippingAddress: shippingAddress,
      );

      await _repository.placeOrder(order);

      _orders.insert(0, order);

      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> fetchOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _repository.fetchOrders();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _repository.updateOrderStatus(orderId, status);
      final index = _orders.indexWhere((o) => o.orderId == orderId);
      if (index != -1) {
        _orders[index] = OrderModel(
          orderId: _orders[index].orderId,
          items: _orders[index].items,
          subtotal: _orders[index].subtotal,
          shipping: _orders[index].shipping,
          tax: _orders[index].tax,
          discount: _orders[index].discount,
          totalAmount: _orders[index].totalAmount,
          status: status,
          createdAt: _orders[index].createdAt,
          shippingAddress: _orders[index].shippingAddress,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
