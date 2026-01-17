import 'dart:async';
import 'dart:convert';
import 'package:ecommerceapp/models/cart_item_model.dart';
import 'package:ecommerceapp/resources/constants.dart';
import 'package:ecommerceapp/view_model/stats_view_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeServices {
  StripeServices._();
  static final StripeServices instance = StripeServices._();

  Future<bool> makePayment({
    required int amount,
    required String currency,
    required String userName,
    required StatsViewModel statsViewModel,
    
    String? productName,
    String? productPic,
    int? productPrice,
    String? categoryName,
    
    List<CartItemModel>? cartItems,
  }) async {
    try {
     
      String? paymentIntentClientSecret = await _createPaymentIntent(amount, currency);
      if (paymentIntentClientSecret == null) {
        if (kDebugMode) {
          print('Failed to create payment intent');
        }
        return false;
      }
      
      
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: productName ?? "Your Store Name",
        ),
      );
      
      
      await processPayment();
  
      
      if (cartItems != null && cartItems.isNotEmpty) {

    
        for (var item in cartItems) {
          if (kDebugMode) {
            print('  - ${item.productName}: Qty ${item.quantity} @ \$${item.price}');
          }
        }
        
        await statsViewModel.addCartStats(
          cartItems: cartItems,
          userName: userName,
        );

      } else if (productName != null && productPic != null && productPrice != null) {
    
        await statsViewModel.addSingleProductStats(
          productName: productName,
          productPic: productPic,
          price: productPrice,
          userName: userName,
          categoryName: categoryName ?? "Uncategorized",
        );
        if (kDebugMode) {
          print('Single product saved to Firestore');
        }
      } else {
        if (kDebugMode) {
          print('No items to save - cartItems is null or empty');
        }
      }
      
      return true;
      
    } catch (e) {


      return false;
    }
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
      Map<String, String> headers = {
        "Authorization": "Bearer $stripeSecretKey",
        "Content-Type": "application/x-www-form-urlencoded",
      };
      Map<String, dynamic> body = {
        "amount": _calculateAmount(amount),
        "currency": currency,
        "payment_method_types[]": "card",
      };
      
      var response = await http.post(url, headers: headers, body: body);
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData["client_secret"];
      } else {
        if (kDebugMode) {
          print('Failed to create payment intent: ${response.body}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating payment intent: $e');
      }
    }
    return null;
  }

  Future<void> processPayment() async {
    await Stripe.instance.presentPaymentSheet();
  }

  String _calculateAmount(int amount) {
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }
}