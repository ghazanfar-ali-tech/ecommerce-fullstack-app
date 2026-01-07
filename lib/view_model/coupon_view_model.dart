import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CouponViewModel extends ChangeNotifier {
  String? appliedCouponCode;
  int discount = 0;
  bool isLoading = false;

  Future<void> applyCoupon(String code, BuildContext context) async {
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a coupon code"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('coupons')
          .where('code', isEqualTo: code)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Coupon exists
        discount = snapshot.docs.first['discount'] ?? 0;
        appliedCouponCode = code;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Coupon applied! Discount: \$$discount"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        discount = 0;
        appliedCouponCode = null;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Invalid coupon code"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      discount = 0;
      appliedCouponCode = null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error applying coupon: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
